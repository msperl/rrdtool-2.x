using GLib;
using Gee;

public class rrd_command_graph_def : rrd_argument {

	protected const rrd_argument_entry[] DEF_ARGUMENT_ENTRIES = {
		{ "vname",   0,
		  "rrd_value_string",
		  null,
		  true,
		  "the vname of this data"
		},
		{ "rrdfile", 0,
		  "rrd_value_string",
		  null,
		  true,
		  "the filename of the rrd file"
		},
		{ "dsname",  0,
		  "rrd_value_string",
		  null,
		  true,
		  "the field inside the rrd file"
		},
		{ "cf",      0,
		  "rrd_value_string",
		  "AVG",
		  true,
		  "the consolidation function to use"
		},
		{ "start",   0,
		  "rrd_value_rpn",
		  "start",
		  false,
		  "the start time for the def"
		},
		{ "step",   0,
		  "rrd_value_rpn",
		  "step",
		  false,
		  "the time steps for the def"
		},
		{ "end",   0,
		  "rrd_value_rpn",
		  "end",
		  false,
		  "the end time for the def"
		},
		{ "reduce",      0,
		  "rrd_value_string",
		  "",
		  false,
		  "the reduction consolidation function to use"
		}
	};

	protected override rrd_argument_entry[] getArgumentEntries()
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
		if (hasParsedArgument("rrdfile")) {
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
		setParsedArgument("rrdfile",keyval[1]);

		/* as we have been successfull we can strip it
		 * from the position list now */
		positional.remove_at(0);
		/* and return successfull */
		return true;
	}

	protected rrd_value_timestring cached_result = null;

	public override rrd_value? getValue(
		rrd_command cmd,
		rrd_rpn_stack? stack = null)
	{
		if (cached_result != null)  {
			return cached_result;
		}
		/* the start/step/end values */
		rrd_value_timestamp start =
			(rrd_value_timestamp) getParsedArgumentValue(
				"start", cmd);
		rrd_value_number step =
			(rrd_value_number) getParsedArgumentValue(
				"step", cmd);
		rrd_value_timestamp end =
			(rrd_value_timestamp) getParsedArgumentValue(
				"end", cmd);

		/* the information that is specific to rrdfile */
		rrd_value_string rrdfile =
			(rrd_value_string) getParsedArgumentValue(
				"rrdfile", cmd);
		rrd_value_string dsname =
			(rrd_value_string) getParsedArgumentValue(
				"dsname", cmd);
		rrd_value_string cf =
			(rrd_value_string) getParsedArgumentValue(
				"cf", cmd);
		rrd_value_string reduce =
			(rrd_value_string) getParsedArgumentValue(
				"cf", cmd);

		/* create the timestring */
		cached_result = new rrd_value_timestring.init(
			start,step,end,null);

		/* fill in the timestring */
		double dummy=0;
		for (int i=0; i < cached_result.getSteps(); i++) {
			cached_result.setData(i,dummy.NAN);
		}

		/* return result */
		return cached_result;

	}
}
