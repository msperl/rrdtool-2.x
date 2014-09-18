using GLib;
using Gee;

public class rrd.rpnop_add : rrd.rpnop_double_double
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

public class rrd.rpnop_addnan : rrd.rpnop_double_double
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

public class rrd.rpnop_sub : rrd.rpnop_double_double
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

public class rrd.rpnop_mul : rrd.rpnop_double_double
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

public class rrd.rpnop_div : rrd.rpnop_double_double
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

public class rrd.rpnop_mod : rrd.rpnop_double_double
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

public class rrd.rpnop_min : rrd.rpnop_one_or_n_plus_one
{
	public override void processDouble(double val)
	{
		if ( (count==0) || (val < res) ) {
			res = val;
		}
	}

	public override void processValue(rrd.value obj)
	{
		rrd.value_number num = (rrd.value_number) obj;
		double val = (obj == null) ? res.NAN : num.getDouble();
		if ( (count==0) || (val < res) ) {
			resobj = obj;
			res = val;
		}
	}
}

public class rrd.rpnop_avg : rrd.rpnop_one_or_n_plus_one
{
	public override void processDouble(double val)
	{
		res += val;
	}

	public override rrd.value? postprocessDouble()
	{
		double v = (count>0) ? res/count : res.NAN;
		return new rrd.value_number.double(v);
	}


	public override void processValue(rrd.value obj)
	{
		rrd.value_number num = (rrd.value_number) obj;
		res += (obj == null) ? res.NAN : num.getDouble();
	}

	public override rrd.value? postprocessValue()
	{
		double v = (count>0) ? res/count : res.NAN;
		return new rrd.value_number.double(v);
	}

}

public class rrd.rpnop_max : rrd.rpnop_one_or_n_plus_one
{
	public override void processDouble(double val)
	{
		if ( (count==0) || (val > res) ) {
			res = val;
		}
	}

	public override void processValue(rrd.value obj)
	{
		rrd.value_number num = (rrd.value_number) obj;
		double val = (obj == null) ? res.NAN : num.getDouble();
		if ( (count==0) || (val > res) ) {
			resobj = obj;
			res = val;
		}
	}
}

public class rrd.rpnop_timestring : rrd.rpnop_obj_obj_obj
{
	public override rrd.value? getValue3(
		rrd.value start_v,
		rrd.value step_v,
		rrd.value end_v,
		rrd.command cmd,
		rrd.rpn_stack? stack) {

		/* transform values */
		var start = (rrd.value_number) start_v;
		var step = (rrd.value_number) step_v;
		var end = (rrd.value_number) end_v;

		/* now we got everything, so create rrd.value_timestring */
                rrd.value cached_result = new rrd.value_timestring.init(
                        start,step,end,null);

		/* and return it */
		return cached_result;
	}
}

public class rrd.rpnop_timestamp : rrd.rpnop_double
{
	public override double
		getValue_double(
			double ts,
			double val)
	{
		return ts;
	}
}
