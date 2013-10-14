package app.view
{
	import app.AppNotification;
	import app.model.AppConfigProxy;
	import app.model.ContactProxy;
	import app.model.GroupProxy;
	import app.model.vo.AppConfigVO;
	import app.model.vo.ContactVO;
	import app.model.vo.GroupVO;
	import app.view.components.PopupSendMail;
	
	import flash.events.Event;
	
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupSendMailMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSendMailMediator";
		
		public function PopupSendMailMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupSendMail.addEventListener(PopupSendMail.SEND,onSend);
		}
		
		private function get popupSendMail():PopupSendMail
		{
			return viewComponent as PopupSendMail
		}
		
		private function onSend(event:Event):void
		{			
			var mailTitle:String = StringUtil.trim(popupSendMail.textTitle.text);
			var mailMail:String = StringUtil.trim(popupSendMail.textMsg.text);
			
			if(mailTitle == "")
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入邮件标题。");
				return;
			}
			
			if(mailMail == "")
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入邮件正文。");
				return;
			}
			
			var appConfig:AppConfigVO = (facade.retrieveProxy(AppConfigProxy.NAME) as AppConfigProxy).appConfig;
			//SendMail(String fromName,String fromMail,String fromPassword,String toMail,String mailTitle,String mailMain)
			
			var toMail:String = popupSendMail.panelSelectContact.mails;
			if(toMail == "")
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请选择邮件发送会员。");
				return;
			}
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["SendMail",onSendMailResult,[
					"民建虹口区委",
					appConfig.mailAddr,
					appConfig.mailPws,
					toMail,
					mailTitle,
					mailMail
				],true]);
			
			function onSendMailResult(result:String):void
			{
				switch(result)
				{
					case "000":
						sendNotification(AppNotification.NOTIFY_APP_ALERTINFO,"邮件发送成功。");
						break;
				}
			}
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
					if(params[0] == popupSendMail)
					{
						popupSendMail.panelSelectContact.setListContact(groupProxy.list,contactProxy.listAll,"");
						
						popupSendMail.listAttach.removeAll();
						
						popupSendMail.listAttach.addItem("");
						
						sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
							["SetMail",onSetMailResult,[],true]);
					}
					break;
			}
			
			function onSetMailResult(result:String):void
			{
				
			}
		}
	}
}