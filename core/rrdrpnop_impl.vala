/* rrdrpnop_impl.vala
 *
 * Copyright (C) 2014 Martin Sperl
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *
 * Author:
 * Martin Sperl <rrdtool@martin.sperl.org>
 */

/**
 * rpn operator that adds
 * @param val1 Number/Timestring
 * @param val2 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_add : rrd.rpnophelper_double_double
{
	/**
	 * the method that does the actual work of adding 2 doubles
	 */
	public override double
		getValue_double_double(
			double ts,
			double val1,
			double val2)
	{
		return val1 + val2;
	}
}

/**
 * rpn operator that adds (ignoring NANs)
 * @param val1 Number/Timestring
 * @param val2 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_addnan : rrd.rpnophelper_double_double
{
	/**
	 * the method that does the actual work of adding 2 doubles
	 */
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

/**
 * rpn operator that subtracts
 * @param val1 Number/Timestring
 * @param val2 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_sub : rrd.rpnophelper_double_double
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

/**
 * rpn operator that subtracts
 * @param val1 Number/Timestring
 * @param val2 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_subnan : rrd.rpnophelper_double_double
{
	public override double
		getValue_double_double(
			double ts,
			double val1,
			double val2)
	{
		if ( val1.is_nan() ) {
			return -val2;
		}
		if ( val2.is_nan() ) {
			return val1;
		}
		return val1 - val2;
	}
}

/**
 * rpn operator that multiplies
 * @param val1 Number/Timestring
 * @param val2 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_mul : rrd.rpnophelper_double_double
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

/**
 * rpn operator that divides
 * @param val1 Number/Timestring
 * @param val2 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_div : rrd.rpnophelper_double_double
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

/**
 * rpn operator that calculates the modulo
 * @param val1 Number/Timestring
 * @param val2 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_mod : rrd.rpnophelper_double_double
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

/**
 * rpn operator that calculates the min of
 * @param ts Timestring
 * or
 * @param val1 Number
 * @param val2 Number
 * @param valn Number
 * @param n    Number of entries on stack
 * @return Number
 */
public class rrd.rpnop_min : rrd.rpnophelper_one_or_n_plus_one
{
	public override void processDouble(double val)
	{
		if ( (count==0) || (val < accumulate) ) {
			accumulate = val;
		}
	}

	public override void processValue(rrd.value obj)
	{
		rrd.value_number num = (rrd.value_number) obj;
		double val = (obj == null) ? accumulate.NAN : num.getDouble();
		if ( (count==0) || (val < accumulate) ) {
			accumulate_obj = obj;
			accumulate = val;
		}
	}
}

/**
 * rpn operator that calculates the average of
 * @param ts Timestring
 * or
 * @param val1 Number
 * @param val2 Number
 * @param valn Number
 * @param n    Number of entries on stack
 * @return Number
 */
public class rrd.rpnop_avg : rrd.rpnophelper_one_or_n_plus_one
{
	public override void processDouble(double val)
	{
		accumulate += val;
	}

	public override rrd.value? postprocessDouble()
	{
		double v = (count>0) ? accumulate/count : accumulate.NAN;
		return new rrd.value_number.double(v);
	}


	public override void processValue(rrd.value obj)
	{
		rrd.value_number num = (rrd.value_number) obj;
		accumulate += (obj == null) ? accumulate.NAN : num.getDouble();
	}

	public override rrd.value? postprocessValue()
	{
		double v = (count>0) ? accumulate/count : accumulate.NAN;
		return new rrd.value_number.double(v);
	}

}

/**
 * rpn operator that calculates the maximum of
 * @param ts Timestring
 * or
 * @param val1 Number
 * @param val2 Number
 * @param valn Number
 * @param n    Number of entries on stack
 * @return Number
 */
public class rrd.rpnop_max : rrd.rpnophelper_one_or_n_plus_one
{
	public override void processDouble(double val)
	{
		if ( (count==0) || (val > accumulate) ) {
			accumulate = val;
		}
	}

	public override void processValue(rrd.value obj)
	{
		rrd.value_number num = (rrd.value_number) obj;
		double val = (obj == null) ? accumulate.NAN : num.getDouble();
		if ( (count==0) || (val > accumulate) ) {
			accumulate_obj = obj;
			accumulate = val;
		}
	}
}

/**
 * rpn operator that creates a timestring
 * filled with NaN
 * @param start Number/Timestamp
 * @param step  Number/Timestamp
 * @param end   Number/Timestamp
 * @return Timestring filled with NaN
 */
public class rrd.rpnop_timestring : rrd.rpnophelper_obj_obj_obj
{
	public override rrd.value? getValue3(
		rrd.value start_v,
		rrd.value step_v,
		rrd.value end_v,
		rrd.command cmd,
		rrd.rpn_stack? stack) {
		/* check that start step end are numbers */
		if (!(start_v is rrd.value_number)) {
			rrd.error.setErrorString(
				"start is not a number"
				);
			return null;
		}
		if (!(step_v is rrd.value_number)) {
			rrd.error.setErrorString(
				"step is not a number"
				);
			return null;
		}
		if (!(end_v is rrd.value_number)) {
			rrd.error.setErrorString(
				"end is not a number"
				);
			return null;
		}

		/* transform values */
		var start = (rrd.value_number) start_v;
		var step = (rrd.value_number) step_v;
		var end = (rrd.value_number) end_v;

		/* check that start<end */
		if (start.getDouble() > end.getDouble()) {
			rrd.error.setErrorString(
				"start argument is > end"
				);
			return null;
		}
		/* check that start<end */
		if (step.getDouble() <= 0) {
			rrd.error.setErrorString(
				"step argument is <= 0"
				);
			return null;
		}

		/* now we got everything, so create rrd.value_timestring */
                rrd.value result = new rrd.value_timestring.init(
                        start,step,end,null);

		/* and return it */
		return result;
	}
}

/**
 * rpn operator that sets the timestamp of the timestring
 * at the current position
 * @param val1 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_time : rrd.rpnophelper_double
{
	public override double
		getValue_double(
			double ts,
			double val)
	{
		return ts;
	}
}

/**
 * rpn operator that sets the current time
 * @param val1 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_now : rrd.rpnophelper_double
{
	public override double
		getValue_double(
			double ts,
			double val)
	{
		return time_t();
	}
}

/**
 * rpn operator that calculates the sine
 * @param val1 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_sin : rrd.rpnophelper_double
{
	public override double
		getValue_double(
			double ts,
			double val)
	{
		return Math.sin(val);
	}
}

/**
 * rpn operator that calculates the cosine
 * @param val1 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_cos : rrd.rpnophelper_double
{
	public override double
		getValue_double(
			double ts,
			double val)
	{
		return Math.cos(val);
	}
}

/**
 * rpn operator that calculates the log(e)
 * @param val1 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_log : rrd.rpnophelper_double
{
	public override double
		getValue_double(
			double ts,
			double val)
	{
		return Math.log(val);
	}
}

/**
 * rpn operator that calculates the exponent(e)
 * @param val1 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_exp : rrd.rpnophelper_double
{
	public override double
		getValue_double(
			double ts,
			double val)
	{
		return Math.exp(val);
	}
}

/**
 * rpn operator that calculates the square root
 * @param val1 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_sqrt : rrd.rpnophelper_double
{
	public override double
		getValue_double(
			double ts,
			double val)
	{
		return Math.sqrt(val);
	}
}

/**
 * rpn operator that calculates the atan
 * @param val1 Number/Timestring
 * @return Number/Timestring
 */
public class rrd.rpnop_atan : rrd.rpnophelper_double
{
	public override double
		getValue_double(
			double ts,
			double val)
	{
		return Math.atan(val);
	}
}
