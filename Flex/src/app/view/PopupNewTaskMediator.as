package app.view
{
	import app.AppNotification;
	import app.model.ContactProxy;
	import app.model.GroupProxy;
	import app.model.TaskProxy;
	import app.model.vo.ContactVO;
	import app.model.vo.GroupVO;
	import app.model.vo.SMSVO;
	import app.view.components.PopupNewTask;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupNewTaskMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupNewTaskMediator";
		
		private var taskProxy:TaskProxy;
		
		public function PopupNewTaskMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			taskProxy = facade.retrieveProxy(TaskProxy.NAME) as TaskProxy;
			
			popupNewTask.addEventListener(PopupNewTask.OK,onOK);
		}
		
		protected function get popupNewTask():PopupNewTask
		{
			return viewComponent as PopupNewTask;
		}
		
		private function onOK(event:Event):void
		{			
			taskProxy.save(popupNewTask.task);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_POPUP_SHOW
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var groupProxy:GroupProxy = facade.retrieveProxy(GroupProxy.NAME) as GroupProxy;	
			var contactProxy:ContactProxy = facade.retrieveProxy(ContactProxy.NAME) as ContactProxy;
			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_POPUP_SHOW:
					if(notification.getBody()[0] == popupNewTask)
					{
						var task:SMSVO = notification.getBody()[1] as SMSVO;
						if(task == null)
						{
							popupNewTask.title = "新建任务";
							popupNewTask.textName.enabled = true;
							popupNewTask.task = new SMSVO;							
						}
						else 
						{							
							popupNewTask.title = "修改任务";
							popupNewTask.textName.enabled = false;
							popupNewTask.task = task;							
						}
						
						popupNewTask.panelSelectContact.setListContact(groupProxy.list,contactProxy.listAll,task.phone);
					}
					break;
			}
		}
	}
}