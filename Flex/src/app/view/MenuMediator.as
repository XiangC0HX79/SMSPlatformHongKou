package app.view
{
	import app.AppNotification;
	import app.model.AppConfigProxy;
	import app.model.vo.AppConfigVO;
	import app.model.vo.MMSVO;
	import app.model.vo.SMSVO;
	import app.view.components.Menu;
	
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
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
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_MENU_SUBHIDE
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_MENU_SUBHIDE:
					menu.view.visible = false;
					break;
			}
		}
	}
}