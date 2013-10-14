package app.model
{
	import app.AppNotification;
	import app.model.vo.SMSVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class TaskProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "TaskProxy";
		
		public function TaskProxy()
		{
			super(NAME, new ArrayCollection);
		}
		
		public function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		public function init():void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["GetTask",onGetTask
					,[],true]);
			
			function onGetTask(result:ArrayCollection):void
			{
				list.removeAll();
				
				for each(var row:Object in result)
				{
					var task:SMSVO = new SMSVO;
					task.name = row.任务名称;
					task.date = row.时间;
					task.phone = row.手机号码;
					task.message = row.短信;
					task.people = row.姓名;
					
					list.addItem(task);
				}
			}
		}
		
		public function save(task:SMSVO):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["SetTask",onSetTask
					,[
						task.name
						,task.dateString
						,task.phone
						,task.message
						,task.people
					],true]);
			
			function onSetTask(result:String):void
			{
				init();
			}
		}
		
		public function deleteTask(tasks:Array):void
		{
			var taskNames:String = "";
			for each(var task:SMSVO in tasks)
			{
				taskNames += task.name + ";"
			}
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["DeleteTask",onDeleteTask
					,[taskNames],true]);
			
			function onDeleteTask(result:String):void
			{
				init();
			}
		}
	}
}