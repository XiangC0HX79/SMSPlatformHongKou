package app.view
{
	import app.AppNotification;
	import app.model.AppConfigProxy;
	import app.model.vo.AppConfigVO;
	import app.view.components.PopupSystemSetting;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupSystemSettingMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSystemSettingMediator";
		
		[Embed(source="assets/image/icon_error.png")]
		private const ICON_ERROR:Class;
		
		public function PopupSystemSettingMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupSystemSetting.addEventListener(PopupSystemSetting.OK,onOK);
		}
		
		private function get popupSystemSetting():PopupSystemSetting
		{
			return viewComponent as PopupSystemSetting;
		}
		
		private function onOK(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_SYS_SETTING,[
				popupSystemSetting.fontFamily.selectedItem
				,popupSystemSetting.fontSize.selectedItem
					]);
			
			var mailAddr:String = StringUtil.trim(popupSystemSetting.textMailAddr.text);
			var mailPws:String = StringUtil.trim(popupSystemSetting.textMailPws.text);
			var platPws:String = StringUtil.trim(popupSystemSetting.textPlatformPws.text);
			
			if((mailAddr != "") && (mailPws != "") && (platPws != ""))
			{
				var appConfig:AppConfigVO = (facade.retrieveProxy(AppConfigProxy.NAME) as AppConfigProxy).appConfig;
				appConfig.mailAddr = mailAddr;
				appConfig.mailPws = mailPws;
				
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["SetSysParam",onResultNull,["邮箱地址",mailAddr],false]);
				
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["SetSysParam",onResultNull,["邮箱密码",mailPws],false]);
				
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["SetSysParam",onResult,["平台密码",platPws],false]);
			}
			
			function onResultNull(result:String):void
			{
				
			}
			
			function onResult(result:String):void
			{
				var appConfig:AppConfigVO = (facade.retrieveProxy(AppConfigProxy.NAME) as AppConfigProxy).appConfig;
				if(platPws != appConfig.platPws)
				{
					appConfig.platPws = platPws;
					
					sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
						["StartListen",onStartListen,[],true]);
				}
			}
			
			function onStartListen(result:String):void
			{
				Alert.show("短信服务器密码已重置，请点击确定重新登录系统连接服务器！","民建信息服务管理平台",4,null,closeHandle,ICON_ERROR);
			}
			
			function closeHandle(event:CloseEvent):void
			{		
				flash.net.navigateToURL(new URLRequest("javascript:location.reload();"),"_self");
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
					var params:Array = notification.getBody() as Array;
					if(params[0] == popupSystemSetting)
					{
						var appConfig:AppConfigVO = (facade.retrieveProxy(AppConfigProxy.NAME) as AppConfigProxy).appConfig;
						popupSystemSetting.textMailAddr.text = appConfig.mailAddr;
						popupSystemSetting.textMailPws.text = appConfig.mailPws;
						popupSystemSetting.textPlatformPws.text = appConfig.platPws;
					}
					break;
			}
		}
	}
		
}