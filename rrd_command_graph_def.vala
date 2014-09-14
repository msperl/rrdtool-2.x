using GLib;
using Gee;

class rrd_command_graph_def : rrd_argument {

	protected const rrd_argument_entry[] DEF_ARGUMENT_ENTRIES = {
		{ "vname",   0, rrd_value_type.STRING, true,  null},
		{ "rrdfile", 0, rrd_value_type.STRING, true,  null},
		{ "dsname",  0, rrd_value_type.STRING, true,  null},
		{ "cf",      0, rrd_value_type.STRING, true,  "AVG"},
		{ "start",   0, rrd_value_type.RPN,    false, "start"},
		{ "step",    0, rrd_value_type.RPN,    false, "step"},
		{ "end",     0, rrd_value_type.RPN,    false, "end"},
		{ "reduce",  0, rrd_value_type.STRING, false, null},
		{ "type",    0, rrd_value_type.STRING, false,"rrdfile"},
		{ null }
	};

	protected override rrd_argument_entry[] getArgumentEntries()
	{ return DEF_ARGUMENT_ENTRIES; }

	protected override bool modifyParsedArguments(
		TreeMap<string,string> parsed,
		ArrayList<string> positional)
	{
		/* check if rrdfile and vname are defined
		 * then the "normal" positional rules apply
		 */
		if (parsed.has_key("vname")) {
			return true;
		}
		if (parsed.has_key("rrdfile")) {
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
		/* so let us get the first positional arg */
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
		parsed.set("vname",keyval[0]);
		parsed.set("rrdfile",keyval[1]);
		/* as we have been successfull we can strip it
		 * from the position list now */
		positional.remove_at(0);
		/* and return successfull */
		return true;
	}
}
