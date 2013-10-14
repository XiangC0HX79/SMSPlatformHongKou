package app.model
{
	import app.AppNotification;
	import app.model.vo.SMSVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class PhraseGroupProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "PhraseGroupProxy";
		
		public function PhraseGroupProxy()
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
				["GetPhraseGroup",onResult
					,[],true]);
			
			function onResult(result:ArrayCollection):void
			{
				list.removeAll();
				
				for each(var row:Object in result)
				{
					var sms:SMSVO = new SMSVO;
					sms.ID = row.ID;
					sms.name = row.组名;
					
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
				["DeletePhraseGroup",onResult
					,[IDs],true]);
			
			function onResult(result:String):void
			{
				init();
			}
		}
		
		public function save(name:String):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["SetPhraseGroup",onResult
					,[name],true]);
			
			function onResult(result:String):void
			{
				init();
			}
		}
	}
}