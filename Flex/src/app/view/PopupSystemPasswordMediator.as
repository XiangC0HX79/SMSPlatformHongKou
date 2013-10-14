package app.view
{
	import app.AppNotification;
	import app.model.AppConfigProxy;
	import app.model.vo.AppConfigVO;
	import app.view.components.PopupSystemPassword;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupSystemPasswordMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSystemPasswordMediator";
		
		public function PopupSystemPasswordMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupSystemPassword.addEventListener(PopupSystemPassword.OK,onOK);
		}
		
		private function get popupSystemPassword():PopupSystemPassword
		{
			return viewComponent as PopupSystemPassword;
		}
		
		private function onOK(event:Event):void
		{
			if(popupSystemPassword.oldPws.text == "")
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入原始密码。");
				return ;
			}
			
			if(popupSystemPassword.newPws.text == "")
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入新密码。");
				return ;
			}
						
			if(popupSystemPassword.newPws.text != popupSystemPassword.conPws.text)
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"新密码和确认密码不一致。");
				return ;
			}
			
			var appConfig:AppConfigVO = (facade.retrieveProxy(AppConfigProxy.NAME) as AppConfigProxy).appConfig;
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["SetPassword",onResult,
					[
						appConfig.user.name
						,popupSystemPassword.oldPws.text
						,popupSystemPassword.newPws.text
					],true]);
			
			function onResult(result:String):void
			{
				switch(result)
				{									
					//密码不正确
					case "003":
						sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"原始密码不正确，请重新输入原始密码。");
						break;
					
					case "000":
						sendNotification(AppNotification.NOTIFY_APP_ALERTINFO,"修改密码成功。");
						break;
				}
			}
		}
	}
}