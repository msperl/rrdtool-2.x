using GLib;
using Gee;

public class rrd_command_create : rrd_command {

	/* the command arguments */
	protected const rrd_argument_entry[] COMMAND_ARGUMENT_ENTRIES = {
		{ "start", 's', "rrd_value_timestamp", "-1day", false,
		  "start time", "<timestamp>"
		},
		{ "step", 'S', "rrd_value_rpn", "300", false,
		  "step time", "<seconds>"
		}
	};

	protected override rrd_argument_entry[]? getCommandOptions()
	{ return COMMAND_ARGUMENT_ENTRIES; }

	/* the execution method */
	public override bool execute() {
		stderr.printf("rrd_command_create.execute()\n");
		return true;
	}

}
