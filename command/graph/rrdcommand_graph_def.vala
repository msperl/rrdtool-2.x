/* rrdcommand_graph_def.vala
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

public class rrd.command_graph_def : rrd.argument {

	protected const rrd.argument_entry[] DEF_ARGUMENT_ENTRIES = {
		{ "vname",   0,
		  "rrdvalue_string",
		  null,
		  true,
		  "the vname of this data"
		},
		{ "rrdfile", 0,
		  "rrdvalue_string",
		  null,
		  true,
		  "the filename of the rrd file"
		},
		{ "rrdfield",  0,
		  "rrdvalue_string",
		  null,
		  true,
		  "the field inside the rrd file"
		},
		{ "cf",      0,
		  "rrdvalue_string",
		  "AVG",
		  true,
		  "the consolidation function to use"
		},
		{ "start",   0,
		  "rrdvalue_rpn",
		  "start",
		  false,
		  "the start time for the def"
		},
		{ "step",   0,
		  "rrdvalue_rpn",
		  "step",
		  false,
		  "the time steps for the def"
		},
		{ "end",   0,
		  "rrdvalue_rpn",
		  "end",
		  false,
		  "the end time for the def"
		},
		{ "reduce",      0,
		  "rrdvalue_string",
		  "",
		  false,
		  "the reduction consolidation function to use"
		}
	};

	protected override rrd.argument_entry[] getArgumentEntries()
	{ return DEF_ARGUMENT_ENTRIES; }

	/**
	 * prepare for positional arguments
	 * splitting/filling in some fields from positional arguments.
	 * the reason is the name=filename convention, where
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
		if (hasOption("rrdfile")) {
			return true;
		}

		/* otherwise we need to take the first positional argument
		 * and split it ourselves to ket vname=rrdfile
		 */
		if (args.size==0) {
			rrd.error.setErrorString(
				"no rrdfile or vname defined and no "
				+ "positional arguments given!");
			return false;
		}

		/* so let us get the first positional arg */
		var pos0=args.poll_head();
		/* and split it */
		var keyval = pos0.split("=",2);
		/* if no =, then we return an error */
		if (keyval.length != 2) {
			rrd.error.setErrorString(
				"the positional argument %s does not contain ="
				.printf(pos0)
				);
			return false;
		}

		/* so we got key,value, so assign it */
		setOption("vname",keyval[0]);
		setOption("rrdfile",keyval[1]);

		/* and return successfull */
		return true;
	}

	protected rrd.value_timestring cached_result = null;

	public override rrd.value? getValue(
		rrd.command cmd,
		rrd.rpn_stack? stack = null)
	{
		if (cached_result != null)  {
			return cached_result;
		}
		/* the start/step/end values */
		rrd.value_timestamp start =
			(rrd.value_timestamp) getOptionValue(
				"start", cmd);
		rrd.value_number step =
			(rrd.value_number) getOptionValue(
				"step", cmd);
		rrd.value_timestamp end =
			(rrd.value_timestamp) getOptionValue(
				"end", cmd);

		/* the information that is specific to rrdfile */
		rrd.value_string rrdfile =
			(rrd.value_string) getOptionValue(
				"rrdile", cmd);
		rrd.value_string rrdfield =
			(rrd.value_string) getOptionValue(
				"rrdfield", cmd);
		rrd.value_string cf =
			(rrd.value_string) getOptionValue(
				"cf", cmd);
		rrd.value_string reduce =
			(rrd.value_string) getOptionValue(
				"reduce", cmd);

		/* create the timestring */
		cached_result = new rrd.value_timestring.init(
			start,step,end,null);

		/* fill in the timestring */
		double dummy=0;
		for (int i=0; i < cached_result.getSteps(); i++) {
			cached_result.setData(i,dummy.NAN);
		}
		/* to avoid warnings */
		rrdfile=null;
		rrdfield=null;
		cf=null;
		reduce=null;

		/* return result */
		return cached_result;

	}
}
