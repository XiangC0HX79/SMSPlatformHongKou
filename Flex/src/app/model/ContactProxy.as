package app.model
{
	import app.AppNotification;
	import app.model.vo.ContactVO;
	import app.model.vo.GroupVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import spark.collections.Sort;
	
	public class ContactProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "ContactProxy";
		
		public var group:GroupVO;
		
		public function ContactProxy()
		{
			super(NAME, new Array);
			
			list.push(new ArrayCollection);
			list.push(new ArrayCollection);
		}
		
		private function get list():Array
		{
			return data as Array;
		}
		
		public function get listAll():ArrayCollection
		{
			return list[0] as ArrayCollection;
		}
		
		public function get listContact():ArrayCollection
		{
			return list[1] as ArrayCollection;
		}
		
		public function getContactByID(id:String):ContactVO
		{
			for each(var item:ContactVO in listAll)
			{
				if(item.id == id)
				{
					return item;
				}
			}
			
			return null;
		}
		
		public function initList():void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["GetContact",onGetContact,[],true]);
			
			function onGetContact(result:ArrayCollection):void
			{
				listAll.removeAll();
				
				for each(var row:Object in result)
				{
					var contact:ContactVO = new ContactVO;
					
					contact.id = row.ID;
					//if(row.出生年月 != undefined)contact.birth = row.出生年月;
					if(row.所属支部 != undefined)contact.branch = row.所属支部;
					//if(row.学历 != undefined)contact.education = row.学历;
					if(row.组别 != undefined)contact.group = row.组别;
					//if(row.家庭地址 != undefined)contact.home_addr = row.家庭地址;
					//if(row.家庭电话 != undefined)contact.home_phone = row.家庭电话;
					if(row.电子邮箱 != undefined)contact.mail = row.电子邮箱;
					if(row.姓名 != undefined)contact.name = row.姓名;
					if(row.手机号码 != undefined)contact.phone = String(row.手机号码).replace("/",";");
					//if(row.职务 != undefined)contact.post = row.职务;
					//if(row.性别 != undefined)contact.sex = row.性别;
					//if(row.工作单位 != undefined)contact.unit = row.工作单位;
					//if(row.单位地址!= undefined)contact.unit_addr = row.单位地址;
					//if(row.单位电话 != undefined)contact.unit_phone = row.单位电话;
					//if(row.组别职务 != undefined)contact.grouppost = row.组别职务;
					var arrPost:Array = String(row.组别职务).split(",");				
					for(var i:Number = 0;i< ContactVO.groupPost.length;i++)
					{
						if(arrPost.indexOf(ContactVO.groupPost[i]) != -1)
						{
							contact.grouppost = ContactVO.groupPost[i];
							break;
						}
					}
					
					listAll.addItem(contact);	
				}
				
				sendNotification(AppNotification.NOTIFY_CONTACT_ALL);
			}
		}
		
		public function initListContact(group:GroupVO):void
		{
			this.group = group;
			
			listContact.removeAll();
			
			if(group == null)
			{
				listContact.addAll(listAll);
			}
			else
			{
				for each(var contact:ContactVO in listAll)
				{
					if(group.containContact(contact))
						listContact.addItem(contact);
				}
			}
		}
		
		public function save(contact:ContactVO):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["SetContact",onSetTask
					,[
						contact.id
						,contact.name
						,contact.phone
						,contact.group
						,contact.mail
						,contact.grouppost
					],true]);
			
			function onSetTask(result:String):void
			{
				var param:Array = result.split("|");
				
				if(param[0] == "0001")
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"电话号码已存在，更新会员失败。");
				}
				else if(param[0] == "0002")
				{					
					sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"更新会员失败。");
				}
				else
				{		
					sendNotification(AppNotification.NOTIFY_APP_ALERTINFO,"更新会员成功。");
				}
				
				initList();
			}
		}
		
		public function del(contacts:Array):void
		{
			var IDs:String = "";
			for each(var item:ContactVO in contacts)
			{
				IDs += item.id + ";";
			}
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["DeleteContact",onResult
					,[IDs],true]);
			
			function onResult(result:String):void
			{
				if(result != "0")
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTINFO,"删除会员成功。");
				}
				else
				{					
					sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"删除会员失败。");
				}
				
				initList();
			}
		}
	}
}