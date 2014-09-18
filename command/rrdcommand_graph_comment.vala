using GLib;
using Gee;

public class rrd.command_graph_comment : rrd.argument {

	protected const rrd.argument_entry[] DEF_ARGUMENT_ENTRIES = {
		{ "label",   0,
		  "rrdvalue_string",
		  null,
		  true,
		  "the label to draw at the current coordinates",
		  "<string>"}
	};

	protected override rrd.argument_entry[] getArgumentEntries()
	{ return DEF_ARGUMENT_ENTRIES; }

}
