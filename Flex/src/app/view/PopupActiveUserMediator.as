package app.view
{
	import flash.events.Event;
	
	import app.AppNotification;
	import app.model.AppConfigProxy;
	import app.model.SocketProxy;
	import app.model.vo.ContactVO;
	import app.view.components.PopupActiveUser;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupActiveUserMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupActiveUserMediator";
		
		public function PopupActiveUserMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupActiveUser.addEventListener(PopupActiveUser.SEND,onSend);
			popupActiveUser.addEventListener(PopupActiveUser.OK,onOK);
		}
		
		protected function get popupActiveUser():PopupActiveUser
		{
			return viewComponent as PopupActiveUser;
		}
		
		private function onOK(even:Event):void
		{
			if(popupActiveUser.verification == popupActiveUser.textVer.text)
			{				
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["ActiveUser",onActiveUserResult,[popupActiveUser.userName],true]);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"验证码错误，请重新输入。");
			}
			
			function onActiveUserResult(result:String):void
			{
				switch(result)
				{
					case "000":
						sendNotification(AppNotification.NOTIFY_POPUP_HIDE);
								
						if(popupActiveUser.panelTitle == PopupActiveUser.ACTIVEUSER)
							sendNotification(AppNotification.NOTIFY_APP_ALERTINFO,"用户激活成功，默认密码为手机号。");
						else
							sendNotification(AppNotification.NOTIFY_APP_ALERTINFO,"用户密码重置成功，默认密码为手机号。");
						break;
				}
			}
		}
		
		private function onSend(event:Event):void
		{
			var socket:SocketProxy = facade.retrieveProxy(SocketProxy.NAME) as SocketProxy;
			socket.sendSMS(SocketProxy.METHOD_SENDVERIFICATION,popupActiveUser.userPhone,"","000",resultHandle);
			
			function resultHandle(verification:String):void
			{
				popupActiveUser.verification = verification;
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
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_POPUP_SHOW:
					if(notification.getBody()[0] == popupActiveUser)
					{						
						var param:Array = notification.getBody()[1];
						popupActiveUser.userName = param[0];
						popupActiveUser.userPhone = param[1];
						popupActiveUser.panelTitle = param[2];
						
						if(popupActiveUser.timer.running)
							popupActiveUser.timer.stop();
												
						popupActiveUser.btnSend.enabled = true;
						popupActiveUser.btnSend.label = "发送激活码";
						
						popupActiveUser.textVer.text = "";		
						
						if(popupActiveUser.panelTitle == PopupActiveUser.ACTIVEUSER)
							popupActiveUser.labelToolTip.text = "用户尚未激活，请点击发送激活码按钮，从手机获得激活码进行激活。";
						else
							popupActiveUser.labelToolTip.text = "请点击发送激活码按钮，从手机获得激活码进行密码重置。";
					}
			}
		}
	}
}