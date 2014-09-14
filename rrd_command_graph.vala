using GLib;
using Gee;

class rrd_command_graph : rrd_command {

	protected const rrd_argument_entry[] COMMAND_ARGUMENT_ENTRIES = {
		{ "width",
		  'w',
		  rrd_value_type.RPN,
		  false,
		  "600",
		  "given width",
		  "<width in pixel>"
		},
		{ "height",
		  'h',
		  rrd_value_type.RPN,
		  false,
		  "200",
		  "given height",
		  "<height in pixel>"
		},
		{ "start",
		  's',
		  rrd_value_type.TIMESTAMP,
		  false,
		  "-1day",
		  "start time",
		  "<timestamp>"
		},
		{ "step",
		  'S',
		  rrd_value_type.RPN,
		  false,
		  "300",
		  "start time",
		  "<timestamp>"
		},
		{ "end",
		  'e',
		  rrd_value_type.TIMESTAMP,
		  false,
		  "-1day",
		  "start time",
		  "<timestamp>"
		},
		{ "only-graph",
		  'j',
		  rrd_value_type.FLAG,
		  false,
		  "0",
		  "only create the graph",
		  null
		},
		{ "full-size-mode",
		  'D',
		  rrd_value_type.FLAG,
		  false,
		  "0",
		  "only create the graph",
		  null
		},
		{ "title",
		  't',
		  rrd_value_type.STRING,
		  false,
		  null,
		  "title to print on top of graph",
		  "<title>"
		}
	};

	protected override rrd_argument_entry[]? getCommandOptions()
	{ return COMMAND_ARGUMENT_ENTRIES; }

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
