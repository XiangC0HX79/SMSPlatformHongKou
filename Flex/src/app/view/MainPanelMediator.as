package app.view
{
	import app.AppNotification;
	import app.view.components.LeftPanel;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Group;
	
	public class MainPanelMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "MainPanelMediator";
		
		public function MainPanelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		protected function get mainPanel():Group
		{
			return viewComponent as Group;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_SUBPANEL
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
					mainPanel.addElement(facade.retrieveMediator(SubPanelContactMediator.NAME).getViewComponent() as Group);
					break;
				
				case AppNotification.NOTIFY_SUBPANEL:
					mainPanel.removeAllElements();
					mainPanel.addElement(notification.getBody() as Group);
					break;
			}
		}
	}
}