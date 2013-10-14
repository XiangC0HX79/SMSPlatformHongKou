package app.view
{
	import app.AppNotification;
	import app.model.GroupProxy;
	import app.model.vo.GroupVO;
	import app.view.components.PopupNewGroup;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupNewGroupMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupNewGroupMediator";
		
		public function PopupNewGroupMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupNewGroup.addEventListener(PopupNewGroup.OK,onConfirm);
		}
		
		protected function get popupNewGroup():PopupNewGroup
		{
			return viewComponent as PopupNewGroup;
		}
		
		private function onConfirm(event:Event):void
		{
			var groupProxy:GroupProxy = facade.retrieveProxy(GroupProxy.NAME) as GroupProxy;
			if(popupNewGroup.groupName.text != "")
			{
				var group:GroupVO = new GroupVO;
				group.id = groupProxy.nextID;
				group.label = popupNewGroup.groupName.text;
				groupProxy.list.addItem(group);
				
				sendNotification(AppNotification.NOTIFY_GROUP_ADD,group);
				
				sendNotification(AppNotification.NOTIFY_POPUP_HIDE);
			}
		}
	}
}