package app.model.vo
{
	[Bindable]
	public class ContactVO
	{
		public static const groupPost:Array = new Array('主委','副主委','秘书长','主任','副主任','常委','委员','成员');
		public var id:String = "-1";
		
		public var name:String = "";
		public var sex:String = "";
		public var birth:String = "";
		public var education:String = "";
		
		public var unit:String = "";
		public var post:String = "";
		public var phone:String = "";
		
		public var unit_addr:String = "";
		public var unit_phone:String = "";
		public var home_addr:String = "";
		public var home_phone:String = "";
		
		public var mail:String = "";
		
		public var branch:String = "";
		public var group:String = "";
		public var grouppost:String = "";
		
		//public var user_group:String = "";
		
		public var selected:Boolean = false;
		
		public function ContactVO()
		{
		}
		
		public function copy(contact:ContactVO):void
		{
			this.id = contact.id;
			this.name = contact.name;
			this.sex = contact.sex;
			this.birth = contact.birth;
			this.education = contact.education;
			
			this.unit = contact.unit;
			this.post = contact.post;
			this.phone = contact.phone;
			
			this.unit_addr = contact.unit_addr;
			this.unit_phone = contact.unit_phone;
			this.home_addr = contact.home_addr;
			this.home_phone = contact.home_phone;
			
			this.mail = contact.mail;
			
			this.branch = contact.branch;
			this.group = contact.group;
			this.grouppost = contact.grouppost;
			
			//this.selected = contact.selected;
		}
	}
}