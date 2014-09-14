using GLib;
using Gee;

class rrd_command_create : rrd_command {

	/* the command arguments */
	protected const OptionEntry[] command_options = {
		/* format: long option, short option char, flags, argstype,
		 * argdata,description,arg_description)
		 */
		{ "start",'b',0,OptionArg.CALLBACK,
		  (void *)optionCallback,
		  "start",
		  ""},
		{ "step",'s',0,OptionArg.CALLBACK,
		  (void *)optionIncreaseCallback,
		  "step",
		  ""},
		{ null }
	};
	protected override OptionEntry[]? getCommandOptions()
	{ return command_options; }

	/* the execution method */
	public override bool execute() {
		stderr.printf("rrd_command_create.execute()\n");
		return true;
	}

}
