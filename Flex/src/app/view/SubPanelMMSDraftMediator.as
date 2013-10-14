package app.view
{
	import app.AppNotification;
	import app.model.MMSProxy;
	import app.model.vo.MMSVO;
	import app.view.components.SubPanelMMSDraft;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class SubPanelMMSDraftMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "SubPanelMMSDraftMediator";
		
		private var mmsProxy:MMSProxy;
		
		public function SubPanelMMSDraftMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			mmsProxy = facade.retrieveProxy(MMSProxy.NAME) as MMSProxy;
			subPanelMMSDraft.listDraft = mmsProxy.list;
			
			subPanelMMSDraft.addEventListener(SubPanelMMSDraft.DEL,onDel);			
			subPanelMMSDraft.addEventListener(SubPanelMMSDraft.EDIT,onEdit);
		}
		
		protected function get subPanelMMSDraft():SubPanelMMSDraft
		{
			return viewComponent as SubPanelMMSDraft;
		}
		
		private function onEdit(event:Event):void
		{			
			var draft:MMSVO = subPanelMMSDraft.gridContact.selectedItem as MMSVO;
			
			if(draft != null)
			{
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendMMSMediator.NAME).getViewComponent(),draft]);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendMMSMediator.NAME).getViewComponent(),new MMSVO]);
			}
		}
		
		private function onDel(event:Event):void
		{			
			var drafts:Array = new Array;
			for each(var draft:MMSVO in subPanelMMSDraft.listDraft)
			{
				if(draft.selected)
				{
					drafts.push(draft);
				}
			}
			
			mmsProxy.deleteMMS(drafts,"草稿");
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
					if(notification.getBody() == subPanelMMSDraft)
					{
						mmsProxy.getList("草稿");
					}
			}
		}
	}
}