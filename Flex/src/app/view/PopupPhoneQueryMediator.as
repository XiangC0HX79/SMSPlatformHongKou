package app.view
{
	import app.view.components.PopupPhoneQuery;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupPhoneQueryMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupPoneQueryMediator";
		
		public function PopupPhoneQueryMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		private function get popupPhoneQuery():PopupPhoneQuery
		{
			return viewComponent as PopupPhoneQuery;
		}
	}
}