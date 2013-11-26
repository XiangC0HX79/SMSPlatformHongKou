package app.view
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.utils.StringUtil;
	
	import app.AppNotification;
	import app.model.AppConfigProxy;
	import app.model.ContactProxy;
	import app.model.GroupProxy;
	import app.model.OutboxFProxy;
	import app.model.OutboxSProxy;
	import app.model.PhraseProxy;
	import app.model.SMS_DraftProxy;
	import app.model.SocketProxy;
	import app.model.vo.ContactVO;
	import app.model.vo.GroupVO;
	import app.model.vo.SMSVO;
	import app.view.components.PopupSendSMS;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupSendSMSMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSendSMSMediator";
		
		[Embed(source="assets/image/icon_alarm.png")]
		private const ICON_ALERT:Class;
		
		public function PopupSendSMSMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupSendSMS.addEventListener(PopupSendSMS.SENDSMS,onSendSMS);			
						
			popupSendSMS.addEventListener(PopupSendSMS.SAVEDRAFT,onSaveDraft);
			popupSendSMS.addEventListener(PopupSendSMS.SELPHRASE,onSelPhrase);
			popupSendSMS.addEventListener(PopupSendSMS.SAVEPHRASE,onSavePhrase);
			popupSendSMS.addEventListener(PopupSendSMS.SELHOLIDAY,onSelHoliday);
		}
		
		protected function get popupSendSMS():PopupSendSMS
		{
			return viewComponent as PopupSendSMS;
		}
		
		private function onSendSMS(event:Event):void
		{						
			if(popupSendSMS.panelSelectContact.mobs == "")
			{				
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请选择联系人！");
				return ;
			}
			
			if(popupSendSMS.textMsg.text == "")
			{				
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入短信内容！");
				return ;
			}
			
			var sAlert:String = "";
			
			var listNames:Array = popupSendSMS.panelSelectContact.names.split(";");
			var listMobs:Array = popupSendSMS.panelSelectContact.mobs.split(";");
			if(listNames.length > 1)
			{
				var count:Number = Math.min(5,listNames.length - 1);
				
				sAlert = listNames[0];
				
				for(var i:Number = 1;i<count;i++)
				{
					sAlert += "," + listNames[i];
				}
				
				sAlert =  "正准备发送短信给“" + sAlert + "”等" + (listMobs.length - 1).toString() +  "人，是否发送？";
			}
			
			if(sAlert == "")
			{
				if(listMobs.length > 1)
				{
					count = Math.min(5,listMobs.length - 1);
					
					sAlert = listMobs[0];
					
					for(i = 1;i< count;i++)
					{
						sAlert += "," + listMobs[i];
					}
				}
				
				sAlert =  "正准备发送短信给“" + sAlert + "”等" + (listMobs.length - 1).toString() +  "人，是否发送？";
			}
						
			Alert.show(sAlert,"民建信息服务管理平台",Alert.YES | Alert.NO,null,closeHandle,ICON_ALERT);
			
			function closeHandle(event:CloseEvent):void
			{			
				if(event.detail == Alert.YES)
				{
					var user:ContactVO = 
						(facade.retrieveProxy(AppConfigProxy.NAME) as AppConfigProxy).appConfig.user;							
					
					sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"正在发送短信...");
					
					var socketProxy:SocketProxy = facade.retrieveProxy(SocketProxy.NAME) as SocketProxy;
					socketProxy.sendSMS(SocketProxy.METHOD_SENDSMS,popupSendSMS.panelSelectContact.mobs,popupSendSMS.textMsg.text,user.id,resultHandle);
				}
			}
			
			function resultHandle(result:String):void
			{
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
				
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"短信已发送，发送结果请到发件箱查询！");
			}
		}
				
		private function onSaveDraft(event:Event):void
		{			
			if(popupSendSMS.textMsg.text == "")
			{				
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入短信内容！");
				return ;
			}
			
			var sms_draftProxy:SMS_DraftProxy = facade.retrieveProxy(SMS_DraftProxy.NAME) as SMS_DraftProxy;
			sms_draftProxy.save(popupSendSMS.draft);
		}
		
		private function onSelPhrase(event:Event):void
		{
			popupSendSMS.draft.phone = popupSendSMS.panelSelectContact.mobs;
			popupSendSMS.draft.people = popupSendSMS.panelSelectContact.names;
			popupSendSMS.draft.message = StringUtil.trim(popupSendSMS.textMsg.text);
						
			sendNotification(AppNotification.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupPhraseSelMediator.NAME).getViewComponent(),popupSendSMS.draft]);
		}
		
		private function onSelHoliday(event:Event):void
		{
			popupSendSMS.draft.phone = popupSendSMS.panelSelectContact.mobs;
			popupSendSMS.draft.people = popupSendSMS.panelSelectContact.names;
			popupSendSMS.draft.message = StringUtil.trim(popupSendSMS.textMsg.text);
			
			sendNotification(AppNotification.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupSMSHolidaySelMediator.NAME).getViewComponent(),popupSendSMS.draft]);
		}
		
		private function onSavePhrase(event:Event):void
		{
			popupSendSMS.draft.phone = popupSendSMS.panelSelectContact.mobs;
			popupSendSMS.draft.people = popupSendSMS.panelSelectContact.names;
			popupSendSMS.draft.message = StringUtil.trim(popupSendSMS.textMsg.text);
			
			var phraseProxy:PhraseProxy = facade.retrieveProxy(PhraseProxy.NAME) as PhraseProxy;
			phraseProxy.save("1",popupSendSMS.draft.message);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_POPUP_SHOW
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var groupProxy:GroupProxy = facade.retrieveProxy(GroupProxy.NAME) as GroupProxy;	
			var contactProxy:ContactProxy = facade.retrieveProxy(ContactProxy.NAME) as ContactProxy;
			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_POPUP_SHOW:
					var params:Array = notification.getBody() as Array;
					if(params[0] == popupSendSMS)
					{
						//popupSendSMS.draft = (params[2] != null)?params[2]:(new SMSVO);
						
						//popupSendSMS.panelSelectContact.setListContact(initTree(params[1]));
						
						popupSendSMS.draft = params[1];
						
						popupSendSMS.panelSelectContact.setListContact(groupProxy.list,contactProxy.listAll,popupSendSMS.draft.phone);	
					}
					break;
			}
		}
	}
}