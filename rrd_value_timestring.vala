using GLib;
using Gee;

public class rrd.value_timestring : rrd.value {
	protected double start=0;
	public double getStart() { return start; }

	protected double end=0;
	public double getEnd() { return end; }

	protected double step=0;
	public double getStep() { return step; }

	public int getSteps() {
		double steps=(end-start)/step;
		return (int) steps;
	}

	protected double[] data=null;
	public double getData(int i)
		requires(i>=0)
		requires(i<getSteps())
	{
		return data[i];
	}

	public void setData(int i, double v)
		requires(i>=0)
		requires(i<getSteps())
	{
		data[i]=v;
	}

	public double getDataTS(double ts) {
		/* boundry checks */
		if (ts < start) {
			return ts.NAN;
		}
		if (ts >= end) {
			return ts.NAN;
		}
		/* otherwise let us calculate the index */
		ts-=start;
		ts/=step;
		int index=(int) ts;
		/* and use that */
		return data[index];
	}

	protected override bool parse_String()
	{
		start = 0;
		end = 0;
		step = 0;
		data = null;
		return true;
	}
	public rrd.value_timestring.init(
		rrd.value_number a_start,
		rrd.value_number a_step,
		rrd.value_number a_end,
		double[]? a_data = null
		)
	{
		var v_start = a_start.getDouble();
		var v_step = a_step.getDouble();
		var v_end = a_end.getDouble();

		rrd.value_timestring.init_double(
			v_start, v_step, v_end,
			a_data
			);
	}

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
				data[i] = data[i].NAN;
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
				data[i] = data[i].NAN;
			}
		}
	}

	public override string? to_string()
	{ return String; }
}
