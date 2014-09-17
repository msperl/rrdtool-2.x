using GLib;
using Gee;

public class rrd_rpnop : rrd_value
{
	protected override bool parse_String()
	{ return true; }
	public override string? to_string()
	{ return get_type().name().substring(10); }

	public override rrd_value? getValue(
		rrd_command cmd,
		rrd_rpn_stack? stack = null)
	{
		return null;
	}

	public new static rrd_rpnop? factory(
		string opname)
	{
		/* a few shortcuts - we might make this auto-extensible */
		if (strcmp(opname,"+")==0) {
			opname = "add";
		} else if (strcmp(opname,"-")==0) {
			opname = "sub";
		} else if (strcmp(opname,"*")==0) {
			opname = "mul";
		} else if (strcmp(opname,"/")==0) {
			opname = "div";
		} else if (strcmp(opname,"%")==0) {
			opname = "mod";
		}

		/* now call the factory */
		return (rrd_rpnop) rrd_object.classFactory(
			"rrd_rpnop_"+opname.down(),
			"rrd_rpnop",
			"String", "");
	}
}

public abstract class rrd_rpnop_obj : rrd_rpnop {
	public override rrd_value? getValue(
		rrd_command cmd,
		rrd_rpn_stack? stack = null)
	{
		/* pop values from stack */
		var arg = stack.pop();
		if (arg == null) {
			stderr.printf("not enough arguments on stack\n");
			return null;
		}
		/* now get the values */
		var val = arg.getValue(cmd,stack);
		if (val == null) {
			return null;
		}
		return getValue1(val,cmd,stack);
	}
	public abstract rrd_value? getValue1(
		rrd_value val,
		rrd_command cmd,
		rrd_rpn_stack? stack);
}

public class rrd_rpnop_value : rrd_rpnop_obj {

	public override rrd_value? getValue1(
		rrd_value val,
		rrd_command cmd,
		rrd_rpn_stack? stack)
	{
		if (val is rrd_value_number) {
			return getValue_Number((rrd_value_number) val);
		} else if (val is rrd_value_timestring) {
			return getValue_Timestring((rrd_value_timestring) val);
		}

		return null;
	}

	public virtual rrd_value?
		getValue_Number(
			rrd_value_number val)
	{
		stderr.printf(
			"%s does not implement %s\n",
			get_type().name(),
			"getValue_Number_Number");
		return null;
	}

	public virtual rrd_value?
		getValue_Timestring(
			rrd_value_timestring val)
	{
		stderr.printf(
			"%s does not implement %s\n",
			get_type().name(),
			"getValue_Number_Number");
		return null;
	}
}

public class rrd_rpnop_double : rrd_rpnop_value {
	public virtual double getValue_double(
		double timestamp,
		double val) {
		stderr.printf(
			"%s does not implement %s\n",
			get_type().name(),
			"getValue_double");
		return val.NAN;
	}

	public override rrd_value?
		getValue_Number(
			rrd_value_number obj)
	{
		double val = obj.getDouble();
		double result = getValue_double(0, val);
		return new rrd_value_number.double(result);
	}

	public override rrd_value?
		getValue_Timestring(
			rrd_value_timestring obj)
	{
		/* get size of resulting timestring */
		double start=obj.getStart();
		double step=obj.getStep();
		double end=obj.getEnd();

		/* create a copy of timestring */
		var result = new rrd_value_timestring.init_double(
			start, step, end, null);

		/* get the effective steps */
		var steps = result.getSteps();

		/* and now run the steps */
		for(int i=0;i<steps;i++,start+=step) {
			double val = obj.getData(i);
			double res = getValue_double(
				start, val);
			result.setData(i,res);
		}

		/* and return it */
		return result;
	}
}

public abstract class rrd_rpnop_obj_obj : rrd_rpnop {
	public override rrd_value? getValue(
		rrd_command cmd,
		rrd_rpn_stack? stack = null)
	{
		/* pop values from stack */
		var arg2 = stack.pop();
		if (arg2 == null) {
			stderr.printf("not enough arguments on stack\n");
			return null;
		}
		var arg1 = stack.pop();
		if (arg1 == null) {
			stderr.printf("not enough arguments on stack\n");
			return null;
		}

		/* now get the values */
		var val2 = arg2.getValue(cmd,stack);
		if (val2 == null) {
			return null;
		}

		var val1 = arg1.getValue(cmd,stack);
		if (val1 == null) {
			return null;
		}
		return getValue2(val1,val2,cmd,stack);
	}
	public abstract rrd_value? getValue2(
		rrd_value val1,
		rrd_value val2,
		rrd_command cmd,
		rrd_rpn_stack? stack);
}

public abstract class rrd_rpnop_value_value : rrd_rpnop_obj_obj {

	public override rrd_value? getValue2(
		rrd_value val1,
		rrd_value val2,
		rrd_command cmd,
		rrd_rpn_stack? stack)
	{

		/* and check them */
		/* now depending on the types call different
		 * implementations */
		if (val1 is rrd_value_number) {
			if (val2 is rrd_value_number) {
				return getValue_Number_Number(
					(rrd_value_number) val1,
					(rrd_value_number) val2
					);
			} else if (val2 is rrd_value_timestring) {
				return getValue_Number_Timestring(
					(rrd_value_number) val1,
					(rrd_value_timestring) val2);
			} else {
				stderr.printf(
					"unexpected argument2 value %s\n",
					val2.get_type().name());
			}
		} else if (val1 is rrd_value_timestring) {
			if (val2 is rrd_value_number) {
				return getValue_Timestring_Number(
					(rrd_value_timestring) val1,
					(rrd_value_number) val2);
			} else if (val2 is rrd_value_timestring) {
				return getValue_Timestring_Timestring(
					(rrd_value_timestring) val1,
					(rrd_value_timestring) val2);
			} else {
				stderr.printf(
					"unexpected argument2 value %s\n",
					val2.get_type().name());
			}
		} else {
			stderr.printf(
				"unexpected argument1 value %s\n",
				val1.get_type().name());
			return null;
		}
		/* do not get here */
		return null;
	}

	public virtual rrd_value?
		getValue_Number_Number(
			rrd_value_number val1,
			rrd_value_number val2)
	{
		stderr.printf(
			"%s does not implement %s\n",
			get_type().name(),
			"getValue_Number_Number");
		return null;
	}

	public virtual rrd_value?
		getValue_Number_Timestring(
			rrd_value_number val1,
			rrd_value_timestring val2)
	{
		stderr.printf(
			"%s does not implement %s\n",
			get_type().name(),
			"getValue_Number_Timestring");
		return null;
	}

	public virtual rrd_value?
		getValue_Timestring_Number(
			rrd_value_timestring val1,
			rrd_value_number val2)
	{
		stderr.printf(
			"%s does not implement %s\n",
			get_type().name(),
			"getValue_Timestring_Number");
		return null;
	}

	public virtual rrd_value?
		getValue_Timestring_Timestring(
			rrd_value_timestring val1,
			rrd_value_timestring val2)
	{
		stderr.printf(
			"%s does not implement %s\n",
			get_type().name(),
			"getValue_Timestring_Timestring");
		return null;
	}
}

public class rrd_rpnop_double_double : rrd_rpnop_value_value {

	public virtual double getValue_double_double(
		double timestamp,
		double val1, double val2) {
		stderr.printf(
			"%s does not implement %s\n",
			get_type().name(),
			"getValue_double_double");
		return val1.NAN;
	}

	public override rrd_value?
		getValue_Number_Number(
			rrd_value_number obj1,
			rrd_value_number obj2)
	{
		double val1 = obj1.getDouble();
		double val2 = obj2.getDouble();
		double result = getValue_double_double(0, val1, val2);
		return new rrd_value_number.double(result);
	}

	public override rrd_value?
		getValue_Number_Timestring(
			rrd_value_number obj1,
			rrd_value_timestring obj2)
	{
		double val1 = obj1.getDouble();

		/* get size of resulting timestring */
		double start=obj2.getStart();
		double step=obj2.getStep();
		double end=obj2.getEnd();

		/* create a copy of timestring */
		var result = new rrd_value_timestring.init_double(
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

	public override rrd_value?
		getValue_Timestring_Number(
			rrd_value_timestring obj1,
			rrd_value_number obj2)
	{
		double val2 = obj2.getDouble();

		/* get size of resulting timestring */
		double start=obj1.getStart();
		double step=obj1.getStep();
		double end=obj1.getEnd();

		/* create a copy of timestring */
		var result = new rrd_value_timestring.init_double(
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

	public override rrd_value?
		getValue_Timestring_Timestring(
			rrd_value_timestring obj1,
			rrd_value_timestring obj2)
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
		var result = new rrd_value_timestring.init_double(
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

public abstract class rrd_rpnop_obj_obj_obj : rrd_rpnop {
	public override rrd_value? getValue(
		rrd_command cmd,
		rrd_rpn_stack? stack = null)
	{
		/* pop values from stack */
		var arg3 = stack.pop();
		if (arg3 == null) {
			stderr.printf("not enough arguments on stack\n");
			return null;
		}
		var arg2 = stack.pop();
		if (arg2 == null) {
			stderr.printf("not enough arguments on stack\n");
			return null;
		}
		var arg1 = stack.pop();
		if (arg1 == null) {
			stderr.printf("not enough arguments on stack\n");
			return null;
		}

		/* now get the values */
		var val3 = arg3.getValue(cmd,stack);
		if (val3 == null) {
			return null;
		}

		var val2 = arg2.getValue(cmd,stack);
		if (val2 == null) {
			return null;
		}

		var val1 = arg1.getValue(cmd,stack);
		if (val1 == null) {
			return null;
		}
		return getValue3(val1,val2,val3,cmd,stack);
	}
	public abstract rrd_value? getValue3(
		rrd_value val1,
		rrd_value val2,
		rrd_value val3,
		rrd_command cmd,
		rrd_rpn_stack? stack);
}

public abstract class rrd_rpnop_one_or_n_plus_one : rrd_rpnop
{
	public override rrd_value? getValue(
		rrd_command cmd,
		rrd_rpn_stack? stack = null)
	{
		var obj = stack.pop();
		if (obj == null) {
			stderr.printf("not enough arguments on stack\n");
			return null;
		}
		/* if it is a number, then walk the stack */
		if (obj is rrd_value_number) {
			/* the special case where we have to calculate
			 * the max from a number of values
			 */
			return getValueOverStackElements(
				(rrd_value_number) obj,
				cmd,
				stack);
		}
		/* otherwise get the values - it might be a variable */
		var val = obj.getValue(cmd,stack);
		if (val == null) {
			stderr.printf("unexpected NULL\n");
			return null;
		}
		var t = val.get_type();
		/* some more checks for an immediate number */
		if (t.is_a(Type.from_name("rrd_value_number"))) {
			return val;
		} else if (t.is_a(Type.from_name("rrd_value_timestring"))) {
			return getValueOverTimestring(
				(rrd_value_timestring) val);
		}
		stderr.printf("We should not get here for type %s\n",
			t.name());
		return null;
	}

	protected double res = 0;
	protected int count = 0;

	public abstract void processDouble(double val);
	public virtual rrd_value? postprocessDouble()
	{ return (count > 0) ? new rrd_value_number.double(res) : null; }

	public virtual rrd_value? getValueOverTimestring(
		rrd_value_timestring ts) {
		/* get number of steps */
		var steps=ts.getSteps();
		/* now iterate the other data */
		for(var i=0;i<steps;i++,count++) {
			double val = ts.getData(i);
			processDouble(val);
		}
		return postprocessDouble();
	}

	protected rrd_value resobj = null;
	public abstract void processValue(rrd_value obj);
	public virtual rrd_value? postprocessValue()
	{ return resobj; }

	public virtual rrd_value? getValueOverStackElements(
		rrd_value_number steps_v,
		rrd_command cmd,
		rrd_rpn_stack? stack = null) {
		int steps = steps_v.getInteger();
		if (steps<0) {
			stderr.printf(
				"counter can not be less than 0: %i\n",
				steps);
			return null;
		}
		/* now iterate for all others */
		for(int i=0 ; i<steps ; i++,count++) {
			var obj = stack.pop();
			if (obj != null) {
				obj = obj.getValue(cmd,stack);
			}
			processValue(obj);
		}
		/* return result */
		return postprocessValue();
	}
}
