using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using System.Xml;
using CommonUtility;
using EMPPLib;
using Timer = System.Windows.Forms.Timer;

namespace SocketAsyncServer
{
    public partial class Form1 : Form
    {
        private readonly TcpAsyncServer _tcpAsyncServer;
        private readonly emptcl _empp = new emptclClass();
        private readonly ClsGetData _clsGetData;
               
        public const string EmppHost = "211.136.163.68";
        public const int EmppPort = 9981;
        public const string EmppAccountId = "10657109080176";
        private string _EmppPassword = "";

        private Dictionary<string, int> _emppIDs = new Dictionary<string, int>();
        private Dictionary<int, int> _SendCounts = new Dictionary<int, int>();

        private int _ConnectCount = 0;
        private bool _IsPatrol = false;

        public Form1()
        {
            InitializeComponent();

            try
            {
                _tcpAsyncServer = new TcpAsyncServer(Convert.ToInt32(ConfigurationManager.AppSettings["ServerPort"]), IPAddress.Any);
                _tcpAsyncServer.DataReceived += tcpAsynServer_DataReceived;
                _tcpAsyncServer.Connected += tcpAsynServer_Connected;
               
                _empp.needStatus = true;

                _empp.EMPPClosed += (new _IemptclEvents_EMPPClosedEventHandler(EMPPClosed));
                _empp.EMPPConnected += (new _IemptclEvents_EMPPConnectedEventHandler(EMPPConnected));
                _empp.MessageReceivedInterface += (new _IemptclEvents_MessageReceivedInterfaceEventHandler(MessageReceivedInterface));
                _empp.SocketClosed += (new _IemptclEvents_SocketClosedEventHandler(SocketClosed));
                _empp.StatusReceivedInterface += (new _IemptclEvents_StatusReceivedInterfaceEventHandler(StatusReceivedInterface));
                _empp.SubmitRespInterface += (new _IemptclEvents_SubmitRespInterfaceEventHandler(SubmitRespInterface));

                _clsGetData = new ClsGetData("System.Data.OleDb", ConfigurationManager.AppSettings["DBConStr"]);

                var o = _clsGetData.GetValue("SELECT 参数值 FROM 系统设置 WHERE 参数名称 = '平台密码'");
                if (o == null)
                {
                    WriteSystemErrorLog.ntWriteLogSystemTxt("初始化错误: " + _clsGetData.ErrorString);
                }
                else
                {
                    _EmppPassword = o.ToString();

                    ConnnectEmpp(0);
                }

                var timer = new Timer { Interval = 60000 };
                timer.Tick  += timer_Tick;
                timer.Start();
            }
            catch (Exception ex)
            {
                WriteSystemErrorLog.ntWriteLogSystemTxt(ex.Message);
            }
        }
               
        private void timer_Tick(object sender, EventArgs e)
        {
            if (_empp == null)
                return;

            if (_ConnectCount < 60)
            {
                if (!_empp.connected)
                {
                    ConnnectEmpp(0);
                }
                else
                {
                    if ((DateTime.Now.TimeOfDay > TimeSpan.FromHours(8))
                        && !_IsPatrol)
                    {
                        _IsPatrol = true;

                        SendSms("15921065956", "系统巡检", "000");
                    }
                }
            }
            else
            {
                _ConnectCount = 0;

                if (_empp.connected)
                {
                    _empp.disconnect();
                }

                ConnnectEmpp(1000);
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
        }

        private void tcpAsynServer_Connected(Object sender, ref TcpAsyncServer.SockWrapper sockWrapper)
        {
            WriteSystemErrorLog.ntWirteTcpReceiveInfomation(sockWrapper.Client.RemoteEndPoint.ToString(), "Connected", "连接客户端...");
        }

        private void tcpAsynServer_DataReceived(Object sender, ref TcpAsyncServer.SockWrapper sockWrapper,
                                                ref byte[] bContent, int iCount)
        {
            var bRecv = new byte[iCount];

            Array.Copy(bContent, bRecv, iCount);

            try
            {
                //收到指令后打印出来
                var sRecv = Encoding.UTF8.GetString(bRecv);

                WriteSystemErrorLog.ntWirteTcpReceiveInfomation(sockWrapper.Client.RemoteEndPoint.ToString(), "DataReceived", sRecv);


                if (sRecv == "<policy-file-request/>\0")
                {
                    const string xml =
                        "<?xml version=\"1.0\"?><cross-domain-policy><site-control permitted-cross-domain-policies=\"all\"/><allow-access-from domain=\"*\" to-ports=\"*\"/></cross-domain-policy>\0";

                    var bSend = Encoding.UTF8.GetBytes(xml);

                    _tcpAsyncServer._SendOne(sockWrapper, bSend, bSend.Length);

                    _tcpAsyncServer.RemoveConnection(sockWrapper);
                }
                else
                {
                    var xmlDocReceive = new XmlDocument();
                    xmlDocReceive.LoadXml(sRecv);

                    var nodeeMethod = xmlDocReceive.SelectSingleNode("/xml/method");

                    //发送激活用户验证码
                    if (nodeeMethod.InnerText == "method_sendverification")
                    {
                        var phone = xmlDocReceive.SelectSingleNode("/xml/phone").InnerText;

                        String verification = (new Random().Next(1000, 10000)).ToString();

                        SendSms(phone, verification, "000");

                        var bSend = Encoding.UTF8.GetBytes(verification);

                        _tcpAsyncServer._SendOne(sockWrapper, bSend, bSend.Length);
                    }
                        //登录时创建SMS
                    else if (nodeeMethod.InnerText == "method_login")
                    {
                        var bSend = Encoding.UTF8.GetBytes("Login Complete");

                        _tcpAsyncServer._SendOne(sockWrapper, bSend, bSend.Length);
                    }
                        //发送短信
                    else if (nodeeMethod.InnerText == "method_sendSMS")
                    {
                        var phone = xmlDocReceive.SelectSingleNode("/xml/phone").InnerText;
                        var message = xmlDocReceive.SelectSingleNode("/xml/message").InnerText;
                        var serviceId = xmlDocReceive.SelectSingleNode("/xml/serviceID").InnerText;

                        var aMobs = phone.Split(';');
                        foreach (var mob in aMobs.Where(mob => (mob.Length == 11)))
                        {
                            var sendId = InsertSend(mob, message, "SENDING", serviceId);
                            if (sendId <= 0) continue;

                            _SendCounts[sendId] = 0;

                            while(true)
                            {
                                if (SendSms(mob, message, serviceId, sendId))
                                    break;

                                Thread.Sleep(10000);

                                //var o = _clsGetData.GetValue(String.Format("SELECT 短信ID FROM 短信_发件箱 WHERE ID = {0}", sendId));

                                //if ((o != null) && (o.ToString() == ""))
                                //    _clsGetData.SetTable(
                                //        String.Format("UPDATE 短信_发件箱 SET 状态 = '{0}',时间 = now() WHERE ID = {1}", "FAILED",
                                //            sendId));
                                //else
                                //    break;
                            }

                            Thread.Sleep(2000);
                        }

                        var bSend = Encoding.UTF8.GetBytes("Send Complete.");

                        _tcpAsyncServer._SendOne(sockWrapper, bSend, bSend.Length);
                    }
                }
            }
            catch (Exception ex)
            {
                WriteSystemErrorLog.ntWriteLogSystemTxt("DataReceived Error:" + ex.Message);
            }
        }

        private void ConnnectEmpp(int interval)
        {
            try
            {
                if (interval > 0)
                    Thread.Sleep(interval);

                var result = _empp.connect(EmppHost, EmppPort, EmppAccountId, _EmppPassword);
                if ((result != ConnectResultEnum.CONNECT_OK) && (result != ConnectResultEnum.CONNECT_KICKLAST))
                {
                    WriteSystemErrorLog.ntWriteLogSystemTxt("Empp连接失败。代码：" + result);
                }
            }
            catch (Exception ex)
            {
                WriteSystemErrorLog.ntWriteLogSystemTxt("Empp连接失败。代码：" + ex.Message);
            }
        }

        private int InsertSend(String phone, String message, String status,String userId)
        {
            var o = _clsGetData.GetValue(String.Format("SELECT 手机号码 FROM 会员名单 WHERE ID = {0}",userId));
            var sendPhone = (o != null)?o.ToString():"";

            o = _clsGetData.GetValue("SELECT 姓名 FROM 会员名单 WHERE InStr(手机号码,'" + phone + "') > 0");
            var people = (o != null) ? o.ToString() : "";

            var sql = "INSERT INTO 短信_发件箱 (时间,手机号码,短信,状态,姓名,发送号码) values (now(),'"
                    + phone + "','" + message + "','" + status + "','" + people + "','" + sendPhone + "')";

            var resultCount = _clsGetData.SetTable(sql);
            if (resultCount > 0)
            {
                sql = "SELECT MAX(ID) FROM 短信_发件箱";
                return Convert.ToInt32(_clsGetData.GetValue(sql));
            }
            else
            {
                return resultCount;
            }
        }

        private void SendSms(String mob, String pMessage, String serviceId)
        {
            try
            {
                ShortMessage shortMsg = new ShortMessageClass();
                shortMsg.srcID = EmppAccountId;
                shortMsg.content = pMessage;
                shortMsg.ServiceID = serviceId;
                shortMsg.needStatus = true;
                shortMsg.SendNow = true;

                Mobiles mobs = new MobilesClass();
                mobs.Add(mob);

                shortMsg.DestMobiles = mobs;

                if (_empp.connected)
                {
                    _empp.submit(shortMsg);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private bool SendSms(String mob, String pMessage, String serviceId,int sendId)
        {
            try
            {
                if (_SendCounts[sendId] > 3)
                {
                    _clsGetData.SetTable(
                                        String.Format("UPDATE 短信_发件箱 SET 状态 = '{0}',时间 = now() WHERE ID = {1}", "FAILED",
                                            sendId));

                    WriteSystemErrorLog.ntWriteLogSystemTxt("Empp发送失败。代码：发送次数超过3次。");

                    return true;
                }

                ShortMessage shortMsg = new ShortMessageClass();
                shortMsg.srcID = EmppAccountId;
                shortMsg.content = pMessage;
                shortMsg.ServiceID = serviceId;
                shortMsg.needStatus = true;
                shortMsg.SendNow = true;
                
                Mobiles mobs = new MobilesClass();
                mobs.Add(mob);

                shortMsg.DestMobiles = mobs;

                if (_empp.connected)
                {
                    WriteSystemErrorLog.ntWriteLogSystemTxt("发送前状态：seqId=" + _empp.SequenceID + ",msgId=" + _empp.MsgID + ",电话=" + mob + ",内容=" + pMessage + ",用户=" + serviceId);

                    _emppIDs[_empp.SequenceID] = sendId;

                    _SendCounts[sendId]++;
                    _empp.submit(shortMsg);

                    return true;
                    //var msgId =
                    //    _clsGetData.GetValue(String.Format("SELECT 短信ID FROM 短信_发件箱 WHERE ID = {0}", sendId)).ToString();

                    //if (msgId == "")
                    //{
                    //    WriteSystemErrorLog.ntWriteLogSystemTxt("Empp发送失败。代码：短信未能提交到服务器。");

                    //    return false;
                    //}
                    //else
                    //{
                    //    return true;
                    //}
                }
                else
                {
                    WriteSystemErrorLog.ntWriteLogSystemTxt("Empp发送失败。代码：未连接Empp服务器。");
                    return false;
                }
            }
            catch (Exception ex)
            {
                WriteSystemErrorLog.ntWriteLogSystemTxt("Empp发送失败。代码：" + ex.Message);
                return false;
            }
        }

        private void EMPPConnected()
        {
            WriteSystemErrorLog.ntWriteLogSystemTxt("EMPP已连接。");
        }

        private void EMPPClosed(int errorCode)
        {
            WriteSystemErrorLog.ntWriteLogSystemTxt("发生了EMPPClose事件。");

            ConnnectEmpp(10000);
        }

        private void SocketClosed(int errorCode)
        {
            WriteSystemErrorLog.ntWriteLogSystemTxt("发生了SocketClosed事件。");

            ConnnectEmpp(10000);
        }
               
        private void MessageReceivedInterface(SMDeliverd sm)
        {
            var o = _clsGetData.GetValue(String.Format("SELECT 姓名 FROM 会员名单 WHERE InStr(手机号码,'{0}') > 0",sm.srcID));
            var people = (o != null) ? o.ToString() : "";

            _clsGetData.SetTable(String.Format("INSERT INTO 短信_收件箱 (时间,手机号码,短信,姓名) values (now(),'{0}','{1}','{2}')",sm.srcID,sm.content,people));

            o =
                _clsGetData.GetValue(String.Format("SELECT TOP 1 发送号码 FROM 短信_发件箱 WHERE 手机号码 = '{0}' ORDER BY 时间 DESC",
                    sm.srcID));

            var phone = (o != null) ? o.ToString() : "";
            if (phone != "")
                SendSms(phone, sm.content + " " + people, "000");

            //string str = "手机回复:srcId=" + sm.srcID + ",content=" + sm.content + "企业扩展位" + sm.DestID + ",ServiceID=" + sm.ServiceID + ",MsgID=" + sm.MsgID;
            //Console.WriteLine(str);
            //Program.testWriter.WriteLine(str);

            //ServiceReference1.ServiceSoapClient sc = new SocketAsyncServer.ServiceReference1.ServiceSoapClient();

            //try
            //{
            //    sc.SetReceive(sm.srcID, sm.content);
            //}
            //catch (Exception e)
            //{
            //}
        }

        private void StatusReceivedInterface(StatusReport sm)
        {
            WriteSystemErrorLog.ntWriteLogSystemTxt("收到状态:seqId=" + sm.SeqID + ",msgId=" + sm.MsgID + ",mobile=" + sm.DestID + ",destId=" + sm.SrcTerminalId + ",stat=" + sm.Status + ",serviceID=" + sm.ServiceID + ",emmp seqId=" + _empp.SequenceID);

            _clsGetData.SetTable(String.Format("UPDATE 短信_发件箱 SET 状态 = '{0}',时间 = now() WHERE 短信ID = '{1}'", sm.Status, sm.MsgID));
        }

        private void SubmitRespInterface(SubmitResp sm)
        {
            var key = (sm.SequenceID - 1).ToString();

            if (!_emppIDs.ContainsKey(key)) return;

            var sendId = _emppIDs[key];

            WriteSystemErrorLog.ntWriteLogSystemTxt("提交状态:msgId=" + sm.MsgID + ",seqId=" + sm.SequenceID + ",result=" + sm.Result + ",emmp seqId=" + _empp.SequenceID);

            _clsGetData.SetTable(String.Format("UPDATE 短信_发件箱 SET 状态 = '{0}',短信ID = '{1}',时间 = now() WHERE ID = {2}", sm.Result,sm.MsgID, sendId));
        }

        private void Form1_FormClosed(object sender, FormClosedEventArgs e)
        {
            if (_empp.connected)
            {
                _empp.disconnect();
            }
        }
    }
}
