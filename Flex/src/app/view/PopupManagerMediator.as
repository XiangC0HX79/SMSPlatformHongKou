package app.view
{
	import app.AppNotification;
	import app.view.components.PopupManager;
	import app.view.components.subComponents.BasePopupPanel;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupManagerMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupManagerMediator";
		
		public function PopupManagerMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		protected function get popupManager():PopupManager
		{
			return viewComponent as PopupManager;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_POPUP_SHOW,
				AppNotification.NOTIFY_POPUP_HIDE
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_POPUP_SHOW:
					popupManager.content.removeAllElements();
					popupManager.content.addElement(notification.getBody()[0] as BasePopupPanel);
					popupManager.visible = true;
					break;
				
				case AppNotification.NOTIFY_POPUP_HIDE:
					popupManager.visible = false;
					break;
			}
		}
	}
}