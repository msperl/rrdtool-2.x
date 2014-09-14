using GLib;
using Gee;

class rrd_command_graph_comment : rrd_argument {

	protected const rrd_argument_entry[] DEF_ARGUMENT_ENTRIES = {
		{ "label",   0, rrd_value_type.STRING, true,  null},
		{ null }
	};

	protected override rrd_argument_entry[] getArgumentEntries()
	{ return DEF_ARGUMENT_ENTRIES; }

}
