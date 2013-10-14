package app.view
{
	import app.AppNotification;
	import app.model.ContactProxy;
	import app.model.GroupProxy;
	import app.model.vo.ContactVO;
	import app.model.vo.GroupVO;
	import app.view.components.PopupSendFax;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupSendFaxMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSendFaxMediator";
		
		public function PopupSendFaxMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		private function get popupSendFax():PopupSendFax
		{
			return viewComponent as PopupSendFax;
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
					if(params[0] == popupSendFax)
					{
						popupSendFax.panelSelectContact.setListContact(groupProxy.list,contactProxy.listAll,"");	
					}
					break;
			}
		}
	}
}