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
using Gee;

public class rrd.command_graph_rpn : rrd.argument {

	protected const rrd.argument_entry[] RPN_ARGUMENT_ENTRIES = {
		{ "vname",   0,
		  "rrdvalue_string",
		  null,
		  true,
		  "the vname of this data"
		},
		{ "rpn", 0,
		  "rrdvalue_rpn",
		  null,
		  true,
		  "the filename of the rrd file"
		}
	};

	protected override rrd.argument_entry[] getArgumentEntries()
	{ return RPN_ARGUMENT_ENTRIES; }

	protected override bool modifyOptions(
		LinkedList<string> positional)
	{
		/* check if rrdfile and vname are defined
		 * then the "normal" positional rules apply
		 */
		if (hasOption("vname")) {
			return true;
		}
		if (hasOption("rpn")) {
			return true;
		}

		/* otherwise we need to take the first positional argument
		 * and split it ourselves to ket vname=rrdfile
		 */
		if (positional.size==0) {
			stderr.printf(
				"no rrdfile or vname defined and no "
				+ "positional arguments given!\n");
			return false;
		}

		/* so let us get a peak at the first positional arg */
		var pos0=positional.get(0);
		/* and split it */
		var keyval = pos0.split("=",2);
		/* if no =, then we return an error */
		if (keyval.length != 2) {
			stderr.printf(
				"the positional argument %s"
				+ " does not contain =\n",
				pos0);
			return false;
		}

		/* so we got key,value, so assign it */
		setOption("vname",keyval[0]);
		setOption("rpn",keyval[1]);

		/* as we have been successfull we can strip it
		 * from the position list now */
		positional.remove_at(0);
		/* and return successfull */
		return true;
	}

	protected rrd.value cached_result = null;
	public override rrd.value? getValue(
		rrd.command cmd,
		rrd.rpn_stack? stack = null)
	{
		/* take from cache */
		if (cached_result != null)  {
			return cached_result;
		}
		/* otherwise take from rpn itself */
		cached_result = getOptionValue("rpn",cmd);

		/* and return it */
		return cached_result;
	}

	protected override void linkToCommandFullName(
		rrd.command command,
		string prefix)
	{
		command.setOption(
			prefix,
			getOption("rpn")
			);
	}

}
