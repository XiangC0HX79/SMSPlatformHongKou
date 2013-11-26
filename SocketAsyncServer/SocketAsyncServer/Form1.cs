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

        public const string EmppHost = "211.136.163.68";
        public const int EmppPort = 9981;
        public const string EmppAccountId = "10657109080176";
        private string _EmppPassword = "10657109080176";

        private int _ConnectCount = 0;

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

                var clsGetData = new ClsGetData("System.Data.OleDb", ConfigurationManager.AppSettings["DBConStr"]);
                var o = clsGetData.GetValue("SELECT 参数值 FROM 系统设置 WHERE 参数名称 = '平台密码'");
                if (o == null)
                {
                    WriteSystemErrorLog.ntWriteLogSystemTxt("初始化错误: " + clsGetData.ErrorString);
                }
                else
                {
                    _EmppPassword = clsGetData.GetValue("SELECT 参数值 FROM 系统设置 WHERE 参数名称 = '平台密码'").ToString();

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
                        var serviceID = xmlDocReceive.SelectSingleNode("/xml/serviceID").InnerText;

                        SendSms(phone, message, serviceID);

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

        private void SendSms(String pMods, String pMessage, String serviceId)
        {
            ShortMessage shortMsg = new ShortMessageClass();
            shortMsg.srcID = EmppAccountId;
            shortMsg.content = pMessage;
            shortMsg.ServiceID = serviceId;
            shortMsg.needStatus = true;
            shortMsg.SendNow = true;

            String[] aMobs = pMods.Split(';');
            Mobiles mobs = new MobilesClass();
            foreach (String mob in aMobs)
            {
                if (mob.Trim() != "")
                {
                    mobs.Add(mob.Trim());
                }
            }

            shortMsg.DestMobiles = mobs;

            if (_empp.connected)
            {
                WriteSystemErrorLog.ntWriteLogSystemTxt("发送前状态：seqId=" + _empp.SequenceID + ",msgId=" + _empp.MsgID + ",电话=" + pMods + ",内容=" + pMessage + ",用户=" + serviceId);

                _empp.submit(shortMsg);

                WriteSystemErrorLog.ntWriteLogSystemTxt("发送后状态：seqId=" + _empp.SequenceID + ",msgId=" + _empp.MsgID);
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
            WriteSystemErrorLog.ntWriteLogSystemTxt("MessageReceivedInterface。");

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
            WriteSystemErrorLog.ntWriteLogSystemTxt("收到状态:seqId=" + sm.SeqID + ",msgId=" + sm.MsgID + ",mobile=" + sm.DestID + ",destId=" + sm.SrcTerminalId + ",stat=" + sm.Status + ",serviceID=" + sm.ServiceID);

            //string str = "收到状态:seqId=" + sm.SeqID + ",msgId=" + sm.MsgID + ",mobile=" + sm.DestID + ",destId=" + sm.SrcTerminalId + ",stat=" + sm.Status + ",serviceID=" + sm.ServiceID;
            //Console.WriteLine(str);
            //Program.testWriter.WriteLine(str);

            //ServiceReference1.ServiceSoapClient sc = new SocketAsyncServer.ServiceReference1.ServiceSoapClient();
            //try
            //{
            //    sc.UpdateSend("", sm.Status, sm.MsgID);
            //}
            //catch (Exception e)
            //{
            //}
        }

        private void SubmitRespInterface(SubmitResp sm)
        {
            WriteSystemErrorLog.ntWriteLogSystemTxt("提交状态:msgId=" + sm.MsgID + ",seqId=" + sm.SequenceID + ",result=" + sm.Result);

            //string str = "提交状态:msgId=" + sm.MsgID + ",seqId=" + sm.SequenceID + ",result=" + sm.Result;
            //Console.WriteLine(str);
            //Program.testWriter.WriteLine(str);

            //if (emppIDs.ContainsKey(sm.SequenceID - 1))
            //{
            //    ServiceReference1.ServiceSoapClient sc = new SocketAsyncServer.ServiceReference1.ServiceSoapClient();

            //    try
            //    {
            //        sc.UpdateSend(emppIDs[sm.SequenceID - 1], sm.Result.ToString(), sm.MsgID);
            //    }
            //    catch (Exception e)
            //    {
            //    }
            //}
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
