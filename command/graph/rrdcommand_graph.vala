/* rrdcommand_graph.vala
 *
 * Copyright (C) 2014 Martin Sperl
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *
 * Author:
 * Martin Sperl <rrdtool@martin.sperl.org>
 */
using Cairo;

/**
 * the graph command implementation
 */
public class rrd.command_graph : rrd.command {
	/**
	 * the defined fields
	 */
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

	/**
	 * return the defined option fields
	 * @return array of rrd.argument_entry[]
	 */
	protected override rrd.argument_entry[] getCommandOptions()
	{ return COMMAND_ARGUMENT_ENTRIES; }

	/**
	 * delegate to subclasses - depending on the parameters
         * @return the current intance or an instance to use
	 */
	public override rrd.object? delegate() {
		string cname=this.get_type().name();

		if( strcmp(cname,"rrdcommand_graph") == 0) {
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
		}
		/* parse the remaining positional arguments */
		if (! parsePositionalArguments()) {
			/* on error return null */
			return null;
		}
		/* return this */
		return this;
	}

	/**
	 * the cairo image surface used for drawing
	 * strangely these can't be protected or public
	 */
	protected ImageSurface surface = null;
	/**
	 * the cairo context used for drawing
	 * strangely these can't be protected or public
	 */
	protected Context context = null;

	/**
	 * creates a graph
	 * @return true on success
	 */
	public override bool execute() {
		/* depending on full sized mode maybe move things arround
		 *  worsted case we may need to reparse the whole thing
		 * to get different defaults...
		 */

		/* get the effective width and height */
		int width = 600;
		int height = 200;
		/* now create the graph contexts */
#if true
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
#endif

		/* and start processing */

		stderr.printf("rrdcommand_graph.execute()\n");
		dump();

		/* try to calculate the effective width and height */

		return true;
	}
}
