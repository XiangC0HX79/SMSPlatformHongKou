package app.view
{
	import app.AppNotification;
	import app.controller.WebServiceCommand;
	import app.model.ContactProxy;
	import app.model.GroupProxy;
	import app.model.MMSProxy;
	import app.model.vo.ContactVO;
	import app.model.vo.GroupVO;
	import app.model.vo.MMSParVO;
	import app.model.vo.MMSVO;
	import app.view.components.PopupSendMMS;
	import app.view.components.subComponents.PanelMMSPar;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Group;
	import spark.components.NavigatorContent;
	
	public class PopupSendMMSMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSendMMSMediator";
		
		private var mmsProxy:MMSProxy;
		
		[Embed(source="assets/image/icon_alarm.png")]
		private const ICON_ALERT:Class;
		
		public function PopupSendMMSMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			mmsProxy = facade.retrieveProxy(MMSProxy.NAME) as MMSProxy;
						
			popupSendMMS.addEventListener(PopupSendMMS.SEND,onSend);
			popupSendMMS.addEventListener(PopupSendMMS.SAVE,onSave);
						
			popupSendMMS.addEventListener(PopupSendMMS.OPENWORD,onOpenWord);
			popupSendMMS.addEventListener(PopupSendMMS.SETWORD,onSetWord);
			popupSendMMS.addEventListener(PopupSendMMS.ERRORWORD,onErrorWord);
		}
		
		protected function get popupSendMMS():PopupSendMMS
		{
			return viewComponent as PopupSendMMS;
		}
		
		private function onSend(event:Event):void
		{
			popupSendMMS.MMS.phone = popupSendMMS.panelSelectContact.mobs;
			popupSendMMS.MMS.people = popupSendMMS.panelSelectContact.names;
			
			if(popupSendMMS.MMS.phone == "")
			{				
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请选择联系人！");
				return 
			}
				
			
			if(popupSendMMS.MMS.name == "")
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入彩信主题！");
				return;
			}
			
			var sAlert:String = "";
			
			var listNames:Array = popupSendMMS.panelSelectContact.names.split(";");
			var listMobs:Array = popupSendMMS.panelSelectContact.mobs.split(";");
			if(listNames.length > 1)
			{
				var count:Number = Math.min(5,listNames.length - 1);
				
				sAlert = listNames[0];
				
				for(var i:Number = 1;i<count;i++)
				{
					sAlert += "," + listNames[i];
				}
				
				sAlert =  "正准备发送彩信给“" + sAlert + "”等" + (listMobs.length - 1).toString() +  "人，是否发送？";
			}
			
			if(sAlert == "")
			{
				if(listMobs.length > 1)
				{
					count = Math.min(5,listMobs.length - 1);
					
					sAlert = listMobs[0];
					
					for(i = 1;i< count;i++)
					{
						sAlert += "," + listMobs[i];
					}
				}
				
				sAlert =  "正准备发送彩信给“" + sAlert + "”等" + (listMobs.length - 1).toString() +  "人，是否发送？";
			}
			
			Alert.show(sAlert,"民建信息服务管理平台",Alert.YES | Alert.NO,null,closeHandle,ICON_ALERT);
			
			function closeHandle(event:CloseEvent):void
			{			
				if(event.detail == Alert.YES)
				{
					mmsProxy.send(popupSendMMS.MMS);
				}
			}
		}
		
		private function onSave(event:Event):void
		{
			popupSendMMS.MMS.phone = popupSendMMS.panelSelectContact.mobs;
			popupSendMMS.MMS.people = popupSendMMS.panelSelectContact.names;
			
			if(popupSendMMS.MMS.name != "")
			{
				mmsProxy.save(popupSendMMS.MMS);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入彩信主题！");
			}
		}
		
		private function onErrorWord(event:Event):void
		{			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
			
			sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"Word导入失败，请检查Word文件格式是否正确！");
		}
		
		private function onOpenWord(event:Event):void
		{			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"正在导入Word文件！");
		}
		
		private function onSetWord(event:Event):void
		{			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
			
			sendNotification(AppNotification.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupSendMMSMediator.NAME).getViewComponent(),popupSendMMS.MMS]);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_POPUP_SHOW,
				AppNotification.NOTIFY_MMS_FILE
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var groupProxy:GroupProxy = facade.retrieveProxy(GroupProxy.NAME) as GroupProxy;	
			var contactProxy:ContactProxy = facade.retrieveProxy(ContactProxy.NAME) as ContactProxy;
			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_POPUP_SHOW:
					var params:Array = notification.getBody() as Array;
					if(params[0] == popupSendMMS)
					{						
						var paramMMS:MMSVO = params[1];
						
						popupSendMMS.panelSelectContact.setListContact(groupProxy.list,contactProxy.listAll,paramMMS.phone);	
						
						popupSendMMS.view.removeAllChildren();
						
						popupSendMMS.MMS.copy(paramMMS);
						
						if(popupSendMMS.MMS.ID != "-1")
						{
							mmsProxy.getMMS(popupSendMMS.MMS);
						}
						else
						{
							var navi:NavigatorContent = new NavigatorContent;						
							var par:PanelMMSPar = new PanelMMSPar;
							navi.label = "第1页";
							navi.addElement(par);
							
							popupSendMMS.view.addItem(navi);
							popupSendMMS.MMS.pares.addItem(par.MMSPar);
						}
					}
					break;
				
				case AppNotification.NOTIFY_MMS_FILE:
					var xml:XML = notification.getBody() as XML;
					
					namespace w3c = "http://www.w3.org/2000/SMIL20/CR/Language";  					
					use namespace w3c;   
					
					var titleUrl:String = WebServiceCommand.WSDL + "MMS/F" + popupSendMMS.MMS.ID + "/title.txt";
					popupSendMMS.MMS.downTitle(titleUrl);
					
					popupSendMMS.MMS.pares.removeAll();
					
					var index:Number = 0;
					for each(var xmlPar:XML in xml.w3c::body.w3c::par)
					{
						index ++;
						
						navi = new NavigatorContent;						
						par = new PanelMMSPar;
						navi.label = "第"+index.toString()+"页";
						navi.addElement(par);
						
						popupSendMMS.view.addItem(navi);
						popupSendMMS.MMS.pares.addItem(par.MMSPar);
						
						var dur:String = String(xmlPar.@dur);						
						par.MMSPar.dur = Number(dur.substr(0,dur.length - 1));
						
						if(xmlPar.w3c::img != undefined)
						{
							var imgUrl:String = WebServiceCommand.WSDL + "MMS/F" + popupSendMMS.MMS.ID + "/" + xmlPar.w3c::img.@src;
							par.MMSPar.imgName = xmlPar.w3c::img.@src;
							par.MMSPar.downImg(imgUrl);
						}
						
						if(xmlPar.w3c::text != undefined)
						{
							var textUrl:String = WebServiceCommand.WSDL + "MMS/F" + popupSendMMS.MMS.ID + "/" + xmlPar.w3c::text.@src;
							par.MMSPar.downText(textUrl);
						}
					}
					break;
			}
		}
				
		private function initTree(phone:String):XML
		{
			var groupProxy:GroupProxy = facade.retrieveProxy(GroupProxy.NAME) as GroupProxy;			
			var xml:XML = groupProxy.listXML;
			
			for each(var item:XML in xml.children()) 
			{
				var group:GroupVO = groupProxy.getGroupByID(item.@id);
				
				for each(var contact:ContactVO in (facade.retrieveProxy(ContactProxy.NAME) as ContactProxy).listAll)
				{
					if(group.containContact(contact))
					{
						var newXML:XML = <node/>;
						newXML.@id = contact.id;
						newXML.@selected = (phone.indexOf(contact.phone) >= 0)?"true":"false";
						newXML.@type = "contact";
						newXML.@phone = contact.phone;
						newXML.@label = contact.name;
						
						/*for each(var phone:ContactVO in listPhone)
						{
						if(phone.id == contact.id)
						{								
						newXML.@selected = "true";
						break;
						}
						}*/
						
						item.appendChild(newXML);	
					}
				}
			}
			
			return xml;
		}
	}
}