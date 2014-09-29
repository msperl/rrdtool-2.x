/* rrdrpn_stack.vala
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
using Gee;

/**
 * rpn stack implementation
 */
public class rrd.rpn_stack {
	/**
	 * member variable that contains the linked list that is the stack
	 */
	protected LinkedList<rrd.value> stack = null;
	/**
	 * member variable that contains the original rpn definition
	 * to processing
	 */
	protected string rpn_str = null;
	/**
	 * member variable cmd, which contains the reference to the
	 * command to which the stack belongs
	 */
	protected rrd.command cmd = null;

	/* the context of this stack*/
	protected string context = null;

	/**
	 * dump the stack
	 */
	public void dump()
	{
		stderr.printf("rrdrpn_stack.dump():\n");
		stderr.printf("String: %s\n",rpn_str);

		foreach(var entry in stack) {
			stderr.printf("\t(%s) %s\n",
				entry.get_type().name(),
				entry.to_string()
				);
		}
	}

	/**
	 * parse the string and create it inot a stack object
	 * @param rpn     the rpn string to parse
	 * @param command the command for which we run this
	 * @return the result rrd.value object
	 */
	public rrd.value? parse(string rpn,
				rrd.command command,
				string ctx
		)
	{
		/* set the values */
		rpn_str = rpn;
		cmd = command;
		context = ctx;

		/* create the stack linked list*/
		stack = new LinkedList<rrd.value>();

		/* split the values */
		if (! split() ) {
			return null;
		}

		/* now process the stack */
		rrd.value result = process();

		/* if the stack is not empty, then complain */
		if (stack.size > 0) {
			rrd.error.setErrorString(
				"Stack of %s is not empty after processing"
				.printf(rpn_str)
				);
			result = null;
		}
		/* return the result */
		return result;
	}

	/**
	 * try to parse the field to a string
	 * and return the corresponding rrd.value_string
	 * @param field the field to parse
	 * @return the created object corresponding to field
	 */
	protected rrd.value_string? parseString(string field)
	{
		/* field must be at least 2 because of quotes */
		var len= field.length;
		if (len < 2) {
			return null;
		}
		/* first and last char must be the same */
		/* this is mostly an inefficient workarround for vala 0.10 */
		var first=field.substring(0,1);
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
			return (rrd.value_string) rrd.value.factory(
				"rrdvalue_string",
				field.substring(
					1,
					field.length-2
					)
				);
		}
		return null;
	}
	/**
	 * try to parse the field to a number
	 * and return the corresponding rrd.value_number
	 */
	protected rrd.value_number? parseNumber(string field)
	{
		double val = 0;
		if (strcmp(field,"NAN")==0) {
			return new rrd.value_number.Double(double.NAN);
		} else if (strcmp(field,"INF")==0) {
			return new rrd.value_number.Double(double.INFINITY);
		} else {
			string end = null;
			val = field.to_double(out end);
			if (strcmp(end,"") == 0) {
				return new rrd.value_number.Double(val);
			}
		}
		return null;
	}

	/**
	 * try to parse the field to an operator
	 * and return the corresponding rrd.rpnop
	 */
	protected rrd.rpnop? parseOperator(string field)
	{
		return rrd.rpnop.factory(field,cmd.get_type().name());
	}

	protected rrd.value? parseLookupContext(string field)
	{
		var split = context.split(".");
		for(var i=split.length;i>0;i--) {
			string f=split[0];
			for(var j=1;j<i;j++) {
				f += "."+split[j];
			}
			f += "."+field;
			if (strcmp(f,context)!=0) {
				/* now try the lookup */
				var entry = cmd.getOption(f);
				if (entry != null) {
					rrd.error.clearError();
					return entry;
				}
			}
		}
		/* do the global lookup */
		return cmd.getOption(field);
	}

	protected rrd.value? parseLookup(string field)
	{
		/* first try the "normal" lookup */
		var entry = cmd.getOption(field);
		if (entry != null) {
			return entry;
		}
		/* split into two fields */
		var split = field.split("?",2);
		if (split.length==2) {
			/* try to get the value alone */
			entry = parseField(split[0]);
			/* if it did not work, then try the second part */
			if (entry == null){
				rrd.error.clearError();
				entry = parseField(split[1]);
			}
			if (entry != null) {
				return entry;
			}
		}
		/* now the context lookup */
		if (strcmp(field.substring(0,1),"!")==0) {
			rrd.error.clearError();
			return parseLookupContext(field.substring(1));
		}

		return entry;
	}

	protected rrd.value? parseField(string field)
	{
		/* check if it is a string */
		rrd.value entry = parseString(field);
		/* else check if it is a number */
		if ( entry == null)
			entry = parseNumber(field);
		/* try to get the value alone */
		if ( entry == null)
			entry = parseLookup(field);
		/* else check if it is an operator */
		if ( entry == null)
			entry = parseOperator(field);
		/* return the result */
		return entry;
	}

	/**
	 * split the fields and try to parse them
	 * @return true on success
	 */
	protected bool split()
	{
		/* iterate the split values */
		foreach(var field in rpn_str.split(",")) {
			/* try to identify the field */
			rrd.value entry = parseField(field);
			/* if we are empty then return an error */
			if (entry == null) {
				rrd.error.setErrorString(
					"RPN operator %s not found in rpn: %s context %s"
					.printf(field, rpn_str, context)
					);
				return false;
			} else {
				/* otherwise add it to the stack */
				push(entry);
			}
		}
		/* clear the errors, that have happened */
		rrd.error.clearError();
		/* and return success */
		return true;
	}

	/**
	 * process the stack
	 * @return rrd.value or null as the result
	 */
	protected rrd.value? process() {
		/* pop a value from stack */
		rrd.value top = pop();
		if (top == null) {
			rrd.error.setErrorString(
				"not enough arguments on stack"
				);
			return null;
		}
		/* and return the value by calling getValue */
		return top.getValue(cmd,false,this);
	}

	/**
	 * pop an item from stack
	 * @return rrd.value or null
	 */
	public rrd.value? pop() {
		if (stack.size>0) {
			return stack.poll_tail();
		} else {
			rrd.error.setErrorString(
				"not enough arguments on stack"
				);
			return null;
		}
	}
	/**
	 * push a value onto the stack
	 * @param value
	 */
	public void push(rrd.value value) {
		stack.offer_tail(value);
	}
}
