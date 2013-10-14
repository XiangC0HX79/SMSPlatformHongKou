package app.view
{
	import app.AppNotification;
	import app.model.vo.HolidayProxy;
	import app.model.vo.HolidayVO;
	import app.view.components.PopupSMSHoliday;
	
	import flash.events.Event;
	
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupSMSHolidayMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSMSHolidayMediator";
		
		private var holidayProxy:HolidayProxy;
		
		public function PopupSMSHolidayMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			holidayProxy = facade.retrieveProxy(HolidayProxy.NAME) as HolidayProxy;
			popupSMSHoliday.list = holidayProxy.list;
			
			popupSMSHoliday.addEventListener(PopupSMSHoliday.SET,onSet);
			popupSMSHoliday.addEventListener(PopupSMSHoliday.EDIT,onEdit);
			popupSMSHoliday.addEventListener(PopupSMSHoliday.DEL,onDel);
		}
		
		protected function get popupSMSHoliday():PopupSMSHoliday
		{
			return viewComponent as PopupSMSHoliday;
		}
		
		private function onSet(event:Event):void
		{
			var name:String = StringUtil.trim(popupSMSHoliday.textName.text);
			var message:String = StringUtil.trim(popupSMSHoliday.textPhrase.text);
			
			if((name != "") && (message != ""))
			{
				var holiday:HolidayVO = new HolidayVO;
				holiday.month = String(popupSMSHoliday.dropMonth.selectedItem);
				holiday.date = String(popupSMSHoliday.dropDate.selectedItem);
				holiday.name = name;
				holiday.message = message;
				holiday.type = String(popupSMSHoliday.type.selectedValue);
				
				holidayProxy.save(holiday);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入节日名称和短信内容。");
			}
		}
		
		private function onEdit(event:Event):void
		{
			var selected:HolidayVO = popupSMSHoliday.gridPhrase.selectedItem as HolidayVO;
			var name:String = StringUtil.trim(popupSMSHoliday.textName.text);
			var message:String = StringUtil.trim(popupSMSHoliday.textPhrase.text);
			
			if((selected != null) && (name != "") && (message != ""))
			{
				var holiday:HolidayVO = new HolidayVO;
				holiday.ID = selected.ID;
				holiday.month = String(popupSMSHoliday.dropMonth.selectedItem);
				holiday.date = String(popupSMSHoliday.dropDate.selectedItem);
				holiday.name = name;
				holiday.message = message;
				holiday.type = String(popupSMSHoliday.type.selectedValue);
				
				holidayProxy.save(holiday);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入节日名称和短信内容。");
			}
		}
		
		private function onDel(event:Event):void
		{			
			var selected:HolidayVO = popupSMSHoliday.gridPhrase.selectedItem as HolidayVO;
			if(selected != null)
			{
				holidayProxy.deleteHoliday([selected]);
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
					var params:Array = notification.getBody() as Array;
					if(params[0] == popupSMSHoliday)
					{
						holidayProxy.getList();
						
						holidayProxy.list.filterFunction = filterFunction;
						holidayProxy.list.refresh();
					}
					break;
			}
			
			function filterFunction(item:HolidayVO):Boolean
			{
				return (item.type == popupSMSHoliday.type.selectedValue);
			}
		}
	}
}