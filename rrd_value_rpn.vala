using GLib;
using Gee;

public class rrd_value_rpn : rrd_value {

	protected rrd_rpn_stack stack = null;
	protected rrd_value cached_result = null;

	protected override bool parse_String()
	{
		return true;
	}

	public override string? to_string()
	{
		return String;
	}

	public override rrd_value? getValue(
		rrd_command cmd,
		rrd_rpn_stack? stack_arg = null)
	{

		/* if we got it cached, then  return it */
		if (cached_result != null) {
			return cached_result;
		}
		/* if we got a stack already, then we recursed on ourself */
		if (stack != null) {
			stderr.printf("RPN recursion detected for %s\n",
				String);
			return null;
		}

		/* create a new stack */
		stack=new rrd_rpn_stack();
		/* then calculate */
		cached_result = stack.parse(String,cmd);

		/* clean the stack again */
		stack = null;
		/* and return the (now) cached result */
		return cached_result;
	}

}
