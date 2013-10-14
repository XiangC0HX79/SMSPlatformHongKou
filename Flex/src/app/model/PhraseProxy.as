package app.model
{
	import app.AppNotification;
	import app.model.vo.SMSVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class PhraseProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "PhraseProxy";
		
		public function PhraseProxy()
		{
			super(NAME, new ArrayCollection);
		}
		
		public function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		public function init(groupID:String):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["GetPhrase",onResult
					,[groupID],true]);
			
			function onResult(result:ArrayCollection):void
			{
				list.removeAll();
				
				for each(var row:Object in result)
				{
					var sms:SMSVO = new SMSVO;
					sms.ID = row.ID;
					sms.message = row.短语;
					sms.date = row.时间;
					
					list.addItem(sms);
				}
			}
		}
		
		public function deleteSMS(groupID:String,smses:Array):void
		{
			var IDs:String = "";
			for each(var sms:SMSVO in smses)
			{
				IDs += sms.ID + ";"
			}
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["DeletePhrase",onResult
					,[IDs],true]);
			
			function onResult(result:String):void
			{
				init(groupID);
			}
		}
		
		public function save(groupID:String,message:String):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["SetPhrase",onResult
					,[groupID,message],true]);
			
			function onResult(result:String):void
			{
				init(groupID);
			}
		}
	}
}