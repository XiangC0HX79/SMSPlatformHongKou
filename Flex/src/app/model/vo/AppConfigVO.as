package app.model.vo
{
	[Bindable]
	public class AppConfigVO
	{
		public var user:ContactVO;
		
		public var mailAddr:String = "";
		
		public var mailPws:String = "";
		
		public var platPws:String = "";
		
		public function AppConfigVO()
		{
			this.user = new ContactVO;
		}
	}
}