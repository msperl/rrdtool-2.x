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

	/* the positional Argument Parser */
	protected override  void
		parsePositionalArguments(ArrayList<string> args)
	{
		foreach(var arg in parsed_args) {
			stdout.printf("rrd_command_create.parsed_args=%s=%s\n",
				arg.key,arg.value);
		}
		foreach(var arg in args) {
			stdout.printf("rrd_command_create.args=%s\n",arg);
		}
	}

	/* the execution method */
	public override bool execute() {
		stdout.printf("rrd_command_create.execute()\n");
		return true;
	}

}
