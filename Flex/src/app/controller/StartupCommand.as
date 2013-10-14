package app.controller
{	
	//import app.view.components.subComponents.TreeRightClickManager;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.patterns.command.MacroCommand;
	
	import spark.components.Application;
	
	public class StartupCommand extends MacroCommand implements ICommand
	{
		override protected function initializeMacroCommand():void
		{
			//TreeRightClickManager.regist();  
			
			addSubCommand(ModelPreCommand);
			addSubCommand(ViewPreCommand);
			
			addSubCommand(LocalConfigCommand);
		}
	}
}