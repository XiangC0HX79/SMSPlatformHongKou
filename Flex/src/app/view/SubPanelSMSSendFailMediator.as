package app.view
{
	import app.AppNotification;
	import app.model.OutboxFProxy;
	import app.model.vo.SMSVO;
	import app.view.components.SubPanelSMSSend;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class SubPanelSMSSendFailMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "SubPanelSMSSendFailMediator";
		
		private var outboxFProxy:OutboxFProxy;
		
		public function SubPanelSMSSendFailMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			outboxFProxy = facade.retrieveProxy(OutboxFProxy.NAME) as OutboxFProxy;
			
			subPanelSMSSendFail.list = outboxFProxy.list;
			
			subPanelSMSSendFail.addEventListener(SubPanelSMSSend.DEL,onDel);
			subPanelSMSSendFail.addEventListener(SubPanelSMSSend.RESMS,onReSMS);
			subPanelSMSSendFail.addEventListener(SubPanelSMSSend.SENDSMS,onSendSMS);
		}
		
		protected function get subPanelSMSSendFail():SubPanelSMSSend
		{
			return viewComponent as SubPanelSMSSend;
		}
			
		private function onReSMS(event:Event):void
		{			
			var draft:SMSVO = subPanelSMSSendFail.gridContact.selectedItem as SMSVO;
			
			if(draft != null)
			{
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),draft]);
			}
		}
		
		private function onSendSMS(event:Event):void
		{			
			var draft:SMSVO = subPanelSMSSendFail.gridContact.selectedItem as SMSVO;
			
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
			for each(var sms:SMSVO in subPanelSMSSendFail.list)
			{
				if(sms.selected)
				{
					smses.push(sms);
				}
			}
			
			outboxFProxy.deleteSMS(smses);
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
					if(notification.getBody() == subPanelSMSSendFail)
					{
						outboxFProxy.init();
					}
			}
		}
	}
}