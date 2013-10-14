
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
            Console.WriteLine("我们进入到createPro函数里面**********************************");          
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
                LogUtil.toLog("INDE 我们首次建立连接开始");
                result = this.empp.connect(host, port, accountId, password);
            }catch (Exception ex){
                LogUtil.toLog("INDE 我们首次建立连接开始，以失败告终");
                LogUtil.toLog(ex.ToString());
            }


            int con = 0; 
            while (result != EMPPLib.ConnectResultEnum.CONNECT_OK && result != EMPPLib.ConnectResultEnum.CONNECT_KICKLAST){
                LogUtil.toLog("我们首次连接失败，接下来进行while重连----------" + con);
                con++; 
                try{
                    result = this.empp.connect(host, port, accountId, password);
                }catch (Exception ex){
                    ex.ToString();
                }

            }


           // string msg = "一是一瓜，二是二瓜，三是三瓜，四是四瓜，五是万瓜，六是六瓜，七是七瓜，八是八瓜，九是九瓜，十个是十个瓜，十一个是十一个瓜，十二个是十二瓜瓜，十三是十三瓜，一是一瓜，二是二瓜，三是三瓜，四是四瓜，五是万瓜，六是六瓜，七是七瓜，八是八瓜，九是九瓜，十个是十个瓜，十一个是十一个瓜，十二个是十二瓜瓜，十三是十三瓜，";           
            //Thread.Sleep(3000);
            String msg = "一是一瓜，二是二瓜，三是三瓜，四是四瓜，五是万瓜，六是六瓜，七是七瓜，八是八瓜，九是九瓜，十个是七瓜，八是八瓜，九是九瓜，十个是七瓜，八是八瓜，九是九瓜，十个是七瓜，八是八瓜，九是九瓜，十个是 tianijiajijsdfasf";            
            msg = msg.Substring(0,60);
            //msg = "宝宝好啊 ... 哥哥 ...";
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
                //shortMsg.content ="lujia  " + i + "  lujia    " +  msg + ":" + "【时间" + DateTime.Now.ToString() + "】";
                //shortMsg.SequenceID = new Random().Next(100000);
                shortMsg.content = msg;
                LogUtil.toLog("我们打印原始的短信内容：" + msg);
                shortMsg.SendNow=true;
				empp.needStatus=true;
                if (empp!=null && empp.connected == true){
                    Console.WriteLine("即将发送短信" + i + "diaoyong");                 
                    Console.WriteLine("现在的连接状况是: " + empp.connected);

                    LogUtil.toLog("\r\n"); 
                    LogUtil.toLog("目前的连接状况是：" + empp.connected );
                    LogUtil.toLog("目前的短信的seqid是：" + shortMsg.SequenceID);
                    LogUtil.toLog("the empp.sequceid:" + empp.SequenceID);
                    LogUtil.toLog("IF语句   我们即将发送短信：" + shortMsg.content);
                    empp.submit(shortMsg);
                    
                    LogUtil.toLog("IF语句   我们已经发送短信：" + shortMsg.content);
                    
                    Console.WriteLine("短信提交结束" + i);
                    Console.WriteLine("end empp.SequenceID:" + empp.SequenceID);
                    Thread.Sleep(1000);

                }
                else {
                    LogUtil.toLog("连接已经关闭，我们即将重新连接：现在我们在else语句里面");
                    Reconnect2();                   
                    Console.WriteLine("即将发送短信" + i + "diaoyong");                   
                    Console.WriteLine("现在的连接状况是: " + empp.connected);

                    LogUtil.toLog("\r\n");
                    LogUtil.toLog("目前的连接状况是：" + empp.connected);
                    LogUtil.toLog("目前的shortmsgseqid是：" + shortMsg.SequenceID);
                    LogUtil.toLog("目前的emppseqid是：" + empp.SequenceID);

                    LogUtil.toLog("ELSE语句   我们即将发送短信：" + msg);
                    empp.submit(shortMsg);
                    LogUtil.toLog("ELSE语句   我们已经发送短信：" + msg);
                    
                    Console.WriteLine("短信提交结束" + i);
                    Console.WriteLine("end empp.SequenceID:" + empp.SequenceID);
                    Console.WriteLine("");
                    Thread.Sleep(200);
                }              
			}
            Thread.Sleep(1000000);
		}

		public void SubmitRespInterface(SubmitResp sm)
		{
			string str="收到submitResp:msgId="+sm.MsgID+",seqId="+sm.SequenceID+",result="+sm.Result;
            Console.WriteLine(""+sm.ToString());
			Console.WriteLine(str);
            LogUtil.toLog("我们收到提交返回：" + str);
		 
		}

		public void EMPPClosed(int errorCode){            			
            LogUtil.toLog("发生了EMPPClose事件了");
		}

		
		public void SocketClosed(int errorCode)
		{            
            Console.WriteLine("发生了socketcolse事件");        
			string str="SocketClosed:errorCode="+errorCode+",connected="+empp.connected;
            LogUtil.toLog("我们现在发生了socketclose事件：" + "errorcoded is :" + errorCode +"我们即将进行重新连接");
			Console.WriteLine(str);            
			Reconnect2();           
		}
				
		
		public void Reconnect2(){					
			this.empp=new EMPPLib.emptclClass();
            createPro(this.empp);
            LogUtil.toLog("发生异常，我们正在重新连接");
            Console.WriteLine("发生异常，我们正在重新连接");
            EMPPLib.ConnectResultEnum result = ConnectResultEnum.CONNECT_OTHER_ERROR;
            try { 
                result = this.empp.connect(host, port, accountId, password); }
            catch(Exception ex){
                LogUtil.toLog(ex.ToString());
            }
           


            while (result != EMPPLib.ConnectResultEnum.CONNECT_OK && result != EMPPLib.ConnectResultEnum.CONNECT_KICKLAST){
                LogUtil.toLog("WHILE   发生异常，我们进行重新连接");
                Console.WriteLine("WHILE   发生异常，我们进行重新连接");
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
			string str="收到手机回复:srcId="+sm.srcID+"               ,content="+sm.content+"企业扩展位"+sm.DestID;
            string content = sm.content.Trim();
            Console.WriteLine(str);
            LogUtil.toLog(str);
            LogUtil.toLog(content+"我们到此结束");
		}

		public void StatusReceivedInterface(StatusReport sm){
			string str="收到状态报告:seqId="+sm.SeqID+",msgId="+sm.MsgID+",mobile="+sm.DestID+",destId="+sm.SrcTerminalId+",stat="+sm.Status;
			Console.WriteLine(str);
            LogUtil.toLog(str);
			
		}

		public void EMPPConnected()		{
			string str="已连接";
			Console.WriteLine(str);
			
		}
	}
	
}
