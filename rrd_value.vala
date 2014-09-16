using GLib;
using Gee;

public abstract class rrd_value : rrd_object {

	public string? String {get; protected set construct;}

	public abstract bool parse_String() ;
	construct {
		parse_String();
	}

	public virtual void modifyOptEntry(ref OptionEntry oe)
	{ ; }

	public abstract string? to_string();

	public static rrd_value? from_ArgEntry(
		rrd_argument_entry ae,
		string? value) {

		/* the value */
		if (value == null) {
			value = ae.default_value;
		}

		return factory(ae.class_name,value);

	}

	public static rrd_value? factory(
		string class_name, string value)
	{
		return (rrd_value) rrd_object.classFactory(
			class_name,
			"rrd_value",
			"String",value);
	}
}

public class rrd_value_flag : rrd_value {
	bool flag;

	public rrd_value_flag(bool flag) {
		Object(String:flag.to_string());
	}

	protected override bool parse_String() {
		if (String == null) {
			flag = false;
		} else {
			flag = (String.to_int() != 0);
		}
		return true;
	}

	public override void modifyOptEntry(ref OptionEntry oe) {
		oe.flags = OptionFlags.NO_ARG;
	}

	public override string? to_string() {
		return (flag)?"true":"false";
	}
}

public class rrd_value_string : rrd_value {
	protected override bool parse_String()
	{ return true; }

	public override string? to_string()
	{ return String; }
}

public class rrd_value_rpn : rrd_value {
	protected string rpn;

	protected override bool parse_String()
	{
		rpn = String;
		return true;
	}

	public override string? to_string()
	{ return rpn; }
}

public class rrd_value_timestamp : rrd_value {

	protected override bool parse_String()
	{
		return true;
	}
	public override string? to_string()
	{ return String; }
}

public class rrd_value_counter : rrd_value {
	protected int count;

	protected override bool parse_String()
	{
		count = 0;
		return true;
	}

	public override string? to_string()
	{ count++; return "%i".printf(count); }
}
