package app.model.vo
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
	import spark.formatters.DateTimeFormatter;

	[Bindable]
	public class MMSVO
	{
		public var ID:String = "-1";
		public var phone:String = "";
		public var name:String = "";
		public var date:Date;
		public function get dateString():String
		{
			var df:DateTimeFormatter = new DateTimeFormatter;
			df.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			return df.format(date);
		}
		public var pares:ArrayCollection = new ArrayCollection;
		public var people:String = "";
				
		public var selected:Boolean = false;
		
		public function MMSVO()
		{
			this.name = "《虹口民建手机报》第一期";
		}
		
		public function copy(mms:MMSVO):void
		{
			this.ID = mms.ID;
			this.name = mms.name;
			this.date = mms.date;
			
			this.pares.removeAll();
			this.pares.addAll(mms.pares);
		}
		
		public function downTitle(url:String):void
		{			
			var downloadURL:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE,completeHandler);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.load(downloadURL);
			
			function completeHandler(event:Event):void
			{
				urlLoader.removeEventListener(Event.COMPLETE, completeHandler);
				var byteArray:ByteArray = urlLoader.data;
				name = byteArray.readMultiByte(byteArray.bytesAvailable, "gb18030");
			}
		}
	}
}