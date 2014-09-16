using GLib;
using Gee;

public class rrd_command_graph_rpn : rrd_argument {

	protected const rrd_argument_entry[] RPN_ARGUMENT_ENTRIES = {
		{ "vname",   0,
		  "rrd_value_string",
		  null,
		  true,
		  "the vname of this data"
		},
		{ "rpn", 0,
		  "rrd_value_rpn",
		  null,
		  true,
		  "the filename of the rrd file"
		}
	};

	protected override rrd_argument_entry[] getArgumentEntries()
	{ return RPN_ARGUMENT_ENTRIES; }

	protected override bool modifyParsedArguments(
		ArrayList<string> positional)
	{
		/* check if rrdfile and vname are defined
		 * then the "normal" positional rules apply
		 */
		if (hasParsedArg("vname")) {
			return true;
		}
		if (hasParsedArg("rpn")) {
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
		setParsedArg("vname",keyval[0]);
		setParsedArg("rpn",keyval[1]);

		/* as we have been successfull we can strip it
		 * from the position list now */
		positional.remove_at(0);
		/* and return successfull */
		return true;
	}
}