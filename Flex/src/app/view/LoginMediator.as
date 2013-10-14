package app.view
{
	import app.AppNotification;
	import app.model.AppConfigProxy;
	import app.model.SocketProxy;
	import app.model.vo.ContactVO;
	import app.view.components.Login;
	import app.view.components.Menu;
	import app.view.components.PopupActiveUser;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LoginMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LoginMediator";
		
		public function LoginMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			login.addEventListener(Login.SUBMIT,onSubmit);
			login.addEventListener(Login.PASSWORD,onPassWord);
			login.addEventListener(Login.EXIT,onExit);
		}
		
		protected function get login():Login
		{
			return viewComponent as Login;
		}
		
		private function onSubmit(event:Event):void
		{
			var userName:String = StringUtil.trim(login.textUserName.text);
			
			if(userName != "")
			{
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
						["Login",onLoginResult,[userName,login.textUserPassword.text],true]);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入用户名。");
			}
			
			function onLoginResult(result:String):void
			{
				var arr:Array = result.split("|");
				switch(arr[0])
				{					
					case "000":
						var user:ContactVO = 
							(facade.retrieveProxy(AppConfigProxy.NAME) as AppConfigProxy).appConfig.user;
						
						user.name = login.textUserName.text;
						user.phone = arr[1];
						user.mail = arr[2];
						user.id = arr[3];
												
						var socket:SocketProxy = facade.retrieveProxy(SocketProxy.NAME) as SocketProxy;
						socket.sendSMS(SocketProxy.METHOD_LOGIN,user.phone,"","000");
						
						login.visible = false;
						
						sendNotification(AppNotification.NOTIFY_INIT_AUTH,user.phone);
						break;
					
					//用户不存在
					case "001":
						sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"用户不存在，请输入手机号。");
						break;
					
					//用户未激活
					case "002":
						sendNotification(AppNotification.NOTIFY_POPUP_SHOW
							,[facade.retrieveMediator(PopupActiveUserMediator.NAME).getViewComponent(),[userName,arr[1],PopupActiveUser.ACTIVEUSER]]);
						break;
					
					//密码不正确
					case "003":
						sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"用户密码不正确，请重新输入密码。");
						break;
				}
			}
		}
		
		private function onPassWord(event:Event):void
		{
			var userName:String = StringUtil.trim(login.textUserName.text);
			if(userName != "")
			{
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["Login",onLoginResult,[userName,login.textUserPassword.text],true]);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入用户名。");
			}
			
			function onLoginResult(result:String):void
			{
				var arr:Array = result.split("|");
				switch(arr[0])
				{								
					//用户不存在
					case "001":
						sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"用户不存在，请输入手机号。");
						break;
					
					//重置密码
					default:
						sendNotification(AppNotification.NOTIFY_POPUP_SHOW
							,[facade.retrieveMediator(PopupActiveUserMediator.NAME).getViewComponent(),[userName,arr[1],PopupActiveUser.RESETPW]]);
						break;
				}
			}
		}
		
		private function onExit(event:Event):void
		{
			flash.net.navigateToURL(new URLRequest("javascript:window.opener=null;window.open('','_top');window.top.close()"),"_self");
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_MENU,
				AppNotification.NOTIFY_APP_RESIZE
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_MENU:
					if(notification.getType() == Menu.MENU_EXIT)
					{
						login.visible = true;
					}
					break;
				
				case AppNotification.NOTIFY_APP_RESIZE:
					login.width = notification.getBody()[0];
					login.height = notification.getBody()[1];
					
					login.refreshBack();
					break;
			}
		}
	}
}