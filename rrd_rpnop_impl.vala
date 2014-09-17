using GLib;
using Gee;

public class rrd_rpnop_add : rrd_rpnop_double_double
{
	public override double
		getValue_double_double(
			double ts,
			double val1,
			double val2)
	{
		return val1 + val2;
	}
}

public class rrd_rpnop_addnan : rrd_rpnop_double_double
{
	public override double
		getValue_double_double(
			double ts,
			double val1,
			double val2)
	{
		if ( val1.is_nan() ) {
			return val2;
		}
		if ( val2.is_nan() ) {
			return val1;
		}
		return val1 + val2;
	}
}

public class rrd_rpnop_sub : rrd_rpnop_double_double
{
	public override double
		getValue_double_double(
			double ts,
			double val1,
			double val2)
	{
		return val1 - val2;
	}
}

public class rrd_rpnop_mul : rrd_rpnop_double_double
{
	public override double
		getValue_double_double(
			double ts,
			double val1,
			double val2)
	{
		return val1 * val2;
	}
}

public class rrd_rpnop_div : rrd_rpnop_double_double
{
	public override double
		getValue_double_double(
			double ts,
			double val1,
			double val2)
	{
		/* some boundry case checks
		 * not sure if other/different checks are needed
		 */
		if (val1.is_nan()) {
			return val1.NAN;
		}
		if (val2.is_nan()) {
			return val2.NAN;
		}
		if (val2 == 0) {
			return val2.INFINITY;
		}
		/* return the result */
		return val1/val2;
	}
}

public class rrd_rpnop_mod : rrd_rpnop_double_double
{
	public override double
		getValue_double_double(
			double ts,
			double val1,
			double val2)
	{
		/* some boundry case checks
		 * not sure if other/different checks are needed
		 */
		if (val1.is_nan()) {
			return val1.NAN;
		}
		if (val2.is_nan()) {
			return val2.NAN;
		}
		if (val2 == 0) {
			return val2.INFINITY;
		}
		/* return the result */
		return val1 % val2;
	}
}

public class rrd_rpnop_min : rrd_rpnop_one_or_n_plus_one
{
	public override void processDouble(double val)
	{
		if ( (count==0) || (val < res) ) {
			res = val;
		}
	}

	public override void processValue(rrd_value obj)
	{
		rrd_value_number num = (rrd_value_number) obj;
		double val = (obj == null) ? res.NAN : num.getDouble();
		if ( (count==0) || (val < res) ) {
			resobj = obj;
			res = val;
		}
	}
}

public class rrd_rpnop_avg : rrd_rpnop_one_or_n_plus_one
{
	public override void processDouble(double val)
	{
		res += val;
	}

	public override rrd_value? postprocessDouble()
	{
		double v = (count>0) ? res/count : res.NAN;
		return new rrd_value_number.double(v);
	}


	public override void processValue(rrd_value obj)
	{
		rrd_value_number num = (rrd_value_number) obj;
		res += (obj == null) ? res.NAN : num.getDouble();
	}

	public override rrd_value? postprocessValue()
	{
		double v = (count>0) ? res/count : res.NAN;
		return new rrd_value_number.double(v);
	}

}

public class rrd_rpnop_max : rrd_rpnop_one_or_n_plus_one
{
	public override void processDouble(double val)
	{
		if ( (count==0) || (val > res) ) {
			res = val;
		}
	}

	public override void processValue(rrd_value obj)
	{
		rrd_value_number num = (rrd_value_number) obj;
		double val = (obj == null) ? res.NAN : num.getDouble();
		if ( (count==0) || (val > res) ) {
			resobj = obj;
			res = val;
		}
	}
}

public class rrd_rpnop_timestring : rrd_rpnop_obj_obj_obj
{
	public override rrd_value? getValue3(
		rrd_value start_v,
		rrd_value step_v,
		rrd_value end_v,
		rrd_command cmd,
		rrd_rpn_stack? stack) {

		/* transform values */
		var start = (rrd_value_number) start_v;
		var step = (rrd_value_number) step_v;
		var end = (rrd_value_number) end_v;

		/* now we got everything, so create rrd_value_timestring */
                rrd_value cached_result = new rrd_value_timestring.init(
                        start,step,end,null);

		/* and return it */
		return cached_result;
	}
}

public class rrd_rpnop_timestamp : rrd_rpnop_double
{
	public override double
		getValue_double(
			double ts,
			double val)
	{
		return ts;
	}
}
