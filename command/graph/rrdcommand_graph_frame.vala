/* rrdcommand_graph_tsgraph.vala
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

/**
 * the frame implementation
 */
public class rrd.command_graph_frame : rrd.argument {
	/**
	 * the defined fields
	 */
	protected const rrd.argument_entry[] GRAPH_ARGUMENT_ENTRIES = {
		{ "x",        0, "rrdvalue_rpn",
		  "0",
		  false, "the starting x coordinate of the graph"
		},
		{ "y",        0, "rrdvalue_rpn",
		  "0",
		  false, "the starting y coordinate of the graph"
		},
		{ "width",    0, "rrdvalue_rpn",
		  "!xend,!x,-",
		  false, "the width of this graph"
		},
		{ "height",   0, "rrdvalue_rpn",
		  "!yend,!y,-",
		  false, "the height of this graph"
		},
		{ "xend",   0, "rrdvalue_rpn",
		  "!x,!width,+",
		  false, "the height of this graph"
		},
		{ "yend",   0, "rrdvalue_rpn",
		  "!y,!height,+",
		  false, "the height of this graph"
		}

	};

	/**
	 * return the defined option fields
	 * @return array of rrd.argument_entry[]
	 */
	protected override rrd.argument_entry[] getArgumentEntries()
	{ return GRAPH_ARGUMENT_ENTRIES; }
}
