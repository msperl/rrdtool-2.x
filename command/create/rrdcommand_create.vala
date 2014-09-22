using GLib;
using Gee;

public class rrd.command_create : rrd.command {

	/* the command arguments */
	protected const rrd.argument_entry[] COMMAND_ARGUMENT_ENTRIES = {
		{ "start", 's', "rrdvalue_timestamp", "-1day", false,
		  "start time", "<timestamp>"
		},
		{ "step", 'S', "rrdvalue_rpn", "300", false,
		  "step time", "<seconds>"
		}
	};

	protected override rrd.argument_entry[] getCommandOptions()
	{ return COMMAND_ARGUMENT_ENTRIES; }

	/* the execution method */
	public override bool execute() {
		stderr.printf("rrdcommand_create.execute()\n");
		return true;
	}

}
