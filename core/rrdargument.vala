/* rrdobject.vala
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
 * structure containing the argument option flags
 */
public struct rrd.argument_entry {
	/**
	 * the long name of the option - e.g --<name>
	 */
	public unowned string    name;
	/**
	 * the short name of the option - e.g -<short_name>
	 */
	public char              short_name;
	/**
	 * the class name of the object to generate for this object
	 */
	public string            class_name;
	/**
	 * the default value to set when not set as option
	 */
	public string            default_value;
	/**
	 * flag if it is a positional argument
	 * if so, then the order is important
	 */
	public bool              is_positional;
	/**
	 * the description string
	 */
	public unowned string    description;
	/**
	 * the argument description
	 */
	public unowned string    arg_description;
}

/**
 * the (positional) argument class
 */
public abstract class rrd.argument : rrd.value {
	/**
	 * constructor argument list of arguments to this argument
	 */
        public LinkedList<string> argsList { get; construct; }
	/**
	 * constructor
	 */
        construct {
		assert(argsList != null);
		parseArgs(argsList);
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
	 * the parsed options as a map for quick access.
	 * this also contains the options of arguments,
	 * so that the parameters of those can also get
	 * used for rpn calculations
	 */
	protected TreeMap<string,rrd.value> options;

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
			return res.getValue(cmd,null);
		}
		return res;
	}

	/**
	 * set option key to value
	 * @param key the key to set
	 * @param value the value to set
	 * @return status if OK
	 */
	protected bool setOption(string key, string value)
	{
		/* create a new class */
		rrd.value val = getClassForKey(key,value);
		/* if it is set, then it is in entries */
		if (val != null) {
			options.set(key,val);
			return true;
		} else {
			return false;
		}
	}

	/**
	 * dump the argument info
	 */
	public void dump() {
		stderr.printf("%s.dump():\n",get_type().name());
		foreach(var arg in options) {
			stderr.printf("   Parsed arg: %s = %s\n",
				arg.key,arg.value.to_string());
		}
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
		foreach(var str in arg.split(":")) {
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
			stderr.printf(
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

		/* now start processing those entries
		 * to get the type of arg */
		string cmdname_find = null;
		string cmdname = null;
		foreach(var arg in split) {
			/* try to split in key/values */
			var keyvalue=arg.split("=",2);
			/* now  check if we got key+value */
			if (keyvalue.length == 1) {
				/* postitional argument */
				if ( cmdname == null ) {
					cmdname_find = arg;
					cmdname = arg.down();
				}
			} else {
				/* got key/value, so check if key is "cmd" */
				if (keyvalue[0] == "cmd") {
					cmdname_find = arg.down();
					cmdname = keyvalue[1];
				}
			}
		}

		/* now that we got everything remove the entries */
		if (cmdname != null) {
			split.remove(cmdname_find);
		}

		/* get the (base classname) for the classname */
		var base_class=command.get_type().name();

		/* and now create the Class object
		 * - this has delegate implemented!!!
		 */
		return (rrd.argument) classFactory(
				base_class + "_" + cmdname,
				"rrdargument",
				"argsList",split);
	}

	/**
	 * the default empty list of argument entries
	 */
	protected const rrd.argument_entry[] DEFAULT_ARGUMENT_ENTRIES =
		{ };

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
	protected virtual bool modifyOptions(
		LinkedList<string> positional)
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

		/* now link it in command context
		 * - mostly for rpn calculations */

		/* get the prefix to use */
		var prefix=getPrefixName(command);

		/* link the argument itself */
		linkToCommandFullName(command,prefix);

		/* now set our options in the command context
		 * - this should be a reference
		 */
		foreach(var kv in options) {
			command.setOption(
				prefix+"."+kv.key,
				kv.value);
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
	protected bool parseArgs(LinkedList<string>? arg_list)
	{
		/* list of positional=unhandled args */
		var pos_args = new LinkedList<string>();
		/* initialize map of keys */
		options = new TreeMap<string,rrd.value>();

		/* now parse the args */
		foreach(var arg in arg_list) {
			/* try to split in key/values */
			var keyvalue=arg.split("=",2);
			/* if we got a single entry only,
			 * then it IS a positional arg */
			if (keyvalue.length == 1) {
				pos_args.add(arg);
			} else {
				var key = keyvalue[0];
				var value = keyvalue[1];
				rrd.value val = null;
				if (strcmp(key,"debug") == 0) {
					val = new rrd.value_bool.bool(true);
					options.set(key,val);
				} else {
					if (! setOption(key,value)) {
						pos_args.add(arg);
					}
				}
			}
		}

		/* do some customized translations
		 * prior to the default positional parser
		 */
		if (! modifyOptions(pos_args) ) {
			return false;
		}

		/* now handle the positional args and also set the defaults */
		/* get the arg info for this class */
		var entries = getArgumentEntries();

		foreach(var entry in entries) {
			if (hasOption(entry.name)) {
				/* do nothing */
			} else if (entry.is_positional) {
				if (pos_args.size>0) {
					/* create a new class */
					setOption(
						entry.name,
						pos_args.remove_at(0)
						);
				} else {
					stderr.printf("Positional argument"
						+ "for %s not given\n",
						entry.name);
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
					stderr.printf("Missing argument"
						+ "- no default value for %s\n",
						entry.name);
				}
			}
		}

		/* if there are any positional arguments NOT used,
		   then we fail */
		if (pos_args.size > 0) {
			string unclaimed="";
			for(int i=0;i<pos_args.size;i++) {
				unclaimed += ((i>0) ? ":" : "")
					+ pos_args.get(i);
			}
			stderr.printf(
				"Unclaimed positional arguments: %s\n",
				unclaimed);
			return false;
		}

		/* dump what we have found */
		if (options.get("debug")!=null)  {
			dump();
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
	 */
	protected bool haveArgumentEntry(
		rrd.argument_entry[] entries, string key)
	{
		foreach(var entry in entries) {
			if (strcmp(entry.name,key) == 0) {
				return true;
			}
		}
		return false;
	}

	protected rrd.argument_entry? getArgumentEntry(string name)
	{
		/* get the arg info for this class */
		var entries = getArgumentEntries();
		/* iterate to find */
		foreach(var ae in entries) {
			if (strcmp(ae.name,name)==0) {
				return ae;
			}
		}
		/* return empty */
		return null;
	}

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
}
