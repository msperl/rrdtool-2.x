/* rrdargument.vala
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
 * the (positional) argument class
 */
public class rrd.argument : rrd.value {
	/**
	 * the parent rrd_command from which we are derived
	 */
	public rrd.argument parent { get; construct; }

	/**
	 * constructor argument list of arguments to this argument
	 */
        public LinkedList<string> args { get; protected construct set; }

	/**
	 * constructor argument command to which this object belongs
	 */
        public weak rrd.command command { get; construct; }

	/**
	 * the parsed options as a map for quick access.
	 * this also contains the options of arguments,
	 * so that the parameters of those can also get
	 * used for rpn calculations
	 */
	protected TreeMap<string,rrd.value> options;

	/**
	 * constructor
	 */
        construct {
		/* if we got a parent so this is happening during delegation
		 * copy the things from parent - we can highjack it, as it
		 * (should) get destroyed anyway inside the factory
		 */
		if (parent != null) {
			/* copy things over from parent */
			args =
				parent.args;
			options = (owned)
				parent.options;
			command =
				parent.command;
			/* and parse the remaining arguments */
			parseArgs();
		} else if (args == null) {
			if (String == null) {
				rrd.error.setErrorString(
					"construct %s without args or String set"
					.printf(this.get_type().name()));
			} else {
				/* split into a list */
				args = split_colon(String);
				if (args != null) {
					/* fill in options */
					options = new TreeMap<string,rrd.value>();
					/* and parse the remaining arguments */
					parseArgs();
				}
			}
		} else if (command == null) {
			rrd.error.setErrorString(
				"construct %s without command set"
				.printf(this.get_type().name()));
		} else {
			/* fill in options */
			options = new TreeMap<string,rrd.value>();
			/* and parse the remaining arguments */
			parseArgs();
		}
        }
	/**
	 * execute method
	 * the default implementation does nothing
	 * @param cmd the command for which we run
	 * @return true on success
	 */
	public bool execute(rrd.command cmd)
	{ return true ; }

	/**
	 * check if we have an option
	 * @param key the key to check
	 * @return if the key exists in the list of options
	 */
	public bool hasOption(string key)
	{ return options.has_key(key); }

	/**
	 * get the option with name key
	 * @param key the key to check
	 * @return thr option rrd_value for key
	 */
	public rrd.value? getOption(string key)
	{
		if (options.has_key(key)) {
			return options.get(key);
		}
		return null;
	}

	/**
	 * get the option value with name key
	 * @param key the key to check
	 * @return thr option rrd_value for key
	 */
	public rrd.value? getOptionValue(
		string key, rrd.command cmd)
	{
		rrd.value res = getOption(key);
		if (res != null) {
			return res.getValue(cmd,false,null);
		}
		return res;
	}

	/**
	 * set option key to value
	 * @param key the key to set
	 * @param value the value to set
	 * @return status true if OK
	 */
	protected bool setOption(string key, string value)
	{
		/* create a new class */
		rrd.value val = getClassForKey(key,value);
		/* if it is set, then it is in entries */
		if (val == null) {
			return false;
		}
		/* now set the value */
		options.set(key,val);
		/* and if the value is of type rrd_argument,
		 * then link also the subvalues
		 */
		var flag = rrd.object.isSubClassOf(
			val.get_type(),
			"rrdargument");
		if ( flag )  {
			var opt=((rrd.argument)val).options;
			foreach( var ent in opt.entries) {
				options.set(
					key+"."+ent.key,
					ent.value
					);
			}
		}
		/* return it */
		return true;
	}

	/**
	 * dump the argument info
	 */
	public void dump() {
		stderr.printf("%s.dump():\n",get_type().name());
		foreach(var arg in options.entries) {
			stderr.printf("   Parsed arg: %s = %s\n",
				arg.key,arg.value.to_string());
		}
		foreach(var p in args) {
			stderr.printf("   Arg: %s\n",p);
		}

	}

	/**
	 * the default empty list of argument entries
	 */
	protected const rrd.argument_entry[] DEFAULT_ARGUMENT_ENTRIES = {
		{ "cmd",  0, "rrdvalue_string", null, true, "command" }
		};

	/**
	 * get the relevant argument entries
	 * @return rrd.argument_entry array
	 */
	protected virtual rrd.argument_entry[] getArgumentEntries()
	{ return DEFAULT_ARGUMENT_ENTRIES; }

	/**
	 * virtual method that allows for modifications
	 * prior to parsing positional arguments
	 * @param list of positional arguments
	 * @returns true on success
	 */
	protected virtual bool modifyOptions()
	{ return true; }

	/**
	 * links the rrd.argument with rrd.command
	 * which includes copying over data to global options
	 * @param command the command to which we should link
	 */
	public void linkToCommand(rrd.command command) {
		/* copy debug from global context if it exists
		 * and we have not set it locally */
		if (! hasOption("debug")) {
			var cmd_debug = command.getOption("debug")
				?? new rrd.value_bool.bool(false);
			/* this is an exception */
			options.set("debug", cmd_debug);
		}

		/* dump what we have found */
		if (((rrd.value_bool)options.get("debug")).to_bool())  {
			dump();
		}

		/* now link it in command context
		 * - mostly for rpn calculations */

		/* get the prefix to use */
		var prefix=getPrefixName(command);

		/* link the argument itself */
		linkToCommandFullName(command,prefix);

		/* now set our options in the command context
		 * - this should be a reference
		 */
		foreach(var kv in options.entries) {
			string ctx=prefix+"."+kv.key;
			command.setOption(
				ctx,
				kv.value);
			kv.value.setContext(ctx);
		}
	}

	/**
	 * activity linking ourselves to the command with the given prefix
	 * @param command the command to which we should link
	 * @param the prefix we should use for this linking
	 */
	protected virtual void linkToCommandFullName(
		rrd.command command,
		string prefix)
	{ command.setOption(prefix,this); }

	/**
	 * parse linked list of unhandled args
	 * and put them into context
	 */
	protected bool parseArgs()
	{
		/* list of positional=unhandled args */
		var pos_args = new LinkedList<string>();

		/* copy the debug from the command */
		if (command.hasOption("debug")) {
			options.set("debug",command.getOption("debug"));
		}

		/* now parse the args */
		foreach(var arg in args) {
			/* skip an empty string */
			if (strcmp(arg,"")==0) {
				continue;
			}
			/* try to split in key/values */
			var keyvalue=arg.split("=",2);
			/* if we got a single entry only,
			 * then it IS a positional arg */
			if (keyvalue.length == 1) {
				pos_args.add(arg);
			} else {
				/* it is key/value */
				var key = keyvalue[0];
				var value = keyvalue[1];
				/* so try to set it */
				if (! setOption(key,value) ) {
					/* if we can not,
					 * then it is a positional arg */
					pos_args.add(arg);
				}
			}
		}
		/* now we can assign the pos_args back to args */
		args = pos_args;

		/* do some customized translations
		 * prior to the default positional parser
		 */
		if (! modifyOptions() ) {
			return false;
		}

		/* now handle the positional args
		 * and also set the defaults */

		/* get the arg info for this class */
		var entries = getArgumentEntries();
		/* loop entries */
		foreach(var entry in entries) {
			if (hasOption(entry.name)) {
				/* do nothing */
			} else if (entry.is_positional) {
				if (args.size>0) {
					/* create a new class */
					setOption(
						entry.name,
						args.remove_at(0)
						);
				} else {
					rrd.error.setErrorString(
						"Positional argument for %s not given"
						.printf(entry.name)
						);
					return false;
				}
			} else {
				/* set the default */
				if (entry.default_value != null) {
					setOption(
						entry.name,
						entry.default_value
						);
				} else {
/*
					rrd.error.setErrorStringIfNull(
						"missing argument for %s"
						.printf(entry.name)
						);
*/
				}
			}
		}

		/* and return OK */
		return true;
	}

	/**
	 * get the prefix to use on the command context
	 * by default try to use "name", "vname" or "id"
	 * @param cmd the command to which we link
	 */
	protected virtual string getPrefixName(
		rrd.command cmd) {
		/* some defaults to minimize coding */
		if (hasOption("name")) {
			return getOption("name").to_string();
		} else if (hasOption("vname")) {
			return getOption("vname").to_string();
		} else if (hasOption("id")) {
			return getOption("id").to_string();
		} else {
			/* otherwise we get the generated version */
			return cmd.getNewName(get_type().name());
		}
	}

	/**
	 * get the argument_entry that fits the name
	 * @param name
	 * @return rrd.argument_entry that matches or null
	 */
	protected rrd.argument_entry? getArgumentEntry(string name)
	{
		/* get the arg info for this class */
		var entries = getArgumentEntries();
		/* iterate to find */
		foreach(var ae in entries) {
			if (strcmp(ae.name,name) == 0) {
				return ae;
			}
		}
		/* return empty */
		return null;
	}

	/**
	 * creates new value object with name and value
	 * this is based on the argument_entries defined
	 * @param name the name of the field for which to create the object
	 * @param value the value (as a string) to assign to the object
	 * @return rrd.value or null
	 */
	protected rrd.value? getClassForKey(
		string name, string value)
	{
		/* get the argument entry */
		var ae = getArgumentEntry(name);
		if (ae == null) {
			return null;
		}
		/* now use the class factory */
		var obj = rrd.value.factory(
			ae.class_name,
			value);
		return obj;
	}

	public override void parse_String()
	{ ; }

	public override string? to_string()
	{ return "TODO"; }

	/**
	 * delegate method that will take parse the class arguments
	 * that have not been parsed and return a replacement version
	 * @return the new rrd_object
	 */
	public override rrd.object? delegate()
	{
		/* if we are not of type rrdcommand then parse args */
		string cname=this.get_type().name();
		if( strcmp(cname,"rrdargument") != 0) {
			/* if there are any positional arguments NOT used,
			 * then we fail
			 */
			if (args.size > 0) {
				string unclaimed="";
				for(int i=0;i<args.size;i++) {
					unclaimed += ((i>0) ? ":" : "")
						+ args.get(i);
				}
				rrd.error.setErrorString(
					"Unclaimed arguments: %s"
					.printf(unclaimed)
					);
				return null;
			}
			/* otherwise return this */
			return this;
		}

		/* check if we got cmd as option */
		string cmd;
		if (hasOption("cmd")) {
			cmd = ((rrd.value_string)getOption("cmd"))
				.to_string();
		} else {
			/* otherwise try to fetch from args */
			if (args.size <1) {
				/* check if we got help */
				rrd.error.setErrorString(
					"Unexpected length - need at least 1 arg as command");
				return null;
			} else {
				cmd = args.poll_head();
			}
		}
		/* now get the command itself in lower case */
		string cmdbase = command.get_type().name();

		/* and delegate to it using parent */
		return (rrd.argument) classFactory(
			cmdbase + "_" + cmd.down(),
			"rrdargument",
			"parent",this
			);
	}


	/**
	 * split_colon method, that also takes care of escaped colons
	 * @param arg the string which we should split
	 * @return list of asplit objects
	 */
	protected static LinkedList<string>? split_colon(string arg)
	{
		/* move it to an LinkedList on split
		 * but also join the ones that have been escaped
		 */
		var arglist = new LinkedList<string>();
		string merged = "";
		foreach(var str in arg.split_set(":")) {
			/* find trailing escape,
			 * but only ones that are not escaped itself
			 */
			if ( (str.length == 1)
				/* case one of trailing escape */
				&& (str.substring(-1, 1) == "\\") ) {
				merged += str.substring(0, str.length-1)+":";
			} else if ( (str.length > 1)
				/* case two of trailing escape
				 * checking that the escape is not
				 * escaped itself...
				 */
				&& (str.substring(-1, 1) == "\\")
				&& (str.substring(-2, 1) != "\\\\")
				) {
				merged += str.substring(0,str.length-2)+":";
			} else {
				/* otherwise add to list and empty merged */
				arglist.add(merged + str);
				merged = "";
			}
		}
		/* if we got a "trailing" \, then there is something wrong */
		if (merged != "") {
			rrd.error.setErrorString(
				"Error: unterminated escape \\ string\n");
			return null;
		}
		/* otherwise return arglist */
		return arglist;
	}

	/**
	 * the factory that transforms a positional argument
	 * into an object
	 * @param command the command for which we do this
	 * @param cmdstr  the string which we need to parse
	 * @return rrd.command object or null
	 */
	public static new rrd.argument? factory(
		rrd.command command, string cmdstr)
	{

		/* split into a list */
		var split = split_colon(cmdstr);
		if (split == null) {
			return null;
		}

		/* and now create the Class object
		 * - this has delegate implemented!!!
		 */
		return (rrd.argument) classFactory(
				"rrdargument",
				null,
				"args",split,
				"command", command
			);
	}

}

/**
 * cachedargument class, that implements caching on the computation of
 * getValue
 */
public abstract class rrd.argument_cachedGetValue : rrd.argument {
	/**
	 * the cached result, so that we do not have to recalculate
	 * the value every time */
	protected rrd.value cached_calcValue = null;

	/**
	 * central rrd.value.getValue implementation
	 * that does take care of caching the computational data
	 * @param cmd   the command to which this belongs
	 * @param skipvalue skip value calculations
	 * @param stack the rpn_stack to work with - if null, then this is
	 *              not part of a rpn calculation
	 * @returns rrd_value with the value given - may be this
	 */
	public override rrd.value? getValue(
		rrd.command cmd,
		bool skipcalc,
		rrd.rpn_stack? stack_arg)
	{
		if (skipcalc)
			return null;
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
