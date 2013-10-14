package app.model
{
	import app.AppNotification;
	import app.model.vo.SMSVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class OutboxFProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "OutboxFProxy";
		
		public function OutboxFProxy()
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
				["GetSend",onResult
					,["失败"],true]);
			
			function onResult(result:ArrayCollection):void
			{
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
				["DeleteSend",onResult
					,[IDs],true]);
			
			function onResult(result:String):void
			{
				init();
			}
		}
		
		public function save(sms:SMSVO):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["SetSend",onResult
					,[
						sms.dateString
						,sms.phone
						,sms.message
						,"失败"
						,sms.people
					],true]);
			
			function onResult(result:String):void
			{
				init();
			}
		}
	}
}