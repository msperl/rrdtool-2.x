using GLib;
using Gee;

class rrd_command_graph : rrd_command {

	/* the common arguments */
	protected const OptionEntry[] COMMAND_OPTIONS = {
		/* format: long option, short option char, flags, argstype,
		 * argdata,description,arg_description)
		 */
		{ "width",'w',0,OptionArg.CALLBACK,
		  (void *)optionCallback,
		  "width",
		  ""},
		{ "height",'h',0,OptionArg.CALLBACK,
		  (void *)optionCallback,
		  "height",
		  ""},
		{ "start",'s',0,OptionArg.CALLBACK,
		  (void *)optionCallback,
		  "start",
		  ""},
		{ "step",'S',0,OptionArg.CALLBACK,
		  (void *)optionIncreaseCallback,
		  "step",
		  ""},
		{ "end",'e',0,OptionArg.CALLBACK,
		  (void *)optionCallback,
		  "end",
		  ""},
		{ "only-graph",'j',0,OptionArg.CALLBACK,
		  (void *)optionCallback,
		  "only-graph",
		  ""},
		{ "full-size-mode",'D',0,OptionArg.CALLBACK,
		  (void *)optionCallback,
		  "full-size-mode",
		  ""},
		{ "title",'t',0,OptionArg.CALLBACK,
		  (void *)optionCallback,
		  "title",
		  ""},
		{ null }
	};

	protected override OptionEntry[]? getCommandOptions()
	{ return COMMAND_OPTIONS; }

	/* the positional Argument Parser */
	protected override  void
		parsePositionalArguments(ArrayList<string> args)
	{
		foreach(var arg in parsed_args) {
			stdout.printf("rrd_command_graph.parsed_args=%s=%s\n",
				arg.key,arg.value);
		}
		foreach(var arg in args) {
			stdout.printf("rrd_command_graph.args=%s\n",arg);
		}
	}

	/* the execution method */
	public override bool execute() {
		stdout.printf("rrd_command_graph.execute()\n");
		return true;
	}

}
