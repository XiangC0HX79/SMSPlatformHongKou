package app.view
{
	import app.AppNotification;
	import app.model.MMSProxy;
	import app.model.vo.MMSVO;
	import app.view.components.Menu;
	import app.view.components.SubPanelMMSSend;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class SubPanelMMSSendMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "SubPanelMMSSendMediator";
		
		private var mmsProxy:MMSProxy;
		
		public function SubPanelMMSSendMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			mmsProxy = facade.retrieveProxy(MMSProxy.NAME) as MMSProxy;
			subPanelMMSSend.list = mmsProxy.list;
			
			subPanelMMSSend.addEventListener(SubPanelMMSSend.DEL,onDel);
			subPanelMMSSend.addEventListener(SubPanelMMSSend.RESMS,onReSMS);
			subPanelMMSSend.addEventListener(SubPanelMMSSend.SENDSMS,onSendSMS);
		}
		
		protected function get subPanelMMSSend():SubPanelMMSSend
		{
			return viewComponent as SubPanelMMSSend;
		}
				
		private function onReSMS(event:Event):void
		{			
			var draft:MMSVO = subPanelMMSSend.gridContact.selectedItem as MMSVO;
			
			if(draft != null)
			{
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendMMSMediator.NAME).getViewComponent(),draft]);
			}
		}
		
		private function onSendSMS(event:Event):void
		{			
			var draft:MMSVO = subPanelMMSSend.gridContact.selectedItem as MMSVO;
			
			if(draft != null)
			{
				var newDraft:MMSVO = new MMSVO;
				newDraft.copy(draft);
				newDraft.phone = "";
				
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendMMSMediator.NAME).getViewComponent(),newDraft]);
			}
		}
		
		private function onDel(event:Event):void
		{			
			var smses:Array = new Array;
			for each(var sms:MMSVO in subPanelMMSSend.list)
			{
				if(sms.selected)
				{
					smses.push(sms);
				}
			}
			
			if(subPanelMMSSend.title == "彩信发送成功记录")
				mmsProxy.deleteMMS(smses,"发送成功");
			else
				mmsProxy.deleteMMS(smses,"发送失败");
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
					if(notification.getBody() == subPanelMMSSend)
					{
						if(notification.getType() == Menu.MENU_MMS_SENDSUCCESS)
						{
							subPanelMMSSend.title = "彩信发送成功记录";							
							mmsProxy.getList("发送成功");
						}
						else
						{
							subPanelMMSSend.title = "彩信发送失败记录";							
							mmsProxy.getList("发送失败");
						}
					}
			}
		}
	}
}