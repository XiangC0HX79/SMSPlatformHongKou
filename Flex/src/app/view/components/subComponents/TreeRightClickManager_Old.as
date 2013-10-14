package app.view.components.subComponents
{
	import flash.display.InteractiveObject;
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	public class TreeRightClickManager_Old
	{
		static private var rightClickTarget:*;
		static public const RIGHT_CLICK:String = "rightClick";
		static private const javascript:XML = 
			<script>
				<![CDATA[
					function(flashObjectId)
					{                
						var RightClick = {
								init: function (flashObjectId) {
								this.FlashObjectID = flashObjectId;
								this.Cache = this.FlashObjectID;
								if(window.addEventListener){
									 window.addEventListener("mousedown", this.onGeckoMouse(), true);
								} else {
									document.getElementById(this.FlashObjectID).parentNode.onmouseup = function() { document.getElementById(RightClick.FlashObjectID).parentNode.releaseCapture(); }
									document.oncontextmenu = function(){ if(window.event.srcElement.id == RightClick.FlashObjectID) { return false; } else { RightClick.Cache = "nan"; }}
									document.getElementById(this.FlashObjectID).parentNode.onmousedown = RightClick.onIEMouse;
								}
							},
							/**
							 * GECKO / WEBKIT event overkill
							 * @param {Object} eventObject
							 */
							killEvents: function(eventObject) {
								if(eventObject) {
									if (eventObject.stopPropagation) eventObject.stopPropagation();
									if (eventObject.preventDefault) eventObject.preventDefault();
									if (eventObject.preventCapture) eventObject.preventCapture();
									   if (eventObject.preventBubble) eventObject.preventBubble();
								}
							},
							/**
							 * GECKO / WEBKIT call right click
							 * @param {Object} ev
							 */
							onGeckoMouse: function(ev) {
								  return function(ev) {
								if (ev.button != 0) {
									RightClick.killEvents(ev);
									if(ev.target.id == RightClick.FlashObjectID && RightClick.Cache == RightClick.FlashObjectID) {
										RightClick.call();
									}
									RightClick.Cache = ev.target.id;
								}
							  }
							},
							/**
							 * IE call right click
							 * @param {Object} ev
							 */
							onIEMouse: function() {
								  if (event.button > 1) {
									if(window.event.srcElement.id == RightClick.FlashObjectID && RightClick.Cache == RightClick.FlashObjectID) {
										RightClick.call(); 
									}
									document.getElementById(RightClick.FlashObjectID).parentNode.setCapture();
									if(window.event.srcElement.id)
									RightClick.Cache = window.event.srcElement.id;
								}
							},
							/**
							 * Main call to Flash External Interface
							 */
							call: function() {
								document.getElementById(this.FlashObjectID).rightClick();
							}
						}
						
						RightClick.init(flashObjectId);
					}
				]]>
			</script>;
		
		public function TreeRightClickManager_Old()
		{
		}
		
		static public function regist() : Boolean
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call(javascript, ExternalInterface.objectID);
				ExternalInterface.addCallback("rightClick", dispatchRightClickEvent);
				//Application.application.addEventListener(MouseEvent.MOUSE_OVER,mouseOverHandler);
				FlexGlobals.topLevelApplication.addEventListener(MouseEvent.MOUSE_OVER,mouseOverHandler);
				
			}
			return true;
		}
		
		static private function mouseOverHandler(event:MouseEvent) : void
		{
			rightClickTarget = InteractiveObject(event.target);  
			return;  
		}
		
		static private function dispatchRightClickEvent() : void
		{
			var event:ContextMenuEvent;
			if(rightClickTarget !=null)  
			{  
				event =new ContextMenuEvent(RIGHT_CLICK,true,false, rightClickTarget as InteractiveObject, rightClickTarget as InteractiveObject);  
				rightClickTarget.dispatchEvent(event);  
			}
			return;
		}
	}
}