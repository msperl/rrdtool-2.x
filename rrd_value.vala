using GLib;
using Gee;

enum rrd_value_type {
	STRING,
	RPN,
	TIMESTRING,
	TIMESTAMP,
	VALUE,
	FLAG,
	IFLAG
}

class rrd_value : rrd_object {
	public rrd_value_type type;
	public string value;
	rrd_value(rrd_value_type t,string v)
	{
		type = t;
		value = v;
	}
}

