using GLib;
using Gee;

public abstract class rrd_value : rrd_object {

	public string? String {get; protected set construct;}

	public abstract bool parse_String();
	construct {
		parse_String();
	}

	public virtual void modifyOptEntry(ref OptionEntry oe)
	{ ; }

	public virtual rrd_value? getValue(
		rrd_command cmd,
		rrd_rpn_stack? stack_arg = null)
	{ return this; }

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

	protected override bool parse_String()
	{
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

public class rrd_value_number : rrd_value {
	protected double value;
	protected override bool parse_String()
	{
		value = value.NAN;
		if (String != null) {
			if (strcmp(String,"NaN") == 0)  {
				// value = value.NAN;
			} else {
				string end = null;
				value = String.to_double(out end);
				if (strcmp(end,"") != 0) {
					//value = value.NAN;
				}
			}
		}
		return true;
	}

	public override string? to_string()
	{ return "%f".printf(value); }

	public virtual double getDouble()
	{ return value; }

	public virtual int getInteger()
	{
		double d = getDouble();
		int i = (int) d;
		if ((d - ((double) i)) > d.EPSILON) {
			stderr.printf(
				"%f is not an integer\n",
				d);
			return i.MIN;
		}
		return i;
	}

	public rrd_value_number.double(double a_value) {
		String = "set directly" ;
		value = a_value;
	}
}

public class rrd_value_timestamp : rrd_value_number {
	protected override bool parse_String()
	{
		time_t now = time_t();
		if (strcmp(String,"now")==0) {
			value = now;
		} else if (strcmp(String,"-1day")==0) {
			value = now - 86400;
		} else {
			stderr.printf("Unsupported time definition: %s",
				String);
			return false;
		}
		return true;
	}
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
