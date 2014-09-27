/* rrdvalue_rpn.vala
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
 * rpn value class
 */
public class rrd.value_rpn : rrd.value_cachedGetValue {
	/**
	 * the rpn stack that we use
	 */
	protected rrd.rpn_stack stack = null;

	/**
	 * parse the string to string
	 * nothing to get done really - we pares only on demand!
	 */
	protected override void parse_String()
	{ ; }

	/**
	 * overriden to_string method
	 * @returns the class name/operator name
	 */
	public override string? to_string()
	{ return String; }

	/**
	 * calcValue implementation
	 * responsible for all the computational work
	 * @param cmd   the command to which this belongs
	 * @param stack the rpn_stack to work with  - this is
	 *              ignored, as as an rpn ourselves, we
	 *              need to create a new stack
	 * @returns rrd_value with the value given - may be this
	 */
	public override rrd.value? calcValue(
		rrd.command cmd,
		rrd.rpn_stack? stack_arg)
	{
		/* if we got a stack already, then we recursed on ourself */
		if (stack != null) {
			rrd.error.setErrorString(
				"RPN recursion detected for %s in context %s"
				.printf(String, context));
			return null;
		}

		/* create a new stack and assign it */
		stack=new rrd.rpn_stack();

		/* then calculate */
		var result = stack.parse(String, cmd, context);

		/* clean the stack again */
		stack = null;

		/* and return the result */
		return result;
	}
}
