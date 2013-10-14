package app.view
{
	import app.AppNotification;
	import app.model.PhraseGroupProxy;
	import app.model.PhraseProxy;
	import app.model.vo.SMSVO;
	import app.view.components.PopupSMSDict;
	
	import flash.events.Event;
	
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupSMSDictMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSMSDictMediator";
		
		private var phraseGroupProxy:PhraseGroupProxy;
		private var phraseProxy:PhraseProxy;
		
		public function PopupSMSDictMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			phraseGroupProxy = facade.retrieveProxy(PhraseGroupProxy.NAME) as PhraseGroupProxy;
			popupSMSDict.listGroup = phraseGroupProxy.list;
			
			phraseProxy = facade.retrieveProxy(PhraseProxy.NAME) as PhraseProxy;
			popupSMSDict.listPhrase = phraseProxy.list;
			
			popupSMSDict.addEventListener(PopupSMSDict.ADDGROUP,onAddGroup);
			popupSMSDict.addEventListener(PopupSMSDict.DELGROUP,onDelGroup);
			
			popupSMSDict.addEventListener(PopupSMSDict.CHANGEGROUP,onChangeGroup);
			
			popupSMSDict.addEventListener(PopupSMSDict.ADDPHRASE,onAddPhrase);
			popupSMSDict.addEventListener(PopupSMSDict.DELPHRASE,onDelPhrase);
		}
		
		protected function get popupSMSDict():PopupSMSDict
		{
			return viewComponent as PopupSMSDict;
		}
		
		private function onAddGroup(event:Event):void
		{
			/*var groupName:String = StringUtil.trim(popupSMSDict.textGroup.text);
			if(groupName != "")
			{
				phraseGroupProxy.save(groupName);
			}*/
		}
		
		private function onDelGroup(event:Event):void
		{
			/*var group:SMSVO = popupSMSDict.gridGroup.selectedItem as SMSVO;
			if(group != null)
			{
				phraseGroupProxy.deleteSMS([group]);
			}*/
		}
		
		private function onChangeGroup(event:Event):void
		{			
			/*var group:SMSVO = popupSMSDict.gridGroup.selectedItem as SMSVO;
			if(group != null)
			{
				phraseProxy.init(group.ID);
			}*/
		}
				
		private function onAddPhrase(event:Event):void
		{
			var message:String = StringUtil.trim(popupSMSDict.textPhrase.text);
			
			//var group:SMSVO = popupSMSDict.gridGroup.selectedItem as SMSVO;
			
			if(message != "")
			{
				phraseProxy.save("1",message);
			}
		}
		
		private function onDelPhrase(event:Event):void
		{
			var phrase:SMSVO = popupSMSDict.gridPhrase.selectedItem as SMSVO;
			//var group:SMSVO = popupSMSDict.gridGroup.selectedItem as SMSVO;
			if(phrase != null)
			{
				phraseProxy.deleteSMS("1",[phrase]);
			}
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
					if(params[0] == popupSMSDict)
					{
						phraseProxy.init("1");
					}
					break;
			}
		}
	}
}