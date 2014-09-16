using GLib;
using Gee;

public class rrd_command_graph : rrd_command {

	protected const rrd_argument_entry[] COMMAND_ARGUMENT_ENTRIES = {
		{ "width",
		  'w',
		  "rrd_value_rpn",
		  "600",
		  false,
		  "given width",
		  "<width in pixel>"
		},
		{ "height",
		  'h',
		  "rrd_value_rpn",
		  "200",
		  false,
		  "given height",
		  "<height in pixel>"
		},
		{ "start",
		  's',
		  "rrd_value_timestamp",
		  "-1day",
		  false,
		  "start time",
		  "<timestamp>"
		},
		{ "step",
		  'S',
		  "rrd_value_rpn",
		  "end,start,-,width,/",
		  false,
		  "step time",
		  "<seconds>"
		},
		{ "end",
		  'e',
		  "rrd_value_timestamp",
		  "now",
		  false,
		  "end time",
		  "<timestamp>"
		},
		{ "only-graph",
		  'j',
		  "rrd_value_flag",
		  "0",
		  false,
		  "only create the graph"
		},
		{ "full-size-mode",
		  'D',
		  "rrd_value_flag",
		  "0",
		  false,
		  "do the frame calculation based on global sizes"
		},
		{ "title",
		  't',
		  "rrd_value_string",
		  null,
		  false,
		  "title to print on top of graph",
		  "<title>"
		}
	};

	protected override rrd_argument_entry[]? getCommandOptions()
	{ return COMMAND_ARGUMENT_ENTRIES; }

	/* the execution method */
	public override bool execute() {
		stderr.printf("rrd_command_graph.execute()\n");
		dump();

		return true;
	}

}
