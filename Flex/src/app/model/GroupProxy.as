package app.model
{
	import app.model.vo.GroupVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class GroupProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "GroupProxy";
		
		public function GroupProxy()
		{
			super(NAME, new ArrayCollection);
		}
		
		public function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		public function get listXML():XML
		{
			var xml:XML = <node label="所有会员" type="root"/>;
			for each(var group:GroupVO in list)
			{
				var newXML:XML = <node/>;
				newXML.@id = group.id;
				newXML.@selected = "false";
				newXML.@type = "group";
				newXML.@label = group.label;
				xml.appendChild(newXML);
			}
			return xml;
		}
		
		public function get nextID():String
		{
			var max:Number = 0;
			for each(var group:GroupVO in list)
			{
				max = Math.max(Number(group.id),max);
			}
			
			return (max + 1).toString();
		}
		
		public function getGroupByID(id:String):GroupVO
		{
			for each(var item:GroupVO in list)
			{
				if(item.id == id)
				{
					return item;
				}
			}
			
			return null;
		}
	}
}