package app.model
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.flash_proxy;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import app.AppNotification;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class SocketProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "SocketProxy";
		
		public static const METHOD_SENDVERIFICATION:String = "method_sendverification";
		public static const METHOD_LOGIN:String = "method_login";
		public static const METHOD_SENDSMS:String = "method_sendSMS";
		
		public static var socketIP:String = "218.242.160.247";
		
		public static var socketPort:int = 4444;
		
		private var socket:Socket;  
		
		[Embed(source="assets/image/icon_error.png")]
		private const ICON_ERROR:Class;
		
		public function SocketProxy()
		{
			super(NAME,new XML);
			
			socket = new Socket;
			
			socket.addEventListener(Event.CLOSE,onClose);			
			
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSocketOnSecurityError); 			
			socket.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandle);			
		}
		
		public function get xml():XML
		{
			return data as XML;
		}
		
		public function conect(resultHandle:Function):void
		{								
			socket.addEventListener(Event.CONNECT,onConnect);	
			
			socket.connect(SocketProxy.socketIP,SocketProxy.socketPort);
			
			Security.loadPolicyFile("xmlsocket://" + SocketProxy.socketIP + ":" + SocketProxy.socketPort);
						
			function onConnect( event:Event ):void 
			{  				
				socket.removeEventListener(Event.CONNECT,onConnect);
				
				socket.close();
				
				resultHandle();
				
				trace("Socket首次连接.");  
			}  
		}
		
		//Socket连接失败  
		private function onClose( event:Event ):void 
		{  			
			trace("Socket连接失败.");  
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["StartListen",onStartListen,[],true]);
		} 
				
		private function closeHandle(event:CloseEvent):void
		{			
			flash.net.navigateToURL(new URLRequest("javascript:location.reload();"),"_self");
		}
		
		//安全错误  
		private function ioErrorHandle(evt:IOErrorEvent):void
		{  
			trace("io异常");  
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["StartListen",onStartListen,[],true]);
		}  
		
		//安全错误  
		private function onSocketOnSecurityError( event:SecurityErrorEvent ):void 
		{  
			trace("发生SecurityError."); 
						
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["StartListen",onStartListen,[],true]);
		}  
		
		private function onStartListen(result:String):void
		{
			Alert.show("短信服务器连接失败，请点击确定重新登录系统连接服务器！","民建信息服务管理平台",4,null,closeHandle,ICON_ERROR);
		}
		
		public function sendSMS(method:String,phone:String,message:String,serviceID:String,resultHandle:Function = null):void
		{
			var xml:XML = 
				<xml>
					<method/>
					<phone/>
					<message/>
					<serviceID/>
				</xml>;
			xml.method = method;
			xml.phone = phone;
			xml.message = message;
			xml.serviceID = serviceID;
			
			socket.addEventListener(Event.CONNECT,onConnect);			
			
			socket.connect(SocketProxy.socketIP,SocketProxy.socketPort);
			
			//Security.loadPolicyFile("xmlsocket://" + SocketProxy.socketIP + ":" + 4444);
			
			function onConnect( event:Event ):void 
			{  
				socket.removeEventListener(Event.CONNECT,onConnect);	
								
				socket.addEventListener(ProgressEvent.SOCKET_DATA,onGetData);  
				
				var s:String = xml.toXMLString();
				
				socket.writeUTFBytes(s);
				
				socket.flush();				
				
				trace("Socket连接.");  
			}  
			
			var bytesArray:ByteArray = new ByteArray;	
			
			function onGetData( event:ProgressEvent ):void 
			{  			
				var target:Socket = event.target as Socket;
				
				
				while(target.bytesAvailable)			
				{			
					target.readBytes(bytesArray,bytesArray.length);
					
					//如出现Error: Error #2030: 遇到文件尾错误，请用：str=socket.readUTFBytes(socket.bytesAvailable);
					
				}
				
				var recv:String = bytesArray.readUTFBytes(bytesArray.length);
				
				socket.removeEventListener(ProgressEvent.SOCKET_DATA,onGetData);  
				
				socket.close();
					
				trace(recv);
				
				if(resultHandle != null)
					resultHandle(recv);
			}  
		}
	}
}