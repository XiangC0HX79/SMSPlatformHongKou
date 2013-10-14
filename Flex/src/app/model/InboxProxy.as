package app.model
{
	import app.AppNotification;
	import app.model.vo.SMSVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class InboxProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "InboxProxy";
		
		public function InboxProxy()
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
				["GetReceive",onResult
					,[],true]);
			
			function onResult(result:ArrayCollection):void
			{
				list.filterFunction = null;
				list.refresh();
				
				list.removeAll();
				
				for each(var row:Object in result)
				{
					var sms:SMSVO = new SMSVO;
					sms.ID = row.ID;
					sms.date = row.时间;
					sms.phone = row.手机号码;
					sms.message = row.短信;
					sms.people = row.姓名;
					
					list.addItem(sms);
				}
			}
		}
		
		public function deleteSMS(smses:Array):void
		{
			var IDs:String = "";
			for each(var sms:SMSVO in smses)
			{
				IDs += sms.ID + ";"
			}
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["DeleteReceive",onResult
					,[IDs],true]);
			
			function onResult(result:String):void
			{
				init();
			}
		}
	}
}