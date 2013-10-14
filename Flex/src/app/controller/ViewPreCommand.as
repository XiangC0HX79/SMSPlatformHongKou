package app.controller
{	
	import app.view.AppAlertMediator;
	import app.view.ApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.Application;
	
	public class ViewPreCommand extends SimpleCommand
	{
		override public function execute(note:INotification):void
		{
			var application:Application = note.getBody() as Application;
						
			facade.registerMediator(new AppAlertMediator);
			
			facade.registerMediator(new ApplicationMediator(application));
						
			application.styleManager.getStyleDeclaration("mx.controls.ToolTip").setStyle("fontWeight","bold");
			application.styleManager.getStyleDeclaration("mx.controls.ToolTip").setStyle("fontSize","14");
			application.styleManager.getStyleDeclaration("mx.controls.ToolTip").setStyle("fontFamily","Arial");
			application.styleManager.getStyleDeclaration("mx.controls.ToolTip").setStyle("color","black");
			application.styleManager.getStyleDeclaration("mx.controls.ToolTip").setStyle("backgroundColor","#A8A8A8");
		}
	}
}