using GLib;
using Gee;

public class rrd.command_graph : rrd.command {
//	protected Cairo.ImageSurface surface = null;
//	protected Cairo.Context context = null;

	protected const rrd.argument_entry[] COMMAND_ARGUMENT_ENTRIES = {
		{ "imagefile", 0, "rrdvalue_string", null, true,
		  "filename to create", "<filename>"
		},
		{ "imgformat", 'a', "rrdvalue_string", "PNG", false,
		  "type of image", "<title>"
		},
		{ "width", 'w', "rrdvalue_rpn", "600", false,
		  "given width", "<width in pixel>"
		},
		{ "height", 'h', "rrdvalue_rpn", "200", false,
		  "given height", "<height in pixel>"
		},
		{ "start", 's', "rrdvalue_timestamp", "-1day", false,
		  "start time", "<timestamp>"
		},
		{ "step", 'S', "rrdvalue_rpn", "end,start,-,width,/", false,
		  "step time", "<seconds>"
		},
		{ "end", 'e', "rrdvalue_timestamp", "now", false,
		  "end time", "<timestamp>"
		},
		{ "only-graph", 'j', "rrdvalue_flag", "0", false,
		  "only create the graph"
		},
		{ "full-size-mode", 'D', "rrdvalue_flag", "0", false,
		  "do the frame calculation based on global sizes"
		},
		{ "title", 't', "rrdvalue_string", null, false,
		  "title to print on top of graph", "<title>"
		}
	};

	protected override rrd.argument_entry[]? getCommandOptions()
	{ return COMMAND_ARGUMENT_ENTRIES; }

	/* the execution method */
	public override bool execute() {
		stderr.printf("rrdcommand_graph.execute()\n");
		dump();

		return true;
	}

}
