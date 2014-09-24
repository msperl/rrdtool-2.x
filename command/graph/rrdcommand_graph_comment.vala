/* rrdcommand_graph_rpn.vala
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
 * the comment argument to graph
 */
public class rrd.command_graph_comment : rrd.argument {
	/**
	 * the defined fields
	 */
	protected const rrd.argument_entry[] DEF_ARGUMENT_ENTRIES = {
		{ "label",   0,
		  "rrdvalue_string",
		  null,
		  true,
		  "the label to draw at the current coordinates",
		  "<string>"}
	};

	/**
	 * return the defined option fields
	 * @return array of rrd.argument_entry[]
	 */
	protected override rrd.argument_entry[] getArgumentEntries()
	{ return DEF_ARGUMENT_ENTRIES; }

}
