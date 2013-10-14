package app.view
{
	import app.AppNotification;
	import app.model.ContactProxy;
	import app.model.GroupProxy;
	import app.model.vo.ContactVO;
	import app.model.vo.GroupVO;
	import app.model.vo.MMSVO;
	import app.model.vo.SMSVO;
	import app.view.components.LeftPanel;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Group;
	
	public class LeftPanelMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LeftPanelMediator";
		
		private var contactProxy:ContactProxy;
		private var groupProxy:GroupProxy;
		
		public function LeftPanelMediator(viewComponent:Object=null)
		{
			super(mediatorName, viewComponent);
			
			contactProxy = facade.retrieveProxy(ContactProxy.NAME) as ContactProxy;			
			groupProxy = facade.retrieveProxy(GroupProxy.NAME) as GroupProxy;
			
			leftPanel.addEventListener(LeftPanel.ADDGROUP,onAddGroup);
			leftPanel.addEventListener(LeftPanel.ADDCONTACT,onAddGontact);
			leftPanel.addEventListener(LeftPanel.DELETEGROUP,onDeleteGroup);
			leftPanel.addEventListener(LeftPanel.SENDSMS,onSendSMS);
			leftPanel.addEventListener(LeftPanel.SENDMMS,onSendMMS);
			leftPanel.addEventListener(LeftPanel.DELCONTACT,onDeleteContact);
			
			leftPanel.addEventListener(LeftPanel.NODECHANGE,onNodeChange);			
		}
		
		protected function get leftPanel():LeftPanel
		{
			return viewComponent as LeftPanel;
		}
		
		private function onAddGroup(event:Event):void
		{			
			sendNotification(AppNotification.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupNewGroupMediator.NAME).getViewComponent()]);
		}
		
		private function onAddGontact(event:Event):void
		{			
			sendNotification(AppNotification.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupNewContactMediator.NAME).getViewComponent(),new ContactVO]);
		}
		
		private function onSendSMS(event:Event):void
		{
			var selectedTreeNode:XML = leftPanel.treeContact.selectedItem as XML;
			if(selectedTreeNode != null)
			{								
				var arr:ArrayCollection = new ArrayCollection;
				
				switch(String(selectedTreeNode.@type))
				{
					case "root":
						arr.addAll(contactProxy.listAll);
						break;
					
					case "group":
						var group:GroupVO = groupProxy.getGroupByID(selectedTreeNode.@id);
						for each(var item:ContactVO in contactProxy.listAll)
						{
							if(group.containContact(item))
								arr.addItem(item);
						}
						break;
					
					default:						
						var contact:ContactVO = contactProxy.getContactByID(selectedTreeNode.@id);
						arr.addItem(contact);
						break;
				}
				
				var draft:SMSVO = new SMSVO;
				for each(contact in arr)
				{
					draft.phone += contact.phone + ";";
				}
				
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendSMSMediator.NAME).getViewComponent(),draft]);
			}
		}
		
		private function onDeleteGroup(event:Event):void
		{			
			var groupProxy:GroupProxy = facade.retrieveProxy(GroupProxy.NAME) as GroupProxy;
			var currentItem:XML = leftPanel.treeContact.selectedItem as XML;
			
			for(var i:Number = 0;i<groupProxy.list.length;i++)
			{
				var group:GroupVO = groupProxy.list[i] as GroupVO;
				if(group.id == currentItem.@id)
				{
					groupProxy.list.removeItemAt(i);
				}
			}
			
			initTree();
		}
		
		private function onDeleteContact(event:Event):void
		{
			var selectedTreeNode:XML = leftPanel.treeContact.selectedItem as XML;
			if(selectedTreeNode != null)
			{												
				var contact:ContactVO = contactProxy.getContactByID(selectedTreeNode.@id);
				
				if(contact != null)
				{
					contactProxy.del([contact]);
				}
			}
		}
		
		private function onSendMMS(event:Event):void
		{			
			var selectedTreeNode:XML = leftPanel.treeContact.selectedItem as XML;
			if(selectedTreeNode != null)
			{				
				var arr:ArrayCollection = new ArrayCollection;
				
				switch(String(selectedTreeNode.@type))
				{
					case "root":
						arr.addAll(contactProxy.listAll);
						break;
					
					case "group":
						var group:GroupVO = groupProxy.getGroupByID(selectedTreeNode.@id);
						for each(var item:ContactVO in contactProxy.listAll)
					{
						if(group.containContact(item))
							arr.addItem(item);
					}
						break;
					
					default:						
						var contact:ContactVO = contactProxy.getContactByID(selectedTreeNode.@id);
						arr.addItem(contact);
						break;
				}
				
				var draft:MMSVO = new MMSVO;
				for each(contact in arr)
				{
					draft.phone += contact.phone + ";";
				}
				
				sendNotification(AppNotification.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendMMSMediator.NAME).getViewComponent(),draft]);
			}
		}	
		
		private function onNodeChange(event:Event):void
		{
			var selectedTreeNode:XML = leftPanel.treeContact.selectedItem as XML;
			if(selectedTreeNode != null)
			{
				var groupProxy:GroupProxy = facade.retrieveProxy(GroupProxy.NAME) as GroupProxy;
				var group:GroupVO = null;
				switch(String(selectedTreeNode.@type))
				{
					case "root":
						break;
					
					case "group":
						group = groupProxy.getGroupByID(selectedTreeNode.@id);
						break;
					
					default:						
						var parent:XML = selectedTreeNode.parent();
						group = groupProxy.getGroupByID(parent.@id);
						break;
				}
				
				contactProxy.initListContact(group);	
				
				sendNotification(AppNotification.NOTIFY_SUBPANEL
					,facade.retrieveMediator(SubPanelContactMediator.NAME).getViewComponent());
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_GROUP_ADD,
				AppNotification.NOTIFY_CONTACT_LIST
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
				case AppNotification.NOTIFY_GROUP_ADD:
				case AppNotification.NOTIFY_CONTACT_LIST:
					initTree();
					break;		
			}
		}
		
		private function initTree():void
		{		
			var xml:XML = groupProxy.listXML;
						
			for each(var contact:ContactVO in contactProxy.listAll)
			{
				if(contact.group == "")
				{
					var newXML:XML = <node/>;
					newXML.@id = contact.id;
					newXML.@type = "contact";
					newXML.@label = contact.name;
					xml.insertChildAfter(null,newXML);	
				}
			}
			
			for each(var item:XML in xml.children()) 
			{
				var group:GroupVO = groupProxy.getGroupByID(item.@id);
				
				if(group != null)
				{
					for each(contact in contactProxy.listAll)
					{
						if(group.containContact(contact))
						{
							newXML = <node/>;
							newXML.@id = contact.id;
							newXML.@type = "contact";
							newXML.@label = contact.name;
							item.appendChild(newXML);	
						}
					}
				}
			}
			
			leftPanel.treeContact.dataProvider = xml;
			
			leftPanel.treeContact.validateNow(); 
			
			for each(item in leftPanel.treeContact.dataProvider) 
			{
				leftPanel.treeContact.expandItem(item,true); 
			}
		}
	}
}