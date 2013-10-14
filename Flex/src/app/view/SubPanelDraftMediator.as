package app.view
{
	import app.AppNotification;
	import app.model.SMS_DraftProxy;
	import app.model.vo.SMSVO;
	import app.view.components.SubPanelDraft;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class SubPanelDraftMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "SubPanelDraftMediator";
		
		private var draftProxy:SMS_DraftProxy;
		
		public function SubPanelDraftMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			draftProxy = facade.retrieveProxy(SMS_DraftProxy.NAME) as SMS_DraftProxy;
			
			subPanelDraft.listDraft = draftProxy.list;
			
			subPanelDraft.addEventListener(SubPanelDraft.EDIT,onEdit);
			subPanelDraft.addEventListener(SubPanelDraft.DEL,onDel);
		}
		
		protected function get subPanelDraft():SubPanelDraft
		{
			return viewComponent as SubPanelDraft;
		}
		
		private function onEdit(event:Event):void
		{			
			var draft:SMSVO = subPanelDraft.gridContact.selectedItem as SMSVO;
			
			if(draft != null)
			{
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),draft]);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),new SMSVO]);
			}
		}
		
		private function onDel(event:Event):void
		{			
			var drafts:Array = new Array;
			for each(var draft:SMSVO in subPanelDraft.listDraft)
			{
				if(draft.selected)
				{
					drafts.push(draft);
				}
			}
			
			draftProxy.deleteTask(drafts);
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
					if(notification.getBody() == subPanelDraft)
					{
						draftProxy.init();
					}
			}
		}
	}
}