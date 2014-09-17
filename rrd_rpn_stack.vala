using GLib;
using Gee;

public class rrd_rpn_stack {
	protected LinkedList<rrd_value> stack = null;
	string stack_str = null;
	rrd_command cmd = null;

	public void dump()
	{
		stderr.printf("rrd_rpn_stack.dump():\n");
		stderr.printf("String: %s\n",stack_str);

		foreach(var entry in stack) {
			stderr.printf("\t(%s) %s\n",
				entry.get_type().name(),
				entry.to_string()
				);
		}
	}

	/* the public parse method */
	public rrd_value? parse(string arg, rrd_command command) {
		/* set the values */
		stack_str = arg;
		cmd = command;
		/* create the stack */
		stack = new LinkedList<rrd_value>();

		/* split the values */
		if (! split() ) {
			return null;
		}

		/* now process the stack */
		rrd_value result = process();

		/* if the stack is not empty, then complain */
		if (stack.size > 0) {
			stderr.printf(
				"Stack of %s is not empty after processing\n",
				stack_str
				);
			result = null;
		}

		/* then parse for real */
		return result;
	}

	protected rrd_value_string? parseString(string field) {
		var len= field.length;
		/* field must be at least 2 */
		if (len < 2) {
			return null;
		}
		/* first and last char must be the same */
		/* this is mostly an inefficient workarround for vala 0.10 */
		var first=field.substring(1,1);
		var last=field.substring(len-1,1);
		if ( strcmp(first,last) != 0 ) {
			return null;
		}
		/* first (and thus also last) char must be " or ' */
		if (
			(strcmp(first,"'") == 0 )
			||
			(strcmp(first,"\"") == 0 )
			) {
			return (rrd_value_string) rrd_value.factory(
				"rrd_value_string",
				field.substring(
					2,
					field.length-2
					)
				);
		}
		return null;
	}

	protected rrd_value_number? parseNumber(string field) {
		double val = 0;
		if (strcmp(field,"NAN")==0) {
			return new rrd_value_number.double(val.NAN);
		} else if (strcmp(field,"INF")==0) {
			return new rrd_value_number.double(val.INFINITY);
		} else {
			string end = null;
			val = field.to_double(out end);
			if (strcmp(end,"") == 0) {
				return new rrd_value_number.double(val);
			}
		}
		return null;
	}

	protected rrd_rpnop? parseOperator(string field) {
		return  rrd_rpnop.factory(field);
	}

	protected bool split()
	{
		/* iterate the split values */
		foreach(var field in stack_str.split(",")) {
			/* try to identify the field */

			/* check if it is an existing field */
			rrd_value entry = cmd.getParsedArgument(field);
			/* else check if it is a string */
			if ( entry == null)
				entry = parseString(field);
			/* else check if it is a number */
			if ( entry == null)
				entry = parseNumber(field);
			/* else check if it is an operator */
			if ( entry == null)
				entry = parseOperator(field);

			/* if we are still empty then return an error */
			if (entry == null) {
				stderr.printf(
					"RPN operator %s not found"
					+"\n in rpn: %s\n",
					field,
					stack_str);
				return false;
			} else {
				/* otherwise add it to the stack */
				push(entry);
			}
		}
		return true;
	}

	protected rrd_value? process() {
		/* pop a value from stack */
		rrd_value top = pop();
		if (top == null) {
			return null;
		}
		/* and return the value */
		return top.getValue(cmd,this);
	}

	public rrd_value? pop() {
		if (stack.size>0) {
			return stack.poll_tail();
		} else {
			stderr.printf("Stack empty\n");
			return null;
		}
	}
	public void push(rrd_value val) {
		stack.offer_tail(val);
	}
}
