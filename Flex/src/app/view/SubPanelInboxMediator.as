package app.view
{
	import app.AppNotification;
	import app.model.InboxProxy;
	import app.model.vo.SMSVO;
	import app.view.components.SubPanelInbox;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class SubPanelInboxMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "SubPanelInboxMediator";
		
		private var inboxProxy:InboxProxy;
		
		public function SubPanelInboxMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			inboxProxy = facade.retrieveProxy(InboxProxy.NAME) as InboxProxy;
			
			subPanelInbox.list = inboxProxy.list;
			
			subPanelInbox.addEventListener(SubPanelInbox.DEL,onDel);
			subPanelInbox.addEventListener(SubPanelInbox.RESMS,onReSMS);
			subPanelInbox.addEventListener(SubPanelInbox.SENDSMS,onSendSMS);
		}
		
		protected function get subPanelInbox():SubPanelInbox
		{
			return viewComponent as SubPanelInbox;
		}
		
		private function onReSMS(event:Event):void
		{			
			var draft:SMSVO = subPanelInbox.gridContact.selectedItem as SMSVO;
			
			if(draft != null)
			{
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),draft]);
			}
		}
		
		private function onSendSMS(event:Event):void
		{			
			var draft:SMSVO = subPanelInbox.gridContact.selectedItem as SMSVO;
			
			if(draft != null)
			{
				var newDraft:SMSVO = new SMSVO;
				newDraft.message = draft.message;
				
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),newDraft]);
			}
		}
		
		private function onDel(event:Event):void
		{			
			var smses:Array = new Array;
			for each(var sms:SMSVO in subPanelInbox.list)
			{
				if(sms.selected)
				{
					smses.push(sms);
				}
			}
			
			inboxProxy.deleteSMS(smses);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_SUBPANEL
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_SUBPANEL:
					if(notification.getBody() == subPanelInbox)
					{
						inboxProxy.init();
					}
			}
		}
	}
}