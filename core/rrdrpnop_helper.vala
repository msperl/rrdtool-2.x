/* rrdrpnop_helper.vala
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
 * rpnop helper class that pops one object from rpn stack and passes it on
 */
public abstract class rrd.rpnophelper_obj : rrd.rpnop {
	/**
	 * implement the generic getValue method
	 * @param cmd   the command to which this belongs (if there
	 *              is the need for a context to lookup other values)
	 * @param stack the rpn_stack to work with - if null, then this is
	 *              not part of a rpn calculation
	 * @param skipcalc skip the expensive calculations
	 * @returns rrd_value with the value given - may be this
	 */
	public override rrd.value? getValue(
		rrd.command cmd,
		bool skipcalc,
		rrd.rpn_stack? stack = null)
	{
		/* pop values from stack */
		var arg = stack.pop();
		if (arg == null) {
			rrd.error.setErrorString(
				"not enough arguments on stack"
				);
			return null;
		}
		/* now get the values */
		var val = arg.getValue(cmd, skipcalc, stack);
		if (val == null) {
			return null;
		}
		/* if we are skipping, dont calculate */
		if (skipcalc)
			return null;
		/* do the calculation */
		return getValue1(val,cmd,stack);
	}
	/**
	 * abstract method that is called to handle
	 * the object from stack
	 * @param val   the value object
	 * @param cmd   the command context
	 * @param stack the command stack
	 * @return rrd_value result
	 */
	public abstract rrd.value? getValue1(
		rrd.value val,
		rrd.command cmd,
		rrd.rpn_stack? stack);
}

/**
 * rpnop helper class that pops two object from rpn stack
 * and passes them on to an abstract method
 */
public abstract class rrd.rpnophelper_obj_obj : rrd.rpnop {
	/**
	 * implement the generic getValue method
	 * @param cmd   the command to which this belongs (if there
	 *              is the need for a context to lookup other values)
	 * @param skipcalc skip the expensive calculations
	 * @param stack the rpn_stack to work with - if null, then this is
	 *              not part of a rpn calculation
	 * @returns rrd_value with the value given - may be this
	 */
	public override rrd.value? getValue(
		rrd.command cmd,
		bool skipcalc,
		rrd.rpn_stack? stack = null)
	{
		/* pop value from stack */
		var arg2 = stack.pop();
		if (arg2 == null) {
			rrd.error.setErrorString(
				"not enough arguments on stack - need 2 more"
				);
			return null;
		}

		/* now get the value */
		var val2 = arg2.getValue(cmd,skipcalc,stack);
		if (val2 == null) {
			return null;
		}

		/* pop value from stack */
		var arg1 = stack.pop();
		if (arg1 == null) {
			rrd.error.setErrorString(
				"not enough arguments on stack - need 1 more"
				);
			return null;
		}

		/* now get the value */
		var val1 = arg1.getValue(cmd,skipcalc,stack);
		if (val1 == null) {
			return null;
		}

		/* if we are skipping, dont calculate */
		if (skipcalc)
			return null;

		/* and call */
		return getValue2(val1,val2,cmd,stack);
	}
	/**
	 * abstract method that is called to handle
	 * the object from stack
	 * @param val1  the first value object
	 * @param val2  the second value object
	 * @param cmd   the command context
	 * @param stack the command stack
	 * @return rrd_value result
	 */
	public abstract rrd.value? getValue2(
		rrd.value val1,
		rrd.value val2,
		rrd.command cmd,
		rrd.rpn_stack? stack);
}

/**
 * rpnop helper class that pops three object from rpn stack
 * and passes them on to an abstract method
 */
public abstract class rrd.rpnophelper_obj_obj_obj : rrd.rpnop {
	/**
	 * implement the generic getValue method
	 * @param cmd   the command to which this belongs (if there
	 *              is the need for a context to lookup other values)
	 * @param skipcalc skip the expensive calculations
	 * @param stack the rpn_stack to work with - if null, then this is
	 *              not part of a rpn calculation
	 * @returns rrd_value with the value given - may be this
	 */
	public override rrd.value? getValue(
		rrd.command cmd,
		bool skipcalc,
		rrd.rpn_stack? stack = null)
	{
		/* pop values from stack */
		var arg3 = stack.pop();
		if (arg3 == null) {
			rrd.error.setErrorString(
				"not enough arguments on stack - need 3 more"
				);
			return null;
		}
		var val3 = arg3.getValue(cmd,skipcalc,stack);
		if (val3 == null) {
			return null;
		}

		var arg2 = stack.pop();
		if (arg2 == null) {
			rrd.error.setErrorString(
				"not enough arguments on stack - need 2 more"
				);
			return null;
		}
		var val2 = arg2.getValue(cmd,skipcalc,stack);
		if (val2 == null) {
			return null;
		}

		var arg1 = stack.pop();
		if (arg1 == null) {
			rrd.error.setErrorString(
				"not enough arguments on stack - need 1 more"
				);
			return null;
		}
		var val1 = arg1.getValue(cmd,skipcalc,stack);
		if (val1 == null) {
			return null;
		}

		/* if we are skipping, dont calculate */
		if (skipcalc)
			return null;
		/* do the processing */
		return getValue3(val1,val2,val3,cmd,stack);
	}
	/**
	 * abstract method that is called to handle
	 * the object from stack
	 * @param val1  the first value object
	 * @param val2  the second value object
	 * @param val3  the second value object
	 * @param cmd   the command context
	 * @param stack the command stack
	 * @return rrd_value result
	 */
	public abstract rrd.value? getValue3(
		rrd.value val1,
		rrd.value val2,
		rrd.value val3,
		rrd.command cmd,
		rrd.rpn_stack? stack);
}

/**
 * rpnop helper class that pops one object from rpn stack
 * and based on type (Number or timestring) call different methods
 */
public abstract class rrd.rpnophelper_value : rrd.rpnophelper_obj {
	/**
	 * implementation of getValue1
	 * and calls the correct abstract function
	 * @param val   the value  object
	 * @param cmd   the command context
	 * @param stack the command stack
	 * @return rrd_value result
	 */
	public override rrd.value? getValue1(
		rrd.value val,
		rrd.command cmd,
		rrd.rpn_stack? stack)
	{
		if (val is rrd.value_number) {
			return getValue_Number(
				(rrd.value_number) val
				);
		} else if (val is rrd.value_timestring) {
			return getValue_Timestring(
				(rrd.value_timestring) val
				);
		}
		return null;
	}

	/**
	 * abstract method that takes a number value
	 * @param val Number
	 * @return Number/Timestring
	 */
	public abstract rrd.value?
		getValue_Number(
			rrd.value_number val);
	/**
	 * abstract method that takes a timestring value
	 * @param val Timestring
	 * @return Number/Timestring
	 */
	public abstract rrd.value?
		getValue_Timestring(
			rrd.value_timestring ts);
}

/**
 * rpnop helper class that pops two object from rpn stack
 * and based on types (Number or timestring)
 * calls different abstract methods
 */
public abstract class rrd.rpnophelper_value_value : rrd.rpnophelper_obj_obj {
	/**
	 * implementation of getValue2
	 * and calls the correct abstract function
	 * @param val1  the first value object
	 * @param val2  the second value object
	 * @param cmd   the command context
	 * @param stack the command stack
	 * @return rrd_value result
	 */
	public override rrd.value? getValue2(
		rrd.value val1,
		rrd.value val2,
		rrd.command cmd,
		rrd.rpn_stack? stack)
	{

		/* and check them */
		/* now depending on the types call different
		 * implementations */
		if (val1 is rrd.value_number) {
			if (val2 is rrd.value_number) {
				return getValue_Number_Number(
					(rrd.value_number) val1,
					(rrd.value_number) val2
					);
			} else if (val2 is rrd.value_timestring) {
				return getValue_Number_Timestring(
					(rrd.value_number) val1,
					(rrd.value_timestring) val2);
			} else {
				rrd.error.setErrorString(
					"unexpected argument2 value %s"
					.printf(val2.get_type().name())
					);
			}
		} else if (val1 is rrd.value_timestring) {
			if (val2 is rrd.value_number) {
				return getValue_Timestring_Number(
					(rrd.value_timestring) val1,
					(rrd.value_number) val2);
			} else if (val2 is rrd.value_timestring) {
				return getValue_Timestring_Timestring(
					(rrd.value_timestring) val1,
					(rrd.value_timestring) val2);
			} else {
				rrd.error.setErrorString(
					"unexpected argument2 value %s"
					.printf(val2.get_type().name())
					);
			}
		}
		/* do not get here */
		rrd.error.setErrorString(
			"unexpected argument1 value %s"
			.printf(val1.get_type().name())
			);
		return null;
	}

	/**
	 * abstract method that takes two number values
	 * @param val1 first Number
	 * @param val2 second Number
	 * @return Number/Timestring
	 */
	public abstract rrd.value?
		getValue_Number_Number(
			rrd.value_number val1,
			rrd.value_number val2);

	/**
	 * abstract method that takes one number and one timestring
	 * @param val1 first Number
	 * @param val2 second timestring
	 * @return Number/Timestring
	 */
	public abstract rrd.value?
		getValue_Number_Timestring(
			rrd.value_number val1,
			rrd.value_timestring val2);

	/**
	 * abstract method that takes one timestring and one number
	 * @param val1 first timestring
	 * @param val1 second Number
	 * @return Number/Timestring
	 */
	public abstract rrd.value?
		getValue_Timestring_Number(
			rrd.value_timestring val1,
			rrd.value_number val2);

	/**
	 * abstract method that takes two timestrings
	 * @param val1 first timestring
	 * @param val1 second timestring
	 * @return Number/Timestring
	 */
	public abstract rrd.value?
		getValue_Timestring_Timestring(
			rrd.value_timestring val1,
			rrd.value_timestring val2);
}

/**
 * rpnop helper class that pops one object from rpn stack
 * and calls a single abstract method that processes the double value
 * the difference between Number and Timestring is hidden
 */
public abstract class rrd.rpnophelper_double : rrd.rpnophelper_value {
	/**
	 * abstract method that takes a value and returns the result
	 * derived from this value
	 * @param timestamp of the current value in case of a timestring
	 *                  0 otherwise
	 * @param value     the double value that is to get processed
	 * @return double value of the computation
	 */
	public abstract double getValue_double(
		double timestamp,
		double value);

	/**
	 * implementation of getValue_Number
	 * @param num Number object
	 * @return  Number object of result
	 */
	public override rrd.value? getValue_Number(
			rrd.value_number num)
	{
		double val = num.getDouble();
		double result = getValue_double(0, val);
		return new rrd.value_number.Double(result);
	}
	/**
	 * implementation of getValue_Timestring
	 * @param ts timestring object to iterate
	 * @return  Number object of result
	 */
	public override rrd.value? getValue_Timestring(
			rrd.value_timestring ts)
	{
		/* get size of resulting timestring */
		double start = ts.getStart();
		double step  = ts.getStep();
		double end   = ts.getEnd();

		/* create a copy of timestring using the same sizes */
		var result = new rrd.value_timestring.init_double(
			start, step, end, null);

		/* get the effective number of stepssteps */
		var steps = result.getSteps();

		/* and now iterate  the steps */
		for(int i=0;i<steps;i++,start+=step) {
			double val = ts.getData(i);
			double res = getValue_double(
				start, val);
			result.setData(i,res);
		}

		/* and return the result */
		return result;
	}
}

/**
 * rpnop helper class that pops two object from rpn stack
 * and calls a single abstract methods that processes the double values
 * the difference between Number and Timestring is hidden for each
 */
public abstract class rrd.rpnophelper_double_double : rrd.rpnophelper_value_value {
	/**
	 * abstract method that takes a value and returns the result
	 * derived from this value
	 * @param timestamp of the current value in case of a timestring
	 *                  0 otherwise
	 * @param value1    the double value that is to get processed
	 * @param value2    the double value that is to get processed
	 * @return double value of the computation
	 */
	public abstract double getValue_double_double(
		double timestamp,
		double value1, double value2);
	/**
	 * implementation of getValue_Number_Number
	 * @param val1 first Number
	 * @param val2 second Number
	 * @return Number
	 */
	public override rrd.value?
		getValue_Number_Number(
			rrd.value_number obj1,
			rrd.value_number obj2)
	{
		double val1 = obj1.getDouble();
		double val2 = obj2.getDouble();
		double result = getValue_double_double(0, val1, val2);
		return new rrd.value_number.Double(result);
	}

	/**
	 * implementation of getValue_Number_Timestring
	 * @param val1 first Number
	 * @param val2 second timestring
	 * @return Number/Timestring
	 */
	public override rrd.value?
		getValue_Number_Timestring(
			rrd.value_number obj1,
			rrd.value_timestring obj2)
	{
		double val1 = obj1.getDouble();

		/* get size of resulting timestring */
		double start=obj2.getStart();
		double step=obj2.getStep();
		double end=obj2.getEnd();

		/* create a copy of timestring */
		var result = new rrd.value_timestring.init_double(
			start, step, end, null);

		/* get the effective steps */
		var steps = result.getSteps();

		/* and now run the steps */
		for(int i=0;i<steps;i++,start+=step) {
			double val2 = obj2.getData(i);
			double res = getValue_double_double(
				start, val1, val2);
			result.setData(i,res);
		}

		/* and return it */
		return result;
	}

	/**
	 * implementation of getValue_Timestring_Number
	 * @param val1 first timestring
	 * @param val1 second Number
	 * @return Timestring
	 */
	public override rrd.value?
		getValue_Timestring_Number(
			rrd.value_timestring obj1,
			rrd.value_number obj2)
	{
		double val2 = obj2.getDouble();

		/* get size of resulting timestring */
		double start=obj1.getStart();
		double step=obj1.getStep();
		double end=obj1.getEnd();

		/* create a copy of timestring */
		var result = new rrd.value_timestring.init_double(
			start, step, end, null);

		/* get the effective steps */
		var steps = result.getSteps();

		/* and now run the steps */
		for(int i=0;i<steps;i++,start+=step) {
			double val1 = obj1.getData(i);
			double res = getValue_double_double(
				start, val1, val2);
			result.setData(i,res);
		}

		/* and return it */
		return result;
	}

	/**
	 * implementation of getValue_Timestring_Timestring
	 * @param val1 first timestring
	 * @param val1 second timestring
	 * @return Timestring
	 */
	public override rrd.value?
		getValue_Timestring_Timestring(
			rrd.value_timestring obj1,
			rrd.value_timestring obj2)
	{
		/* get size of resulting timestring */
		double start1=obj1.getStart();
		double step1=obj1.getStep();
		double end1=obj1.getEnd();

		double start2=obj2.getStart();
		double step2=obj2.getStep();
		double end2=obj2.getEnd();

		double start = (start1 > start2) ? start1 : start2;
		double end = (end1 > end2) ? end1 : end2;
		double step = (step1 < step2) ? step1 : step2;

		/* create a copy of timestring */
		var result = new rrd.value_timestring.init_double(
			start, step, end, null);

		/* get the effective steps */
		var steps = result.getSteps();

		/* and now run the steps */
		for(int i=0;i<steps;i++,start+=step) {
			/* get the values based on start */
			double val1 = obj1.getDataTS(start);
			double val2 = obj2.getDataTS(start);
			/* calculate the result */
			double res = getValue_double_double(
				start, val1, val2);
			/* and set it in the correct location */
			result.setData(i,res);
		}

		/* and return it */
		return result;
	}
}
/**
 * rpnop helper class that pops one object from stack
 * if it is a timestring then it will apply an abstract method on it
 * otherwise if it is a number n, then pop n entries and apply the
 * abstract method to those n Number values
 * it also contains some consolidation of values means
 * as virtual functions that can be overridden
 * Candidates here are MIN,MAX,AVG
 */
public abstract class rrd.rpnophelper_one_or_n_plus_one : rrd.rpnop
{
	/**
	 * implement the generic getValue method
	 * @param cmd   the command to which this belongs (if there
	 *              is the need for a context to lookup other values)
	 * @param skipcalc skip the expensive calculations
	 * @param stack the rpn_stack to work with - if null, then this is
	 *              not part of a rpn calculation
	 * @returns rrd_value with the value given - may be this
	 */
	public override rrd.value? getValue(
		rrd.command cmd,
		bool skipcalc,
		rrd.rpn_stack? stack = null)
	{
		var obj = stack.pop();
		if (obj == null) {
			rrd.error.setErrorString(
				"not enough arguments on stack - need 1 more"
				);
			return null;
		}
		/* if it is a number, then walk the stack */
		if (obj is rrd.value_number) {
			/* the special case where we have to calculate
			 * the max from a number of values
			 */
			return getValueOverStackElements(
				(rrd.value_number) obj,
				cmd,
				skipcalc,
				stack);
		}
		/* otherwise get the values - it might be a rpn again */
		var val = obj.getValue(cmd,skipcalc,stack);
		if (val == null) {
			/* there was an error upstream
			 * in the rpn calculation
			 */
			return null;
		}

		/* skip calculation in some circumstances */
		if (skipcalc)
			return null;

		/* some more checks for an immediate number */
		if (val is rrd.value_timestring) {
			return getValueOverTimestring(
				(rrd.value_timestring) val);
		}
		/* handle errors */
		rrd.error.setErrorString(
			"no support for type %s"
			.printf(val.get_type().name()));
		return null;
	}

	/**
	 * protected member accumulate
	 */
	protected double accumulate = 0;

	/**
	 * protected member accumulate object
	 */
	protected rrd.value accumulate_obj = null;

	/**
	 * protected member count
	 */
	protected int count = 0;

	/**
	 * abstract method that takes a double and does the processing
	 * @param value double value to process
	 */
	public abstract void processDouble(double val);

	/**
	 * virtual method that does postprocessing of the data
	 * the default returns res if we processed more than 0 values
	 */
	public virtual rrd.value? postprocessDouble()
	{
		return (count > 0) ?
			new rrd.value_number.Double(accumulate)
			: null;
	}

	/**
	 * abstract method that processes a single value object
	 * @param obj the object to process
	 */
	public abstract void processValue(rrd.value obj);

	/**
	 * default virtual  implementation for the postProcess Value
	 */
	public virtual rrd.value? postprocessValue()
	{ return accumulate_obj; }

	/**
	 * implementation that iterates over the given timestring
	 * @param ts the timestring to process
	 * @return processed value
	 */
	public virtual rrd.value? getValueOverTimestring(
		rrd.value_timestring ts) {
		/* get number of steps */
		var steps=ts.getSteps();
		/* now iterate the other data */
		for(var i=0;i<steps;i++,count++) {
			double val = ts.getData(i);
			processDouble(val);
		}
		return postprocessDouble();
	}

	/**
	 * implementation that iterates over rpn_stack elements
	 * @param steps number of elements to read from stack
	 * @param cmd   the command to which this belongs (if there
	 *              is the need for a context to lookup other values)
	 * @param stack the rpn_stack to work with - if null, then this is
	 *              not part of a rpn calculation
	 * @returns rrd_value with the value given - may be this
	 */
	public virtual rrd.value? getValueOverStackElements(
		rrd.value_number steps_v,
		rrd.command cmd,
		bool skipcalc,
		rrd.rpn_stack? stack = null) {
		int steps = steps_v.getInteger();
		if (steps<=0) {
			rrd.error.setErrorString(
				"counter can not be less than 1: %i"
				.printf(steps));
			return null;
		}
		/* now iterate for all others */
		for(int i=0 ; i<steps ; i++,count++) {
			var obj = stack.pop();
			if (obj != null) {
				var objnew = obj.getValue(cmd,skipcalc,stack);
				obj=objnew;
			}
			if (! skipcalc)
				processValue(obj);
		}
		if (skipcalc)
			return null;
		/* return result */
		return postprocessValue();
	}
}
