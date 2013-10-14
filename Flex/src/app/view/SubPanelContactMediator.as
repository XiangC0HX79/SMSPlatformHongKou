package app.view
{
	import app.AppNotification;
	import app.model.ContactProxy;
	import app.model.vo.ContactVO;
	import app.model.vo.GroupVO;
	import app.model.vo.MMSVO;
	import app.model.vo.SMSVO;
	import app.view.components.SubPanelContact;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class SubPanelContactMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "SubPanelContactMediator";
		
		private var contactProxy:ContactProxy;
		
		public function SubPanelContactMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			contactProxy = facade.retrieveProxy(ContactProxy.NAME) as ContactProxy;
			subPanelContact.listContact = contactProxy.listContact;
			
			subPanelContact.addEventListener(SubPanelContact.NEWCONTACT,onNewContact);
			subPanelContact.addEventListener(SubPanelContact.SENDSMS,onSendSMS);
			subPanelContact.addEventListener(SubPanelContact.SENDMMS,onSendMMS);
			subPanelContact.addEventListener(SubPanelContact.DELETECONTACT,onDeleteContact);
			subPanelContact.addEventListener(SubPanelContact.EDITCONTACT,onEditContact);
		}
		
		protected function get subPanelContact():SubPanelContact
		{
			return viewComponent as SubPanelContact;
		}
		
		private function onNewContact(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupNewContactMediator.NAME).getViewComponent(),new ContactVO]);
		}
		
		private function onSendSMS(event:Event):void
		{
			var phone:String = "";
			for each(var item:ContactVO in subPanelContact.listContact)
			{
				if(item.selected)
				{
					phone += item.phone + ";";
				}
			}
			
			var draft:SMSVO = new SMSVO;
			draft.phone = phone;
			
			sendNotification(AppNotification.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),draft]);
		}
		
		private function onSendMMS(event:Event):void
		{
			var phone:String = "";
			for each(var item:ContactVO in subPanelContact.listContact)
			{
				if(item.selected)
				{
					phone += item.phone + ";";
				}
			}
			
			var draft:MMSVO = new MMSVO;
			draft.phone = phone;
			
			sendNotification(AppNotification.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupSendMMSMediator.NAME).getViewComponent(),draft]);
		}
		
		private function onDeleteContact(event:Event):void
		{
			var arr:Array = new Array;
			for each(var item:ContactVO in subPanelContact.listContact)
			{
				if(item.selected)
				{
					arr.push(item);
				}
			}
			
			if(arr.length > 0)
				contactProxy.del(arr);
		}
		
		private function onEditContact(event:Event):void
		{
			var contact:ContactVO = subPanelContact.gridContact.selectedItem as ContactVO;
			if(contact != null)
			{
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupNewContactMediator.NAME).getViewComponent(),contact]);	
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				
			}
		}
	}
}