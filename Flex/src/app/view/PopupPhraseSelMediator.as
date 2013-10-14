package app.view
{
	import app.AppNotification;
	import app.model.PhraseProxy;
	import app.model.vo.SMSVO;
	import app.view.components.PopupPhraseSel;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupPhraseSelMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupPhraseSelMediator";
				
		private var phraseProxy:PhraseProxy;
		
		public function PopupPhraseSelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			phraseProxy = facade.retrieveProxy(PhraseProxy.NAME) as PhraseProxy;
			popupPhraseSel.listPhrase = phraseProxy.list;
			
			popupPhraseSel.addEventListener(PopupPhraseSel.OK,onOK);
			popupPhraseSel.addEventListener(PopupPhraseSel.CANCEL,onCancel);
		}
		
		protected function get popupPhraseSel():PopupPhraseSel
		{
			return viewComponent as PopupPhraseSel;
		}
		
		private function onOK(event:Event):void
		{
			var phrase:SMSVO = popupPhraseSel.gridPhrase.selectedItem as SMSVO;
			if(phrase != null)
			{				
				popupPhraseSel.draft.message = phrase.message;
				
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),popupPhraseSel.draft]);
			}
		}
		
		private function onCancel(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),popupPhraseSel.draft]);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_POPUP_SHOW
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_POPUP_SHOW:
					var params:Array = notification.getBody() as Array;
					if(params[0] == popupPhraseSel)
					{
						popupPhraseSel.draft = params[1];
						
						phraseProxy.init("1");
					}
					break;
			}
		}
	}
}