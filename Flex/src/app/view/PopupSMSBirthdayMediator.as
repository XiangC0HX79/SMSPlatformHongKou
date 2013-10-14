package app.view
{
	import app.view.components.PopupSMSBirthday;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupSMSBirthdayMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSMSBirthdayMediator";
		
		public function PopupSMSBirthdayMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		protected function get popupSMSBirthday():PopupSMSBirthday
		{
			return viewComponent as PopupSMSBirthday;
		}
	}
}