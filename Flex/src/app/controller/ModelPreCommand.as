package app.controller
{
	import app.model.AppConfigProxy;
	import app.model.ContactProxy;
	import app.model.GroupProxy;
	import app.model.InboxProxy;
	import app.model.MMSProxy;
	import app.model.OutboxFProxy;
	import app.model.OutboxSProxy;
	import app.model.PhraseGroupProxy;
	import app.model.PhraseProxy;
	import app.model.SMS_DraftProxy;
	import app.model.SocketProxy;
	import app.model.TaskProxy;
	import app.model.vo.HolidayProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.Application;
	
	public class ModelPreCommand extends SimpleCommand
	{
		override public function execute(note:INotification):void
		{
			facade.registerProxy(new AppConfigProxy);
			
			facade.registerProxy(new SocketProxy);
			
			facade.registerProxy(new GroupProxy);
			facade.registerProxy(new ContactProxy);
			facade.registerProxy(new TaskProxy);
			facade.registerProxy(new SMS_DraftProxy);
			facade.registerProxy(new InboxProxy);
			facade.registerProxy(new OutboxSProxy);
			facade.registerProxy(new OutboxFProxy);
			facade.registerProxy(new PhraseGroupProxy);
			facade.registerProxy(new PhraseProxy);
			facade.registerProxy(new HolidayProxy);
			
			facade.registerProxy(new MMSProxy);
		}
	}
}