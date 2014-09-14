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

	/* the execution method */
	public override bool execute() {
		stderr.printf("rrd_command_graph.execute()\n");

		foreach(var kv in parsed_args) {
			stderr.printf("  Args: %s = %s\n",
				kv.key,kv.value);
		}

		return true;
	}

}
