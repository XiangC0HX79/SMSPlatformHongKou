package app.controller
{
	import app.AppNotification;
	import app.model.ContactProxy;
	import app.model.GroupProxy;
	import app.model.vo.ContactVO;
	import app.model.vo.GroupVO;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.collections.Sort;
	
	public class SortContactCommand extends SimpleCommand implements ICommand
	{
		override public function execute(note:INotification):void
		{			
			var contactProxy:ContactProxy = facade.retrieveProxy(ContactProxy.NAME) as ContactProxy;
			var groupProxy:GroupProxy = facade.retrieveProxy(GroupProxy.NAME) as GroupProxy;
			
			var sort:Sort = new Sort();
			sort.compareFunction = sortFunction;
			
			contactProxy.listAll.sort = sort;
			contactProxy.listAll.refresh();
			
			contactProxy.initListContact(contactProxy.group);
			
			sendNotification(AppNotification.NOTIFY_CONTACT_LIST);
			
			function sortFunction(a:ContactVO,b:ContactVO, fields:Array = null):int
			{
				var maxA:Number;
				var maxB:Number;
				for(var i:Number = 0;i<groupProxy.list.length;i++)
				{
					var group:GroupVO = groupProxy.list[i];
					if(group.containContact(a))
					{
						maxA = Number(group.id);
						break;
					}
				}
				
				for(i = 0;i<groupProxy.list.length;i++)
				{
					group = groupProxy.list[i];
					if(group.containContact(b))
					{
						maxB = Number(group.id);
						break;
					}
				}
				
				if(maxA < maxB)
					return -1;
				else if(maxA > maxB)
					return 1;
				else
				{
					maxA = ContactVO.groupPost.indexOf(a.grouppost);
					maxB = ContactVO.groupPost.indexOf(b.grouppost);
					
					if(maxA < maxB)
						return -1;
					else 
						return 1;
				}
			}
		}
	}
}