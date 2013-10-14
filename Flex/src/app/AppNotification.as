package app
{
	public final class AppNotification
	{
		/**
		 *访问WebService
		 */		
		public static const NOTIFY_WEBSERVICE_SEND:String			= "WebServiceSend";
				
		
		/**
		 *弹出错误提示框 
		 */		
		public static const NOTIFY_APP_ALERTERROR:String			= "AppAlertError";
		
		/**
		 *弹出警告提示框 
		 */		
		public static const NOTIFY_APP_ALERTALARM:String			= "AppAlertAlarm";
		
		/**
		 *弹出信息提示框 
		 */		
		public static const NOTIFY_APP_ALERTINFO:String				= "AppAlertInfo";
				
		
		
		/**
		 *程序控制-显示Loading
		 */		
		public static const NOTIFY_APP_LOADINGSHOW:String			= "AppLoadingShow";
		
		/**
		 *程序控制-隐藏Loading
		 */		
		public static const NOTIFY_APP_LOADINGHIDE:String			= "AppLoadingHide";
										
		/**
		 *权限验证成功
		 */		
		public static const NOTIFY_INIT_AUTH:String					= "InitAuth";
		
		/**
		 *程序初始化完成
		 */		
		public static const NOTIFY_APP_INIT:String					= "APP_INIT";
		
		/**
		 *窗口大小变化
		 */		
		public static const NOTIFY_APP_RESIZE:String					= "APP_RESIZE";
		
		/**
		 *菜单 事件 
		 */			
		public static const NOTIFY_MENU:String						= "Menu";
		
		/**
		 *菜单 事件  - 隐藏子菜单
		 */			
		public static const NOTIFY_MENU_SUBHIDE:String				= "Menu_HideSub";
		
		/**
		 *树点击事件
		 */		
		public static const NOTIFY_SUBPANEL:String					= "SubPanel";
		
		/**
		 *打开弹出面板
		 */		
		public static const NOTIFY_POPUP_SHOW:String				= "Popup_Show";
		
		/**
		 *关闭弹出面板
		 */		
		public static const NOTIFY_POPUP_HIDE:String				= "Popup_Hide";
		
		/**
		 *改变节点
		 */		
		//public static const NOTIFY_TREE_NODECHANGE:String			= "Tree_NodeChange";
		
		/**
		 *添加组
		 */		
		public static const NOTIFY_GROUP_ADD:String					= "Group_Add";
		
		/**
		 *会员列表
		 */		
		public static const NOTIFY_CONTACT_ALL:String				= "Contact_ListAll";
		
		/**
		 *会员列表
		 */		
		public static const NOTIFY_CONTACT_LIST:String				= "Contact_List";
		
		/**
		 *添加会员
		 */		
		//public static const NOTIFY_CONTACT_ADD:String				= "Contact_Add";
		
		/**
		 *删除会员
		 */		
		//public static const NOTIFY_CONTACT_DELETE:String			= "Contact_Delete";
		
		/**
		 *获得彩信
		 */		
		public static const NOTIFY_MMS_FILE:String					= "MMS_File";
		
		/**
		 *获得彩信
		 */		
		public static const NOTIFY_SYS_SETTING:String				= "sys_setting";
	}
}