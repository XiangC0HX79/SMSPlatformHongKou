package app.view
{
	import app.AppNotification;
	import app.model.GroupProxy;
	import app.model.vo.ContactVO;
	import app.model.vo.GroupVO;
	import app.view.components.PopupEditContact;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupEditContactMediator_Old extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupEditContactMediator";
		
		public function PopupEditContactMediator_Old(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupEditContact.addEventListener(PopupEditContact.OK,onConfirm);
		}
		
		protected function get popupEditContact():PopupEditContact
		{
			return viewComponent as PopupEditContact;
		}
		
		private function onConfirm(event:Event):void
		{
			popupEditContact.contact.name = popupEditContact.textName.text;
			popupEditContact.contact.phone = popupEditContact.textPhone.text;
			popupEditContact.contact.sex = popupEditContact.textSex.textInput.text;
			popupEditContact.contact.birth = popupEditContact.textYear.text + "年" + popupEditContact.textMonth.text + "月";
			popupEditContact.contact.education = popupEditContact.textEducation.text;
			//contact.branch = popupEditContact.textPhone.text;
			popupEditContact.contact.unit = popupEditContact.textUnit.text;
			popupEditContact.contact.post = popupEditContact.textPost.text;
			popupEditContact.contact.unit_addr = popupEditContact.textUnitAddr.text;
			popupEditContact.contact.unit_phone = popupEditContact.textUnitPhone.text;
			popupEditContact.contact.home_addr = popupEditContact.textHomeAddr.text;
			popupEditContact.contact.home_phone = popupEditContact.textHomePhone.text;
			popupEditContact.contact.mail = popupEditContact.textMail.text;
			
			for(var i:Number = 0;i<popupEditContact.group.dataProvider.length;i++)
			{
				var group:GroupVO = popupEditContact.group.dataProvider[i] as GroupVO;
				if(group.selected)
				{
					popupEditContact.contact.group += group.label + ";";
				}
			}
			
			sendNotification(AppNotification.NOTIFY_CONTACT_ADD);
			
			sendNotification(AppNotification.NOTIFY_POPUP_HIDE);
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
					if(notification.getBody()[0] == popupEditContact)
					{						
						popupEditContact.contact = notification.getBody()[1] as ContactVO;
						
						var arr:ArrayCollection = (facade.retrieveProxy(GroupProxy.NAME) as GroupProxy).list;
						for each(var group:GroupVO in arr)
						{							
							group.selected = group.containContact(popupEditContact.contact);
						}
						popupEditContact.group.dataProvider = arr;
					}
			}
		}
	}
}