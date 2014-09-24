using GLib;
using Gee;
using Cairo;

public class rrd.command_graph : rrd.command {
	/* strangely these can be protected or public */
	private ImageSurface surface = null;
	private Context context = null;

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
		{ "only-graph", 'j', "rrdvalue_bool", "false", false,
		  "only create the graph"
		},
		{ "full-size-mode", 'D', "rrdvalue_bool", "false", false,
		  "do the frame calculation based on global sizes"
		},
		{ "title", 't', "rrdvalue_string", null, false,
		  "title to print on top of graph", "<title>"
		}
	};

	protected override rrd.argument_entry[] getCommandOptions()
	{ return COMMAND_ARGUMENT_ENTRIES; }

	/* the execution method */
	public override bool execute() {
		/* depending on full sized mode maybe move things arround
		 *  worsted case we may need to reparse the whole thing
		 * to get different defaults...
		 */

		/* get the effective width and height */
		int width = 600;
		int height = 200;
		/* now create the graph contexts */
		surface = new ImageSurface(
			Cairo.Format.RGB24,
			width,
			height);
		context = new Context(surface);

		var imgfile = getOption("imagefile");
		if (imgfile == null) {
			return false;
		}
		surface.write_to_png(imgfile.to_string());

		/* and start processing */

		stderr.printf("rrdcommand_graph.execute()\n");
		dump();

		/* try to calculate the effective width and height */

		return true;
	}

	public override rrd.object? delegate() {
		/* handle full size in a special class */
		if (hasOption("full-size-mode")) {
			var flag = (rrd.value_bool)
				getOption("full-size-mode");
			if ( flag.to_bool() ) {
				return (rrd.command) classFactory(
					"rrdcommand_graphfullsize",
					"rrdcommand",
					"parent",this
					);
			}
		}
		/* andle only-graph in a special class */
		if (hasOption("only-graph")) {
			var flag = (rrd.value_bool)
				getOption("only-graph");
			if ( flag.to_bool() ) {
				return (rrd.command) classFactory(
					"rrdcommand_graphonly",
					"rrdcommand",
					"parent",this
					);
			}
		}
		/* handle others */

		return this;
	}
}
