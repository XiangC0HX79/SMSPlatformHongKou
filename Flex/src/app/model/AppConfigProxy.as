package app.model
{
	import app.model.vo.AppConfigVO;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class AppConfigProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "AppConfigProxy";
		
		public function AppConfigProxy()
		{
			super(NAME, new AppConfigVO);
		}
		
		public function get appConfig():AppConfigVO
		{
			return data as AppConfigVO;
		}
	}
}