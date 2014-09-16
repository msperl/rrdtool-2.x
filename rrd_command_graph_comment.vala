using GLib;
using Gee;

public class rrd_command_graph_comment : rrd_argument {

	protected const rrd_argument_entry[] DEF_ARGUMENT_ENTRIES = {
		{ "label",   0,
		  "rrd_value_string",
		  null,
		  true,
		  "the label to draw at the current coordinates",
		  "<string>"}
	};

	protected override rrd_argument_entry[] getArgumentEntries()
	{ return DEF_ARGUMENT_ENTRIES; }

}
