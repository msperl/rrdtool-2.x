using GLib;
using Gee;

public class rrd.command_graph_def : rrd.argument {

	protected const rrd.argument_entry[] DEF_ARGUMENT_ENTRIES = {
		{ "vname",   0,
		  "rrdvalue_string",
		  null,
		  true,
		  "the vname of this data"
		},
		{ "rrdile", 0,
		  "rrdvalue_string",
		  null,
		  true,
		  "the filename of the rrd file"
		},
		{ "dsname",  0,
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

	protected override bool modifyParsedArguments(
		ArrayList<string> positional)
	{
		/* check if rrdfile and vname are defined
		 * then the "normal" positional rules apply
		 */
		if (hasParsedArgument("vname")) {
			return true;
		}
		if (hasParsedArgument("rrdile")) {
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
		setParsedArgument("vname",keyval[0]);
		setParsedArgument("rrdile",keyval[1]);

		/* as we have been successfull we can strip it
		 * from the position list now */
		positional.remove_at(0);
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
			(rrd.value_timestamp) getParsedArgumentValue(
				"start", cmd);
		rrd.value_number step =
			(rrd.value_number) getParsedArgumentValue(
				"step", cmd);
		rrd.value_timestamp end =
			(rrd.value_timestamp) getParsedArgumentValue(
				"end", cmd);

		/* the information that is specific to rrdfile */
		rrd.value_string rrdfile =
			(rrd.value_string) getParsedArgumentValue(
				"rrdile", cmd);
		rrd.value_string dsname =
			(rrd.value_string) getParsedArgumentValue(
				"dsname", cmd);
		rrd.value_string cf =
			(rrd.value_string) getParsedArgumentValue(
				"cf", cmd);
		rrd.value_string reduce =
			(rrd.value_string) getParsedArgumentValue(
				"cf", cmd);

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
		dsname=null;
		cf=null;
		reduce=null;

		/* return result */
		return cached_result;

	}
}
