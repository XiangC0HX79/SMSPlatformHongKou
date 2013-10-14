package app.view
{
	import app.view.components.PopupSMSPerson;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupSMSPersonMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSMSPersonMediator";
		
		public function PopupSMSPersonMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		protected function get popupSMSPerson():PopupSMSPerson
		{
			return viewComponent as PopupSMSPerson;
		}
	}
}