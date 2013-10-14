package app.model.vo
{
	[Bindable]
	public class GroupVO
	{
		public var id:String;
		
		public var label:String;	
		public var type:String;	
		
		public var selected:Boolean;	
		
		public function GroupVO()
		{
		}
		
		public function containContact(contact:ContactVO):Boolean
		{						
			return (contact.group.indexOf(label) != -1);
		}
	}
}