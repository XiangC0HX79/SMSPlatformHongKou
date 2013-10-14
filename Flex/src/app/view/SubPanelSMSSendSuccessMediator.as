package app.view
{
	import app.AppNotification;
	import app.model.OutboxFProxy;
	import app.model.OutboxSProxy;
	import app.model.vo.SMSVO;
	import app.view.components.SubPanelSMSSend;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class SubPanelSMSSendSuccessMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "SubPanelSMSSendSuccessMediator";
		
		private var outboxFProxy:OutboxSProxy;
		
		public function SubPanelSMSSendSuccessMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			outboxFProxy = facade.retrieveProxy(OutboxSProxy.NAME) as OutboxSProxy;
			
			subPanelSMSSend.list = outboxFProxy.list;
			
			subPanelSMSSend.addEventListener(SubPanelSMSSend.DEL,onDel);
			subPanelSMSSend.addEventListener(SubPanelSMSSend.RESMS,onReSMS);
			subPanelSMSSend.addEventListener(SubPanelSMSSend.SENDSMS,onSendSMS);
		}
		
		protected function get subPanelSMSSend():SubPanelSMSSend
		{
			return viewComponent as SubPanelSMSSend;
		}
		
		private function onReSMS(event:Event):void
		{			
			var draft:SMSVO = subPanelSMSSend.gridContact.selectedItem as SMSVO;
			
			if(draft != null)
			{
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),draft]);
			}
		}
		
		private function onSendSMS(event:Event):void
		{			
			var draft:SMSVO = subPanelSMSSend.gridContact.selectedItem as SMSVO;
			
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
			for each(var sms:SMSVO in subPanelSMSSend.list)
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
					if(notification.getBody() == subPanelSMSSend)
					{
						outboxFProxy.init();
					}
			}
		}
	}
}