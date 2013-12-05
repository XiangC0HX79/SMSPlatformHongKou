package app.view
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import app.AppNotification;
	import app.ApplicationFacade;
	import app.controller.WebServiceCommand;
	import app.model.AppConfigProxy;
	import app.model.vo.AppConfigVO;
	import app.model.vo.MMSVO;
	import app.model.vo.SMSVO;
	import app.view.components.Menu;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class MenuMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "MenuMediator";
		
		public function MenuMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			menu.addEventListener(Menu.MENU,onMenu);
		}
		
		protected function get menu():Menu
		{
			return viewComponent as Menu;
		}
		
		private function onMenu(event:Event):void
		{
			var appConfig:AppConfigVO = (facade.retrieveProxy(AppConfigProxy.NAME) as AppConfigProxy).appConfig;
			
			sendNotification(AppNotification.NOTIFY_MENU,null,menu.menu);
			
			switch(menu.menu)
			{
				case Menu.MENU_TASK_NEW:
					sendNotification(AppNotification.NOTIFY_POPUP_SHOW
						,[facade.retrieveMediator(PopupNewTaskMediator.NAME).getViewComponent()]);
					break;
				
				case Menu.MENU_TASK_LIST:
					sendNotification(AppNotification.NOTIFY_SUBPANEL
						,facade.retrieveMediator(SubPanelTaskMediator.NAME).getViewComponent());
					break;
				
				case Menu.MENU_SMS_SEND:
					sendNotification(AppNotification.NOTIFY_POPUP_SHOW
						,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),new SMSVO]);
					break;
				
				case Menu.MENU_SMS_DRAFT:
					sendNotification(AppNotification.NOTIFY_SUBPANEL
						,facade.retrieveMediator(SubPanelDraftMediator.NAME).getViewComponent());
					break;
				
				case Menu.MENU_SMS_RECEIVE:
					sendNotification(AppNotification.NOTIFY_SUBPANEL
						,facade.retrieveMediator(SubPanelInboxMediator.NAME).getViewComponent());
					break;
				
				case Menu.MENU_SMS_SENDFAIL:
					sendNotification(AppNotification.NOTIFY_SUBPANEL
						,facade.retrieveMediator(SubPanelSMSSendFailMediator.NAME).getViewComponent());
					break;
				
				case Menu.MENU_SMS_SENDSUCCESS:
					sendNotification(AppNotification.NOTIFY_SUBPANEL
						,facade.retrieveMediator(SubPanelSMSSendSuccessMediator.NAME).getViewComponent());
					break;
				
				case Menu.MENU_SMS_DICT:
					sendNotification(AppNotification.NOTIFY_POPUP_SHOW
						,[facade.retrieveMediator(PopupSMSDictMediator.NAME).getViewComponent()]);
					break;
				
				case Menu.MENU_SMS_CUSTOM:
					sendNotification(AppNotification.NOTIFY_POPUP_SHOW
						,[facade.retrieveMediator(PopupSMSPersonMediator.NAME).getViewComponent()]);
					break;
				
				case Menu.MENU_SMS_HOLIDAY:
					sendNotification(AppNotification.NOTIFY_POPUP_SHOW
						,[facade.retrieveMediator(PopupSMSHolidayMediator.NAME).getViewComponent()]);
					break;
				
				case Menu.MENU_SMS_BIRTHDAY:
					sendNotification(AppNotification.NOTIFY_POPUP_SHOW
						,[facade.retrieveMediator(PopupSMSBirthdayMediator.NAME).getViewComponent()]);
					break;
								
				case Menu.MENU_MMS_DRAFT:
					sendNotification(AppNotification.NOTIFY_SUBPANEL
						,facade.retrieveMediator(SubPanelMMSDraftMediator.NAME).getViewComponent());
					break;
				
				case Menu.MENU_MMS_SEND:
					sendNotification(AppNotification.NOTIFY_POPUP_SHOW
						,[facade.retrieveMediator(PopupSendMMSMediator.NAME).getViewComponent(),new MMSVO]);
					break;
				
				case Menu.MENU_MMS_SENDSUCCESS:
					sendNotification(AppNotification.NOTIFY_SUBPANEL
						,facade.retrieveMediator(SubPanelMMSSendMediator.NAME).getViewComponent()
						,Menu.MENU_MMS_SENDSUCCESS);
					break;
				
				case Menu.MENU_MMS_SENDFAILED:
					sendNotification(AppNotification.NOTIFY_SUBPANEL
						,facade.retrieveMediator(SubPanelMMSSendMediator.NAME).getViewComponent()
						,Menu.MENU_MMS_SENDFAILED);
					break;
				
				case Menu.MENU_MAIL:
					if(appConfig.mailAddr == "")
					{
						sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请先到系统设置里面设置好正确的邮箱地址和邮箱密码。");
					}
					else
					{
						sendNotification(AppNotification.NOTIFY_POPUP_SHOW
							,[facade.retrieveMediator(PopupSendMailMediator.NAME).getViewComponent()]);
					}
					break;
				
				case Menu.MENU_FAX:
					sendNotification(AppNotification.NOTIFY_POPUP_SHOW
						,[facade.retrieveMediator(PopupSendFaxMediator.NAME).getViewComponent()]);
					break;
				
				case Menu.MENU_FUN_PHONE:
					sendNotification(AppNotification.NOTIFY_POPUP_SHOW
						,[facade.retrieveMediator(PopupPhoneQueryMediator.NAME).getViewComponent()]);
					break;
				
				case Menu.MENU_SYS_SETTING:
					sendNotification(AppNotification.NOTIFY_POPUP_SHOW
						,[facade.retrieveMediator(PopupSystemSettingMediator.NAME).getViewComponent()]);
					break;
				
				case Menu.MENU_SYS_PASSWORD:
					sendNotification(AppNotification.NOTIFY_POPUP_SHOW
						,[facade.retrieveMediator(PopupSystemPasswordMediator.NAME).getViewComponent()]);
					break;
				
				case Menu.MENU_SYS_UPDATE:
					//update();
					update2();
					//update3();
					break;
			}
		}
		
		private var pageIndex:Number = 0;
		private function update3():void
		{
			var fileRef:FileReference = new FileReference;
			fileRef.addEventListener(Event.SELECT,onFileSelect);	
			fileRef.addEventListener(Event.COMPLETE,onFileLoad); 
			
			fileRef.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			
			fileRef.browse();
			
			var pageLength:Number = 4096;
			var pageNumber:Number;
			
			var requestData:ByteArray;
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onUpload);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			
			function upload(len:Number):void
			{
				trace((new Date).toLocaleTimeString() + " " + pageIndex + "/" + pageNumber + " File Size:" + len + " Upload Size:" + pageIndex * pageLength);	
				
				var pageLen:Number = (pageIndex < pageNumber - 1)?pageLength:(requestData.length - (pageNumber - 1) * pageLength);
				var data:ByteArray = new ByteArray;		
				data.writeBytes(requestData,pageIndex * pageLength,pageLen);
									
				var id:String = (pageIndex % 8).toString();
				var url:String =  WebServiceCommand.WSDL + "Mail/Upload" + id + ".aspx";
				url += "?fileName=" + fileRef.name;	
				url += "&pageIndex=" + pageIndex;	
				url += "&pageLen=" + pageLen;	
				
				var request:URLRequest = new URLRequest(encodeURI(url));	
				request.method = URLRequestMethod.POST;
				request.contentType = "application/octet-stream";		
				request.data = data;	
				
				urlLoader.load(request);
			}
			
			function onFileSelect(event:Event):void
			{					
				sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"正在上传文件...");
				
				fileRef.load(); 
			}
			
			function onFileLoad(event:Event):void   
			{   		
				requestData = event.currentTarget.data as ByteArray;
							
				pageNumber = Math.ceil(requestData.length / pageLength);	
				
				//pageIndex = 0;
				
				upload(0);
			}
			
			function onUpload(event:Event):void
			{	
				var len:Number = Number(event.target.data);
				
				if(isNaN(len))
				{
					trace(String(event.target.data));
				}
				else
				{				
					pageIndex ++;
				}
						
				
				if(pageIndex == pageNumber)
					sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);	
				else
				{					
					upload(len);
				}
			}
			
			function onIOError(event:IOErrorEvent):void
			{
				//sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);	
				
				trace("onIOError");
								
				upload(pageIndex * pageLength);
				
			}	
		}
		
		private function update2():void
		{			
			var fileRef:FileReference = new FileReference;
			fileRef.addEventListener(Event.SELECT,onFileSelect);	
			fileRef.addEventListener(Event.COMPLETE,onFileCom); 
			fileRef.addEventListener(ProgressEvent.PROGRESS,onProgress);
			
			fileRef.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
						
			fileRef.browse();
			
			function onFileSelect(event:Event):void
			{					
				var request:URLRequest = new URLRequest();
				request.url= WebServiceCommand.WSDL + "MailService.aspx";
				
				fileRef.upload(request);
			}
			
			function onFileCom(event:Event):void   
			{   		
				trace("onFileCom");
			}
			
			function onProgress(event:ProgressEvent):void
			{
				trace(event.bytesLoaded + "/" + event.bytesTotal);
			}
			
			function onIOError(event:IOErrorEvent):void
			{
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);		
				
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"文件传输失败。");	
			}	
		}
		
		private function update():void
		{			
			var fileRef:FileReference = new FileReference;
			fileRef.addEventListener(Event.SELECT,onFileSelect);	
			fileRef.addEventListener(Event.COMPLETE,onFileLoad); 
			
			fileRef.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			
			fileRef.browse();
			
			function onFileSelect(event:Event):void
			{						
				fileRef.load(); 
			}
			
			function onFileLoad(event:Event):void   
			{   		
				sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"正在更新系统...");
				
				var request:URLRequest = new URLRequest(encodeURI(WebServiceCommand.WSDL + "Update.aspx"));	
				request.method = URLRequestMethod.POST;
				request.contentType = "application/octet-stream";		
				request.data = event.currentTarget.data;	
				
				var urlLoader:URLLoader = new URLLoader();	
				urlLoader.addEventListener(Event.COMPLETE, onUpload);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
				urlLoader.load(request);
			}
			
			function onUpload(event:Event):void
			{	
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);	
				
				if(event.currentTarget.data != "000")
					sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,event.currentTarget.data);						
			}
			
			function onIOError(event:IOErrorEvent):void
			{
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);		
				
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"文件传输失败。");	
			}	
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_INIT_AUTH,
				AppNotification.NOTIFY_MENU_SUBHIDE
				
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_INIT_AUTH:
					var phone:String = notification.getBody() as String;
					menu.currentState = (phone == "15921065956")?"manager":"normal";						
					break;
				
				case AppNotification.NOTIFY_MENU_SUBHIDE:
					menu.view.visible = false;
					break;
			}
		}
	}
}