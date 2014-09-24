/* rrdvalue.vala
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
 * an abstract rrd value class providing a few interfaces
 * for real value implementations
 */
public abstract class rrd.value : rrd.object {
	/**
	 * constructor argument of the Argument String
	 */
	public string? String {get; protected set construct;}

	/**
	 * abstract method that parses member variable String
	 * to the internal format
	 */
	public abstract void parse_String();

	/**
	 * constructor
	 */
	construct {
		parse_String();
	}

	/**
	 * virtual method that can modify OptionEntry fields
	 * so that the correct flags are set
	 * @param oe the option entry to modify
	 */
	public virtual void modifyOptEntry(ref OptionEntry oe)
	{ ; }

	/**
	 * the main computational method
	 * for calculating final values to return
	 * most prominently overridden by rpn and def
	 * to calc the rpn/load data from rrdfile on demand
	 * @param cmd   the command to which this belongs (if there
	 *              is the need for a context to lookup other values)
	 * @param stack the rpn_stack to work with - if null, then this is
	 *              not part of a rpn calculation
	 * @returns rrd_value with the value given - may be this
	 */
	public virtual rrd.value? getValue(
		rrd.command cmd,
		rrd.rpn_stack? stack)
	{ return this; }

	/**
	 * method to transform internal values to string
	 */
	public abstract string? to_string();

	/**
	 * create an rrd_value using the class_name from
	 * arg_entry
	 * @param arg_entry the template from which to take the class
	 * @param value     the string-value to set during construction
	 * @return rrd.value as a result or null on failure
	 */
	public static rrd.value? from_ArgEntry(
		rrd.argument_entry arg_entry,
		string? value) {
		return factory(arg_entry.class_name, value);

	}

	/**
	 * factory method for rrd_values
	 * @param class_name the class_name to instanciate
	 * @param value      the value to set
	 * @return rrd.value as a result or null on failure
	 */
	public static rrd.value? factory(
		string class_name, string? value)
	{
		return (rrd.value) rrd.object.classFactory(
			class_name,
			"rrdvalue",
			"String",value);
	}
}

/**
 * cachedvalue class, that implements caching on the computation of
 * getValue
 */
public abstract class rrd.value_cachedGetValue : rrd.value {
	/**
	 * the cached result, so that we do not have to recalculate
	 * the value every time */
	protected rrd.value cached_calcValue = null;

	/**
	 * central rrd.value.getValue implementation
	 * that does take care of caching the computational data
	 * @param cmd   the command to which this belongs
	 * @param stack the rpn_stack to work with - if null, then this is
	 *              not part of a rpn calculation
	 * @returns rrd_value with the value given - may be this
	 */
	public override rrd.value? getValue(
		rrd.command cmd,
		rrd.rpn_stack? stack_arg)
	{
		/* if we do not have it cached, then calculate it */
		if (cached_calcValue == null) {
			cached_calcValue = calcValue(
				cmd, stack_arg);
		}
		/* and return the cached_value */
		return cached_calcValue;
	}

	/**
	 * abstract calcValue method
	 * that does the heavy work of computations
	 * @param cmd   the command to which this belongs
	 * @param stack the rpn_stack to work with - if null, then this is
	 *              not part of a rpn calculation
	 * @returns rrd_value with the value given - may be this
	 */
	public abstract rrd.value? calcValue(
		rrd.command cmd,
		rrd.rpn_stack? stack_arg);
}

/**
 * string value class
 */
public class rrd.value_string : rrd.value {
	/**
	 * parse the string to string
	 * nothing to get done really
	 */
	protected override void parse_String()
	{ ; }

	/**
	 * overriden to_string method
	 * @returns the string given as arguments
	 */
	public override string? to_string()
	{ return String; }
}

/**
 * bool value class
 */
public class rrd.value_bool : rrd.value {
	/**
	 * member variable that essentially caches parse_String
	 */
	protected bool flag;

	/**
	 * constructor that sets a boolean directly
	 * @param flag the value to set
	 */
	public rrd.value_bool.bool(bool flag) {
		Object(String:flag.to_string());
	}

	/**
	 * overriden String parser method
	 * takes the String and converts it to a boolean
	 */
	protected override void parse_String()
	{
		/* assume a null string means the flag is set
		 * - from options
		 */
		if (String == null) {
			flag = true;
		} else {
			/* otherwise do string parsing */
			if (strcmp(String,"true") == 0) {
				flag = true;
			} else if (strcmp(String,"false") == 0) {
				flag = false;
			} else {
				/* parse it as a number */
				flag = (String.to_int() != 0);
			}
		}
	}

	/**
	 * overridden method to set the OptionFlags to NO_ARG
	 * by default we require flags for options
	 * @param oe the option entry to modify
	 */
	public override void modifyOptEntry(ref OptionEntry oe) {
		oe.flags = OptionFlags.NO_ARG;
	}

	/**
	 * return a stringified version of flag
	 * @return string representation of flag
	 */
	public override string? to_string() {
		return flag.to_string();
	}

	/**
	 * virtual method returning a boolean
	 * @return flag itself
	 */
	public virtual bool to_bool() {
		return flag;
	}
}

/**
 * number value class
 */
public class rrd.value_number : rrd.value {
	/**
	 * member variable that essentially caches parse_String
	 */
	protected double value;

	/**
	 * constructor that sets a boolean directly
	 * @param flag the value to set
	 */
	public rrd.value_number.double(double a_value) {
		/* not sure if we should call the
		 * constructor unnecessarily
		 * Object(String:flag.to_string());
		 */
		/* just set the values */
		String = "%f".printf(a_value);
		value = a_value;
	}

	/**
	 * overriden String parser method
	 * takes the String and converts it to a number
	 */
	protected override void parse_String()
	{
		/* if the String is set, then parse */
		if (String == null) {
			value = value.NAN;
		} else if (strcmp(String,"NaN") == 0)  {
			value = value.NAN;
		} else if (strcmp(String,"INF") == 0)  {
			value = value.INFINITY;
		} else {
			/* parse the string */
			string end = null;
			value = String.to_double(out end);
			if (strcmp(end,"") != 0) {
				rrd.error.setErrorString(
					"can not parse string "
					+"%s to number".printf(
						String)
					);
					value = value.NAN;
			}
		}
	}

	/**
	 * return formatted number as string
	 * @return string formated number
	 */
	public override string? to_string()
	{ return "%f".printf(value); }

	/**
	 * virtual method returning the double value
	 * @return the value itself
	 */
	public virtual double getDouble()
	{ return value; }

	/**
	 * virtual method returning the integer of the number
	 * sets error if not a simple integer
	 * @return the integer value
	 */
	public virtual int getInteger()
	{
		double d = getDouble();
		int i = (int) d;
		if ((d - ((double) i)) > d.EPSILON) {
			rrd.error.setErrorString(
				"the value %f is not a simple integer"
				.printf(value)
				);
			return i.MIN;
		}
		return i;
	}
}

/**
 * counter value class
 * mostly used for internal purposes
 */
public class rrd.value_counter : rrd.value_number {

	/**
	 * return a stringified version of the number
	 * also implicitly increments the counter by 1 on reads
	 * @return string representation of flag
	 */
	public override string? to_string()
	{
		value++;
		return "%.0f".printf(value);
	}
}
