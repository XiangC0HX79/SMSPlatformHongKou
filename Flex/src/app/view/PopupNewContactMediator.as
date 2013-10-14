package app.view
{
	import app.AppNotification;
	import app.model.ContactProxy;
	import app.model.GroupProxy;
	import app.model.vo.ContactVO;
	import app.model.vo.GroupVO;
	import app.view.components.PopupNewContact;
	import app.view.components.subComponents.BasePopupPanel;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Group;
	
	public class PopupNewContactMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupNewContactMediator";
		
		public function PopupNewContactMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
						
			popupNewContact.listGroup = (facade.retrieveProxy(GroupProxy.NAME) as GroupProxy).list;
			
			popupNewContact.addEventListener(PopupNewContact.OK,onConfirm);
		}
		
		protected function get popupNewContact():PopupNewContact
		{
			return viewComponent as PopupNewContact;
		}
		
		private function onConfirm(event:Event):void
		{
			if(popupNewContact.textPhone.text != "")
			{			
				(facade.retrieveProxy(ContactProxy.NAME) as ContactProxy).save(popupNewContact.contact);
				
				sendNotification(AppNotification.NOTIFY_POPUP_HIDE);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入手机号码。");
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
					if(notification.getBody()[0] == popupNewContact)
					{		
						var contant:ContactVO = notification.getBody()[1];
						popupNewContact.contact.copy(contant);
						
						for each(var item:GroupVO in popupNewContact.listGroup)
						{
							item.selected = item.containContact(popupNewContact.contact);
						}		
					}
					break;
			}
		}
	}
}