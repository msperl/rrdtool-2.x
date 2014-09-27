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
 * the rpn argument to graph
 */
public class rrd.command_graph_rpn : rrd.argument {
	/**
	 * the defined fields
	 */
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

	/**
	 * return the defined option fields
	 * @return array of rrd.argument_entry[]
	 */
	protected override rrd.argument_entry[] getArgumentEntries()
	{ return RPN_ARGUMENT_ENTRIES; }

	/**
	 * prepare for positional arguments
	 * splitting/filling in some fields from positional arguments.
	 * the reason is the name=rpn convention, where
	 * name is not predictable.
	 * @param postitional the positional/unparsed arguments
	 * @return true if no issues
	 */
	protected override bool modifyOptions()
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
		if (args.size==0) {
			stderr.printf(
				"no rrdfile or vname defined and no "
				+ "positional arguments given!\n");
			return false;
		}

		/* so let us get the first positional arg */
		var pos0=args.poll_head();
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

		/* and return successfull */
		return true;
	}

	/**
	 * calculate the value and return it
	 * no need to cache it, as the getOptionValue(rpn)
	 * does the caching work necessary
	 * @param cmd   the command to which this belongs
	 * @param stack the rpn_stack to work with - if null, then this is
	 *              not part of a rpn calculation
	 * @returns rrd_value with the value given - may be this
	 */
	public override rrd.value? getValue(
		rrd.command cmd,
		bool skipcalc,
		rrd.rpn_stack? stack = null)
	{
		/* otherwise take from rpn itself */
		return getOptionValue("rpn",cmd);
	}

	/**
	 * override the linkToCommandFullName,
	 * so that we directly link the rpn for processing
	 * cutting short on the above
	 */
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
