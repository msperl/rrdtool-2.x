/* rrdrpnop_if.vala
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
 * rpn operator that does conditional calculations using RIF
 * which allows us to avoid recursions much more easily than IF
 * @param truevalue Number/Timestring
 * @param falsvalue Number/Timestring
 * @param flag boolean on which the decission to return the number will be made
 * @return Number/Timestring
 */
public class rrd.rpnop_rif : rrd.rpnop
{
	/*
	 * we need to implement thsi from scratch and make use of getValue
	 * with the correct flag for computations,
	 * so we can not make use of the helper classes, but have to do
	 * everything on our own
	 */
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
		/* in case we are skipping already, then take the short route */
		if (skipcalc) {
			/* get the 3 values */
			getValueFromStack(cmd,skipcalc,3,stack);
			getValueFromStack(cmd,skipcalc,2,stack);
			getValueFromStack(cmd,skipcalc,1,stack);
			/* and return */
			return null;
		}
		/* otherwise we need to do our own parsing */
		var flagobj = getValueFromStack(cmd,skipcalc,3,stack);
		if (flagobj == null) {
			return flagobj;
		}

		/* check type of object */
		if (!(flagobj is rrd.value_bool)) {
			rrd.error.setErrorString(
				"type returned for if is not a boolean but %s"
				.printf(flagobj.get_type().name())
				);
		}
		/* get the boolean */
		bool flag =  ((rrd.value_bool)flagobj).to_bool();
		/* make a decission based on it */
		rrd.value val = null;
		if (flag) {
			getValueFromStack(cmd,false,2,stack);
			val = getValueFromStack(cmd,true,1,stack);
		} else {
			val = getValueFromStack(cmd,true,2,stack);
			getValueFromStack(cmd,false,1,stack);
		}
		/* and return result */
		return val;
	}
}

/**
 * rpn operator that does conditional calculations using IF
 * if is much more complicated to calculate than rif, as it requires
 * processing the stack twice and a lot more of bookkeeping
 * @param flag boolean on which the decission to return the number will be made
 * @param truevalue Number/Timestring
 * @param falsvalue Number/Timestring
 * @return Number/Timestring
 */

