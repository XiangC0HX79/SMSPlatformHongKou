package app.controller
{
	import app.AppNotification;
	import app.model.AppConfigProxy;
	import app.model.ContactProxy;
	import app.model.GroupProxy;
	import app.model.SocketProxy;
	import app.model.vo.AppConfigVO;
	import app.model.vo.ContactVO;
	import app.model.vo.GroupVO;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class LocalConfigCommand extends SimpleCommand implements ICommand
	{
		private static const INITCOUNT:Number = 3;
		
		private static var init:Number = 0;
		
		override public function execute(note:INotification):void
		{			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"系统初始化：加载本地配置...");
				
			var request:URLRequest = new URLRequest("config.xml");
			var load:URLLoader = new URLLoader(request);
			load.addEventListener(Event.COMPLETE,onLocaleConfigResult);
			load.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
		}
				
		private function onIOError(event:IOErrorEvent):void
		{
			sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,event.text);
		}
		
		private function appInit():void
		{
			if(++init == INITCOUNT)
			{								
				sendNotification(AppNotification.NOTIFY_CONTACT_ALL);
				
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化完成！");
				
				sendNotification(AppNotification.NOTIFY_APP_INIT);
			}
		}
		
		private function onLocaleConfigResult(event:Event):void
		{				
			try
			{
				var xml:XML = new XML(event.currentTarget.data);
			}
			catch(e:Object)
			{
				trace(e);
			}
			
			if(xml == null)
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"配置文件损坏，请检查config.xml文件正确性！");
				
				sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"程序初始化：本地配置加载失败！");	
			}
			else
			{
				WebServiceCommand.WSDL = xml.WebServiceUrl;
				
				SocketProxy.socketIP = xml.SocketIP;
				
				SocketProxy.socketPort = int(xml.SocketPort);
				
				(facade.retrieveProxy(SocketProxy.NAME) as SocketProxy).conect(onSocketConnect);
				
				//验证权限
				//sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				//	["getAuth",onAuthResult,[AppConfigVO.userid],false]);
				
				//加载系统设置
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["GetSysParam",onGetSysParamResult,[],false]);
				
				//加载会员名单
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["GetContact",onGetContactResult,[],false]);
				
				//加载会员组
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["GetGroup",onGetGroupResult,[],false]);
			}
		}
		
		private function onSocketConnect():void
		{			
			appInit();
		}
			
		private function onGetSysParamResult(result:ArrayCollection):void
		{
			var appConfig:AppConfigVO = (facade.retrieveProxy(AppConfigProxy.NAME) as AppConfigProxy).appConfig;
			for each(var row:Object in result)
			{
				switch(String(row.参数名称))
				{
					case "邮箱地址":
						appConfig.mailAddr = (row.参数值 == undefined)?"":String(row.参数值);
						break;
					
					case "邮箱密码":
						appConfig.mailPws = (row.参数值 == undefined)?"":String(row.参数值);
						break;
					
					case "平台密码":
						appConfig.platPws = (row.参数值 == undefined)?"":String(row.参数值);
						break;
				}
			}
		}
		
		private function onGetContactResult(result:ArrayCollection):void
		{		
			var contactProxy:ContactProxy = facade.retrieveProxy(ContactProxy.NAME) as ContactProxy;
			
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
				
				contactProxy.listAll.addItem(contact);
				//contactProxy.listContact.addItem(contact);
			}
			
			appInit();
		}
		
		private function onGetGroupResult(result:ArrayCollection):void
		{		
			var groupProxy:GroupProxy = facade.retrieveProxy(GroupProxy.NAME) as GroupProxy;
			
			for each(var row:Object in result)
			{
				var group:GroupVO = new GroupVO;
				group.id = row.ID;
				group.label = row.组名;
				
				groupProxy.list.addItem(group);
			}
			
			appInit();
		}
	}
}