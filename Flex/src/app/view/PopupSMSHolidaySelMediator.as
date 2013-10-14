package app.view
{
	import app.AppNotification;
	import app.model.vo.HolidayProxy;
	import app.model.vo.HolidayVO;
	import app.model.vo.SMSVO;
	import app.view.components.PopupSMSHolidaySel;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupSMSHolidaySelMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSMSHolidaySelMediator";
		
		private var holidayProxy:HolidayProxy;
		
		public function PopupSMSHolidaySelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			holidayProxy = facade.retrieveProxy(HolidayProxy.NAME) as HolidayProxy;
			popupSMSHolidaySel.list = holidayProxy.list;
			
			popupSMSHolidaySel.addEventListener(PopupSMSHolidaySel.OK,onOK);
			popupSMSHolidaySel.addEventListener(PopupSMSHolidaySel.CANCEL,onCancel);
		}
		
		public function get popupSMSHolidaySel():PopupSMSHolidaySel
		{
			return viewComponent as PopupSMSHolidaySel;
		}
		
		private function onOK(event:Event):void
		{
			var holiday:HolidayVO = popupSMSHolidaySel.gridPhrase.selectedItem as HolidayVO;
			if(holiday != null)
			{				
				popupSMSHolidaySel.draft.message = holiday.message;
				
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),popupSMSHolidaySel.draft]);
			}
		}
		
		private function onCancel(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),popupSMSHolidaySel.draft]);
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
					var params:Array = notification.getBody() as Array;
					if(params[0] == popupSMSHolidaySel)
					{
						popupSMSHolidaySel.draft = params[1];
							
						holidayProxy.getList();
						
						holidayProxy.list.filterFunction = filterFunction;
						holidayProxy.list.refresh();
					}
					break;
			}
			
			function filterFunction(item:HolidayVO):Boolean
			{
				return (item.type == popupSMSHolidaySel.type.selectedValue);
			}
		}
	}
}