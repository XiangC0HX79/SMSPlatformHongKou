package app.model
{
	import app.AppNotification;
	import app.model.vo.SMSVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class SMS_DraftProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "SMS_DraftProxy";
		
		public function SMS_DraftProxy()
		{
			super(NAME, new ArrayCollection);
		}
		
		public function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		public function init():void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["GetDraft",onResult
					,[],true]);
			
			function onResult(result:ArrayCollection):void
			{
				list.filterFunction = null;
				list.refresh();
				
				list.removeAll();
				
				for each(var row:Object in result)
				{
					var task:SMSVO = new SMSVO;
					task.ID = row.ID;
					task.phone = row.手机号码;
					task.message = row.短信;
					task.people = row.姓名;
					
					list.addItem(task);
				}
			}
		}
		
		public function save(draft:SMSVO):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["SetDraft",onResult
					,[
						draft.ID
						,draft.phone
						,draft.message
						,draft.people
					],true]);
			
			function onResult(result:String):void
			{
				draft.ID = result;
				
				init();
			}
		}
		
		public function deleteTask(darfts:Array):void
		{
			var draftIDs:String = "";
			for each(var draft:SMSVO in darfts)
			{
				draftIDs += draft.ID + ";"
			}
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["DeleteDraft",onResult
					,[draftIDs],true]);
			
			function onResult(result:String):void
			{
				init();
			}
		}
	}
}