
using System;
using System.Threading;
using EMPPLib;
using System.Text;


namespace csharpEmppApiTest
{
	public class MainClass
	{
		string host="211.136.163.68";
		int port=9981;

        string accountId = "10657109080176";
        string serviceId = "0";
		string password  = "abcd1234";	
		public EMPPLib.emptcl empp=new EMPPLib.emptclClass();        

		public static void Main(string[] args)
		{
			MainClass mains=new MainClass();
			mains.run();			
		}

        public void createPro(EMPPLib.emptcl empp)
        {
            Console.WriteLine("���ǽ��뵽createPro��������**********************************");          
            empp.EMPPClosed += (new _IemptclEvents_EMPPClosedEventHandler(EMPPClosed));          
            empp.EMPPConnected += (new _IemptclEvents_EMPPConnectedEventHandler(EMPPConnected));          
            empp.MessageReceivedInterface += (new _IemptclEvents_MessageReceivedInterfaceEventHandler(MessageReceivedInterface));          
            empp.SocketClosed += (new _IemptclEvents_SocketClosedEventHandler(SocketClosed));          
            empp.StatusReceivedInterface += (new _IemptclEvents_StatusReceivedInterfaceEventHandler(StatusReceivedInterface));          
            empp.SubmitRespInterface += (new _IemptclEvents_SubmitRespInterfaceEventHandler(SubmitRespInterface));
          
        }

		public void run(){
            createPro(this.empp);			
            EMPPLib.ConnectResultEnum result = ConnectResultEnum.CONNECT_OTHER_ERROR;
            try{
                LogUtil.toLog("INDE �����״ν������ӿ�ʼ");
                result = this.empp.connect(host, port, accountId, password);
            }catch (Exception ex){
                LogUtil.toLog("INDE �����״ν������ӿ�ʼ����ʧ�ܸ���");
                LogUtil.toLog(ex.ToString());
            }


            int con = 0; 
            while (result != EMPPLib.ConnectResultEnum.CONNECT_OK && result != EMPPLib.ConnectResultEnum.CONNECT_KICKLAST){
                LogUtil.toLog("�����״�����ʧ�ܣ�����������while����----------" + con);
                con++; 
                try{
                    result = this.empp.connect(host, port, accountId, password);
                }catch (Exception ex){
                    ex.ToString();
                }

            }


           // string msg = "һ��һ�ϣ����Ƕ��ϣ��������ϣ������Ĺϣ�������ϣ��������ϣ������߹ϣ����ǰ˹ϣ����ǾŹϣ�ʮ����ʮ���ϣ�ʮһ����ʮһ���ϣ�ʮ������ʮ���Ϲϣ�ʮ����ʮ���ϣ�һ��һ�ϣ����Ƕ��ϣ��������ϣ������Ĺϣ�������ϣ��������ϣ������߹ϣ����ǰ˹ϣ����ǾŹϣ�ʮ����ʮ���ϣ�ʮһ����ʮһ���ϣ�ʮ������ʮ���Ϲϣ�ʮ����ʮ���ϣ�";           
            //Thread.Sleep(3000);
            String msg = "һ��һ�ϣ����Ƕ��ϣ��������ϣ������Ĺϣ�������ϣ��������ϣ������߹ϣ����ǰ˹ϣ����ǾŹϣ�ʮ�����߹ϣ����ǰ˹ϣ����ǾŹϣ�ʮ�����߹ϣ����ǰ˹ϣ����ǾŹϣ�ʮ�����߹ϣ����ǰ˹ϣ����ǾŹϣ�ʮ���� tianijiajijsdfasf";            
            msg = msg.Substring(0,60);
            //msg = "�����ð� ... ��� ...";
            for(int i=0;i<1;i++){
			   
				EMPPLib.ShortMessage shortMsg=new EMPPLib.ShortMessageClass();                
				shortMsg.srcID=accountId;                
				shortMsg.ServiceID=serviceId;                
				shortMsg.needStatus=true;                
				EMPPLib.Mobiles mobs=new EMPPLib.MobilesClass();				
                //mobs.Add("13800210021");
                //mobs.Add("13800210111");                 
                //mobs.Add("15921917717");
                mobs.Add("15921065956");
                shortMsg.DestMobiles=mobs;
                //shortMsg.content ="lujia  " + i + "  lujia    " +  msg + ":" + "��ʱ��" + DateTime.Now.ToString() + "��";
                //shortMsg.SequenceID = new Random().Next(100000);
                shortMsg.content = msg;
                LogUtil.toLog("���Ǵ�ӡԭʼ�Ķ������ݣ�" + msg);
                shortMsg.SendNow=true;
				empp.needStatus=true;
                if (empp!=null && empp.connected == true){
                    Console.WriteLine("�������Ͷ���" + i + "diaoyong");                 
                    Console.WriteLine("���ڵ�����״����: " + empp.connected);

                    LogUtil.toLog("\r\n"); 
                    LogUtil.toLog("Ŀǰ������״���ǣ�" + empp.connected );
                    LogUtil.toLog("Ŀǰ�Ķ��ŵ�seqid�ǣ�" + shortMsg.SequenceID);
                    LogUtil.toLog("the empp.sequceid:" + empp.SequenceID);
                    LogUtil.toLog("IF���   ���Ǽ������Ͷ��ţ�" + shortMsg.content);
                    empp.submit(shortMsg);
                    
                    LogUtil.toLog("IF���   �����Ѿ����Ͷ��ţ�" + shortMsg.content);
                    
                    Console.WriteLine("�����ύ����" + i);
                    Console.WriteLine("end empp.SequenceID:" + empp.SequenceID);
                    Thread.Sleep(1000);

                }
                else {
                    LogUtil.toLog("�����Ѿ��رգ����Ǽ����������ӣ�����������else�������");
                    Reconnect2();                   
                    Console.WriteLine("�������Ͷ���" + i + "diaoyong");                   
                    Console.WriteLine("���ڵ�����״����: " + empp.connected);

                    LogUtil.toLog("\r\n");
                    LogUtil.toLog("Ŀǰ������״���ǣ�" + empp.connected);
                    LogUtil.toLog("Ŀǰ��shortmsgseqid�ǣ�" + shortMsg.SequenceID);
                    LogUtil.toLog("Ŀǰ��emppseqid�ǣ�" + empp.SequenceID);

                    LogUtil.toLog("ELSE���   ���Ǽ������Ͷ��ţ�" + msg);
                    empp.submit(shortMsg);
                    LogUtil.toLog("ELSE���   �����Ѿ����Ͷ��ţ�" + msg);
                    
                    Console.WriteLine("�����ύ����" + i);
                    Console.WriteLine("end empp.SequenceID:" + empp.SequenceID);
                    Console.WriteLine("");
                    Thread.Sleep(200);
                }              
			}
            Thread.Sleep(1000000);
		}

		public void SubmitRespInterface(SubmitResp sm)
		{
			string str="�յ�submitResp:msgId="+sm.MsgID+",seqId="+sm.SequenceID+",result="+sm.Result;
            Console.WriteLine(""+sm.ToString());
			Console.WriteLine(str);
            LogUtil.toLog("�����յ��ύ���أ�" + str);
		 
		}

		public void EMPPClosed(int errorCode){            			
            LogUtil.toLog("������EMPPClose�¼���");
		}

		
		public void SocketClosed(int errorCode)
		{            
            Console.WriteLine("������socketcolse�¼�");        
			string str="SocketClosed:errorCode="+errorCode+",connected="+empp.connected;
            LogUtil.toLog("�������ڷ�����socketclose�¼���" + "errorcoded is :" + errorCode +"���Ǽ���������������");
			Console.WriteLine(str);            
			Reconnect2();           
		}
				
		
		public void Reconnect2(){					
			this.empp=new EMPPLib.emptclClass();
            createPro(this.empp);
            LogUtil.toLog("�����쳣������������������");
            Console.WriteLine("�����쳣������������������");
            EMPPLib.ConnectResultEnum result = ConnectResultEnum.CONNECT_OTHER_ERROR;
            try { 
                result = this.empp.connect(host, port, accountId, password); }
            catch(Exception ex){
                LogUtil.toLog(ex.ToString());
            }
           


            while (result != EMPPLib.ConnectResultEnum.CONNECT_OK && result != EMPPLib.ConnectResultEnum.CONNECT_KICKLAST){
                LogUtil.toLog("WHILE   �����쳣�����ǽ�����������");
                Console.WriteLine("WHILE   �����쳣�����ǽ�����������");
                try{
                    result = this.empp.connect(host, port, accountId, password);
                    Thread.Sleep(100);
                }
                catch (Exception ex){
                    ex.ToString();
                }              
            
            }

            LogUtil.toLog("congratulation , now the connection is ok or kicklast");
            Thread.Sleep(3000);
		}


		public void MessageReceivedInterface(SMDeliverd sm)	{            
			string str="�յ��ֻ��ظ�:srcId="+sm.srcID+"               ,content="+sm.content+"��ҵ��չλ"+sm.DestID;
            string content = sm.content.Trim();
            Console.WriteLine(str);
            LogUtil.toLog(str);
            LogUtil.toLog(content+"���ǵ��˽���");
		}

		public void StatusReceivedInterface(StatusReport sm){
			string str="�յ�״̬����:seqId="+sm.SeqID+",msgId="+sm.MsgID+",mobile="+sm.DestID+",destId="+sm.SrcTerminalId+",stat="+sm.Status;
			Console.WriteLine(str);
            LogUtil.toLog(str);
			
		}

		public void EMPPConnected()		{
			string str="������";
			Console.WriteLine(str);
			
		}
	}
	
}
