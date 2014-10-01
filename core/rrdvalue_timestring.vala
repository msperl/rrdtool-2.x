/* rrdvalue_timestring.vala
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
 * the rrd.value_timestring implementation containing an array of doubles

 */
public class rrd.value_timestring : rrd.value {
	/**
	 * the start timestamp
	 */
	protected double start=0;
	/**
	 * start timestamp getter
	 * @return start timestamp
	 */
	public double getStart() { return start; }

	/**
	 * the end timestamp (excluding)
	 */
	protected double end=0;
	/**
	 * end timestamp getter (excluding)
	 * @return end timestamp
	 */
	public double getEnd() { return end; }

	/**
	 * the step size
	 */
	protected double step=0;
	/**
	 * step-size getter (excluding)
	 * @return end timestamp
	 */
	public double getStep() { return step; }

	/**
	 * returns the number of steps for iteration
	 */
	public int getSteps() {
		double steps=(end-start)/step;
		return (int) steps;
	}
	/**
	 * the data array
	 */
	protected double[] data=null;

	/**
	 * the data getter
	 * @param i index into array
	 * @return value
	 */
	public double getData(int i)
		requires(i>=0)
		requires(i<getSteps())
	{
		return data[i];
	}

	/**
	 * the data setter
	 * @param i index
	 * @param v value
	 */
	public void setData(int i, double v)
		requires(i>=0)
		requires(i<getSteps())
	{
		data[i]=v;
	}

	/**
	 * the data getter with a timestamp as index
	 * @param ts the value at this point
	 * @return value at ts and NaN if outside of window
	 */
	public double getDataTS(double ts)
	{
		/* boundry checks */
		if (ts < start) {
			return double.NAN;
		}
		if (ts >= end) {
			return double.NAN;
		}
		/* otherwise let us calculate the index */
		ts-=start;
		ts/=step;
		int index=(int) ts;
		/* and use that */
		return data[index];
	}

	/**
	 * parse the string - essentially initialize values
	 */
	protected override void parse_String()
	{
		start = 0;
		end = 0;
		step = 0;
		data = null;
	}

	/**
	 * construct timestamp from rrd_numbers
	 * @param a_start the start timestamp
	 * @param a_step  the step size
	 * @param a_end   the end timestamp (exclusive)
	 * @param a_data  the data to set
	 */
	public rrd.value_timestring.init(
		rrd.value_number a_start,
		rrd.value_number a_step,
		rrd.value_number a_end,
		double[]? a_data = null
		)
	{
		var v_start = a_start.to_double();
		var v_step = a_step.to_double();
		var v_end = a_end.to_double();

		rrd.value_timestring.init_double(
			v_start, v_step, v_end,
			a_data
			);
	}

	/**
	 * construct timestamp from double values
	 * @param a_start the start timestamp
	 * @param a_step  the step size
	 * @param a_end   the end timestamp (exclusive)
	 * @param a_data  the data to set
	 */
	public rrd.value_timestring.init_double(
		double a_start,
		double a_step,
		double a_end,
		double[]? a_data = null
		)
		requires (a_end >= a_start)
		requires (a_step > 0)
	{
		start = a_start;
		end = a_end;
		step = a_step;

		/* just in case... */
		if (step.is_nan()) {
			step=300;
		}

		data = null;
		int steps = getSteps();
		if ( (a_data != null) && (a_data.length >= steps) ) {
				data = a_data;
		} else {
			data = null;
		}
		/* create data if necessary */
		if (data == null) {
			data = new double[steps];
			for(int i = 0 ; i < steps ; i++) {
				data[i] = double.NAN;
			}
		}
		/* if  sizes do not match, then crete a copy */
		if ( (a_data != null) && (a_data.length < steps) ) {
			/* copy the data so far */
			for(int i=0;i<a_data.length;i++) {
				data[i] = a_data[i];
			}
			/* fill in with NAN */
			for(int i=a_data.length;i<steps;i++) {
				data[i] = double.NAN;
			}
		}
	}

	/**
	 * convert to string
	 */
	public override string? to_string()
	{
		return "timesting[%f:%f:%f["
			.printf(
				start,
				step,
				end
				);
	}
}
