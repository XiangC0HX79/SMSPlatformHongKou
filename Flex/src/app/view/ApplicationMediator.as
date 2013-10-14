package app.view
{	
	import app.AppNotification;
	import app.view.components.PopupActiveUser;
	import app.view.components.PopupNewContact;
	import app.view.components.PopupNewGroup;
	import app.view.components.PopupNewTask;
	import app.view.components.PopupPhoneQuery;
	import app.view.components.PopupPhraseSel;
	import app.view.components.PopupSMSBirthday;
	import app.view.components.PopupSMSDict;
	import app.view.components.PopupSMSHoliday;
	import app.view.components.PopupSMSHolidaySel;
	import app.view.components.PopupSMSPerson;
	import app.view.components.PopupSendFax;
	import app.view.components.PopupSendMMS;
	import app.view.components.PopupSendMail;
	import app.view.components.PopupSendSMS;
	import app.view.components.PopupSystemPassword;
	import app.view.components.PopupSystemSetting;
	import app.view.components.SubPanelContact;
	import app.view.components.SubPanelDraft;
	import app.view.components.SubPanelInbox;
	import app.view.components.SubPanelMMSDraft;
	import app.view.components.SubPanelMMSSend;
	import app.view.components.SubPanelSMSSend;
	import app.view.components.SubPanelTask;
	import app.view.components.subComponents.BasePopupPanel;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	
	import mx.controls.ToolTip;
	import mx.events.ResizeEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
		
	public class ApplicationMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ApplicationMediator";
		
		public function ApplicationMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			facade.registerMediator(new AppLoadingBarMediator(application.appLoadingBar));
			
			facade.registerMediator(new LoginMediator(application.login));
			facade.registerMediator(new PopupManagerMediator(application.popupManager));
			
			facade.registerMediator(new MainPanelMediator(application.mainPanel));
			
			facade.registerMediator(new MenuMediator(application.menu));
			facade.registerMediator(new LeftPanelMediator(application.leftPanel));
			
			facade.registerMediator(new SubPanelContactMediator(new SubPanelContact));
			facade.registerMediator(new SubPanelTaskMediator(new SubPanelTask));
			facade.registerMediator(new SubPanelDraftMediator(new SubPanelDraft));
			facade.registerMediator(new SubPanelInboxMediator(new SubPanelInbox));
			facade.registerMediator(new SubPanelSMSSendFailMediator(new SubPanelSMSSend));
			facade.registerMediator(new SubPanelSMSSendSuccessMediator(new SubPanelSMSSend));
			facade.registerMediator(new SubPanelMMSDraftMediator(new SubPanelMMSDraft));
			facade.registerMediator(new SubPanelMMSSendMediator(new SubPanelMMSSend));
			
			facade.registerMediator(new PopupActiveUserMediator(new PopupActiveUser));
			facade.registerMediator(new PopupNewGroupMediator(new PopupNewGroup));
			facade.registerMediator(new PopupNewContactMediator(new PopupNewContact));
			facade.registerMediator(new PopupSendSMSMediator(new PopupSendSMS));
			facade.registerMediator(new PopupSendMMSMediator(new PopupSendMMS));
			facade.registerMediator(new PopupNewTaskMediator(new PopupNewTask));
			facade.registerMediator(new PopupSMSDictMediator(new PopupSMSDict));
			facade.registerMediator(new PopupPhraseSelMediator(new PopupPhraseSel));
			facade.registerMediator(new PopupSMSPersonMediator(new PopupSMSPerson));
			facade.registerMediator(new PopupSMSHolidayMediator(new PopupSMSHoliday));
			facade.registerMediator(new PopupSMSHolidaySelMediator(new PopupSMSHolidaySel));
			facade.registerMediator(new PopupSMSBirthdayMediator(new PopupSMSBirthday));
			facade.registerMediator(new PopupSendMailMediator(new PopupSendMail));
			facade.registerMediator(new PopupSendFaxMediator(new PopupSendFax));
			facade.registerMediator(new PopupPhoneQueryMediator(new PopupPhoneQuery));
			facade.registerMediator(new PopupSystemSettingMediator(new PopupSystemSetting));
			facade.registerMediator(new PopupSystemPasswordMediator(new PopupSystemPassword));
						
			application.addEventListener(BasePopupPanel.SUBPANEL_CLOSED,onPopupClosed);
			
			application.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			
			application.addEventListener(ResizeEvent.RESIZE,onApplicationResize);
		}
		
		protected function get application():Main
		{
			return viewComponent as Main;
		}		
		
		
		protected function onMouseMove(event:MouseEvent):void
		{
			if(event.stageY > application.menu.height)
			{
				sendNotification(AppNotification.NOTIFY_MENU_SUBHIDE);
			}
		}
		
		private function onPopupClosed(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_POPUP_HIDE);
		}
		
		private function onApplicationResize(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_APP_RESIZE,[application.width,application.height]);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_SYS_SETTING
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_SYS_SETTING:
					var fontFamily:String = notification.getBody()[0];
					var fontSize:Number = notification.getBody()[1];
					
					application.setStyle("fontFamily",fontFamily);
					application.setStyle("fontSize",fontSize);
					
					application.styleManager.getStyleDeclaration("mx.controls.ToolTip").setStyle("fontFamily",fontFamily);
					application.styleManager.getStyleDeclaration("mx.controls.ToolTip").setStyle("fontSize",fontSize);
					
					application.styleManager.getStyleDeclaration("mx.controls.Alert").setStyle("fontFamily",fontFamily);
					application.styleManager.getStyleDeclaration("mx.controls.Alert").setStyle("fontSize",fontSize);
					
					application.styleManager.getStyleDeclaration("mx.controls.Tree").setStyle("fontFamily",fontFamily);
					application.styleManager.getStyleDeclaration("mx.controls.Tree").setStyle("fontSize",fontSize);
					break;
			}
		}
	}
}