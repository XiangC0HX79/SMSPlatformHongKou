package app.model.vo
{
	import spark.formatters.DateTimeFormatter;

	[Bindable]
	public class SMSVO
	{
		public var ID:String = "-1";	
		public var name:String = "";
		public var date:Date;
		public function get dateString():String
		{
			var df:DateTimeFormatter = new DateTimeFormatter;
			df.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			return df.format(date);
		}
		
		public var phone:String = "";
		public var message:String = "";
		public var people:String = "";
		public var status:String = "";
		
		public var selected:Boolean = false;
		
		public function SMSVO()
		{
		}
	}
}