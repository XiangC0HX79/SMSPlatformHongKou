package app.model
{
	import app.AppNotification;
	import app.controller.WebServiceCommand;
	import app.model.vo.MMSParVO;
	import app.model.vo.MMSVO;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class MMSProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "MMSProxy";
		
		public function MMSProxy()
		{
			super(NAME, new ArrayCollection);
		}
		
		public function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		public function send(mms:MMSVO):void
		{			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["SetMMS",onResult
					,[mms.phone,mms.name,"发送",mms.people],true]);
			
			var numComplete:Number = 0;
			
			function onResult(result:String):void
			{
				mms.ID = result;
				
				var mmsPar:MMSParVO = mms.pares[numComplete];
				
				var url:String =  WebServiceCommand.WSDL + "TextFileService.aspx";				
				url += "?id=" + mms.ID;
				url += "&index=" + numComplete.toString();
				url += "&dur=" + mmsPar.dur.toString();
				
				var request:URLRequest = new URLRequest(url);					
				request.method = URLRequestMethod.POST;
				request.contentType = "text/plain";	
				request.data = encodeURIComponent(mmsPar.text);
				
				var urlLoader:URLLoader = new URLLoader();		
				urlLoader.addEventListener(Event.COMPLETE, onUploadText);
				urlLoader.load(request);
			}
			
			function onUploadText(event:Event):void
			{
				var mmsPar:MMSParVO = mms.pares[numComplete];
				
				if(mmsPar.data != null)
				{
					var url:String =  WebServiceCommand.WSDL + "FileService.aspx";
					url += "?id=" + mms.ID;
					url += "&index=" + numComplete.toString();
					url += "&dur=" + mmsPar.dur.toString();
					url += "&imgName=" + mmsPar.imgName;	
					
					var request:URLRequest = new URLRequest(url);	
					request.method = URLRequestMethod.POST;
					request.contentType = "application/octet-stream";		
					request.data = mmsPar.data;	
					
					var urlLoader:URLLoader = new URLLoader();	
					urlLoader.addEventListener(Event.COMPLETE, onUploadImage);
					urlLoader.load(request);
				}
				else
				{
					onUploadImage(null);
				}
			}
			
			function onUploadImage(event:Event):void
			{
				numComplete ++;
				
				if(numComplete == mms.pares.length)
				{					
					sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
						["SaveMMS",onSaveResult
							,[mms.ID],true]);
				}
				else
				{
					var mmsPar:MMSParVO = mms.pares[numComplete];
					
					var url:String =  WebServiceCommand.WSDL + "TextFileService.aspx";				
					url += "?id=" + mms.ID;
					url += "&index=" + numComplete.toString();
					url += "&dur=" + mmsPar.dur.toString();
					
					var request:URLRequest = new URLRequest(url);					
					request.method = URLRequestMethod.POST;
					request.contentType = "text/plain";	
					request.data = encodeURIComponent(mmsPar.text);
					
					var urlLoader:URLLoader = new URLLoader();		
					urlLoader.addEventListener(Event.COMPLETE, onUploadText);
					urlLoader.load(request);
				}
			}
			
			function onSaveResult(result:String):void
			{				
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["SendMMS",onSendResult
						,[mms.ID],true]);
			}
			
			function onSendResult(result:String):void
			{				
				if(result == "0100")
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"彩信包过大，请减少图片或者文字数量！");
				}
				else if(result != "0000")
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"彩信发送失败！");
				}
				else
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTINFO,"彩信发送成功！");
				}
			}
		}
		
		public function save(mms:MMSVO):void
		{			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["SetMMS",onResult
					,[mms.phone,mms.name,"草稿",mms.people],true]);
			
			var numComplete:Number = 0;
			
			function onResult(result:String):void
			{
				mms.ID = result;
				
				var mmsPar:MMSParVO = mms.pares[numComplete];
				
				var url:String =  WebServiceCommand.WSDL + "TextFileService.aspx";				
				url += "?id=" + mms.ID;
				url += "&index=" + numComplete.toString();
				url += "&dur=" + mmsPar.dur.toString();
				
				var request:URLRequest = new URLRequest(url);					
				request.method = URLRequestMethod.POST;
				request.contentType = "text/plain";	
				request.data = encodeURIComponent(mmsPar.text);
				
				var urlLoader:URLLoader = new URLLoader();		
				urlLoader.addEventListener(Event.COMPLETE, onUploadText);
				urlLoader.load(request);
			}
						
			function onUploadText(event:Event):void
			{
				var mmsPar:MMSParVO = mms.pares[numComplete];
				
				if(mmsPar.data != null)
				{
					var url:String =  WebServiceCommand.WSDL + "FileService.aspx";
					url += "?id=" + mms.ID;
					url += "&index=" + numComplete.toString();
					url += "&dur=" + mmsPar.dur.toString();
					url += "&imgName=" + mmsPar.imgName;	
					
					var request:URLRequest = new URLRequest(url);	
					request.method = URLRequestMethod.POST;
					request.contentType = "application/octet-stream";		
					request.data = mmsPar.data;	
					
					var urlLoader:URLLoader = new URLLoader();	
					urlLoader.addEventListener(Event.COMPLETE, onUploadImage);
					urlLoader.load(request);
				}
				else
				{
					onUploadImage(null);
				}
			}
			
			function onUploadImage(event:Event):void
			{
				numComplete ++;
				
				if(numComplete == mms.pares.length)
				{					
					/*sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["SaveMMS",onSaveResult
					,[mms.ID],true]);*/
				}
				else
				{
					var mmsPar:MMSParVO = mms.pares[numComplete];
					
					var url:String =  WebServiceCommand.WSDL + "TextFileService.aspx";				
					url += "?id=" + mms.ID;
					url += "&index=" + numComplete.toString();
					url += "&dur=" + mmsPar.dur.toString();
					
					var request:URLRequest = new URLRequest(url);					
					request.method = URLRequestMethod.POST;
					request.contentType = "text/plain";	
					request.data = encodeURIComponent(mmsPar.text);
					
					var urlLoader:URLLoader = new URLLoader();		
					urlLoader.addEventListener(Event.COMPLETE, onUploadText);
					urlLoader.load(request);
				}
			}
		}
		
		public function getList(type:String):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["GetMMS",onResult
					,[type],true]);
			
			function onResult(result:ArrayCollection):void
			{
				var filterFunction:Function = list.filterFunction;
				
				list.filterFunction = null;
				list.refresh();
				
				list.removeAll();
				
				for each(var row:Object in result)
				{
					var mms:MMSVO = new MMSVO;
					mms.ID = row.ID;
					mms.phone = row.手机号码;
					mms.name = row.标题;
					mms.date = row.时间;
					mms.people = row.姓名;
					
					list.addItem(mms);
				}
				
				list.filterFunction = filterFunction;
				list.refresh();
			}
		}
		
		public function getMMS(mms:MMSVO):void
		{					
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["GetMMSFile",onResult,[mms.ID],true]);
			
			function onResult(result:String):void
			{
				sendNotification(AppNotification.NOTIFY_MMS_FILE,XML(result));
			}
		}
		
		public function deleteMMS(mmses:Array,type:String):void
		{					
			var IDs:String = "";
			
			for each(var sms:MMSVO in mmses)
			{
				IDs += sms.ID + ";"
			}
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["DeleteMMS",onResult
					,[IDs],true]);
			
			function onResult(result:String):void
			{
				getList(type);
			}
		}
	}
}