package app.model.vo
{
	import app.AppNotification;
	import app.model.vo.HolidayVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class HolidayProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "HolidayProxy";
		
		public function HolidayProxy()
		{
			super(NAME, new ArrayCollection);
		}
		
		public function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		public function getList():void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["GetHoliday",onResult
					,[],true]);
			
			function onResult(result:ArrayCollection):void
			{
				var filterFunction:Function = list.filterFunction;
				
				list.filterFunction = null;
				list.refresh();
				
				list.removeAll();
				
				for each(var row:Object in result)
				{
					var holiday:HolidayVO = new HolidayVO;
					holiday.ID = row.ID;
					holiday.month = row.月;
					holiday.date = row.日;
					holiday.name = row.节日名称;
					holiday.message = row.短信;
					holiday.type = row.类型;
					
					list.addItem(holiday);
				}
				
				list.filterFunction = filterFunction;
				list.refresh();
			}
		}
		
		public function save(draft:HolidayVO):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["SetHoliday",onResult
					,[
						draft.ID
						,draft.month
						,draft.date
						,draft.name
						,draft.message
						,draft.type
					],true]);
			
			function onResult(result:String):void
			{
				draft.ID = result;
				
				getList();
			}
		}
		
		public function deleteHoliday(darfts:Array):void
		{
			var draftIDs:String = "";
			for each(var draft:HolidayVO in darfts)
			{
				draftIDs += draft.ID + ";"
			}
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["DeleteHoliday",onResult
					,[draftIDs],true]);
			
			function onResult(result:String):void
			{
				getList();
			}
		}
	}
}