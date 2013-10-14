package app.view
{
	import app.AppNotification;
	import app.model.TaskProxy;
	import app.model.vo.SMSVO;
	import app.view.components.SubPanelTask;
	
	import flash.events.Event;
	
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class SubPanelTaskMediator extends Mediator implements IMediator
	{
		public static const NAME:String ="SubPanelTaskMediator";
		
		private var taskProxy:TaskProxy;
		
		public function SubPanelTaskMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			taskProxy = facade.retrieveProxy(TaskProxy.NAME) as TaskProxy;
			
			subPanelTask.listTask = taskProxy.list;
			
			subPanelTask.addEventListener(SubPanelTask.NEWTASK,onNewTask);
			subPanelTask.addEventListener(SubPanelTask.EDIT,onEditTask);
			subPanelTask.addEventListener(SubPanelTask.DEL,onDelTask);
		}
		
		protected function get subPanelTask():SubPanelTask
		{
			return viewComponent as SubPanelTask;
		}
		
		private function onNewTask(event:Event):void
		{			
			sendNotification(AppNotification.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupNewTaskMediator.NAME).getViewComponent(),null]);
		}
		
		private function onDelTask(event:Event):void
		{			
			var tasks:Array = new Array;
			for each(var task:SMSVO in subPanelTask.listTask)
			{
				if(task.selected)
				{
					tasks.push(task);
				}
			}
				
			taskProxy.deleteTask(tasks);
		}
		
		private function onEditTask(event:Event):void
		{			
			var task:SMSVO = subPanelTask.gridContact.selectedItem as SMSVO;
			if(task != null)
			{
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupNewTaskMediator.NAME).getViewComponent(),task]);
			}
		}
						
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_SUBPANEL
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_SUBPANEL:
					if(notification.getBody() == subPanelTask)
					{
						taskProxy.init();
					}
			}
		}
	}
}