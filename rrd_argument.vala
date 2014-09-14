using GLib;
using Gee;

struct rrd_argument_entry {
	public unowned string    name;
	public char              short_name;
	public rrd_value_type    type;
	public bool              is_positional;
	public unowned string?   default_value;
	public unowned string    description;
	public unowned string    arg_description;
}

class rrd_argument : rrd_object {

	/* our own split_colon method
	 * that also takes care of escaped colons */
	public static ArrayList<string>? split_colon(string arg) {
		/* move it to an ArrayList on split
		 * but also join the ones that have been escaped
		 */
		var arglist = new ArrayList<string>();
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

	/* the factory that transforms a positional argument
	 * into an object */
	public static rrd_argument? factory(
		rrd_command command, string cmdstr) {

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

		/* and now create the Class object */
		rrd_argument argclass =
			(rrd_argument) rrd_object.classFactory(
				base_class + "_" + cmdname,
				"rrd_argument");
		if (argclass == null) {
			stderr.printf("ARG: %s\n",cmdname);
			return null;
		}
		/* now parse the arguments received in full */
		if (!argclass.parseArgs(command,split)) {
			return null;
		}

		return argclass;
	}

	protected const rrd_argument_entry[] DEFAULT_ARGUMENT_ENTRIES =
		{ { null } };

	protected virtual rrd_argument_entry[] getArgumentEntries()
	{ return DEFAULT_ARGUMENT_ENTRIES; }

	protected virtual bool modifyParsedArguments(
		TreeMap<string,string> parsed,
		ArrayList<string> positional)
	{ return true; }

	protected bool parseArgs(rrd_command command,
				ArrayList<string>? arg_list)
	{
		/* get the arg info for this class */
		var entries = getArgumentEntries();

		/* list of positional=unhandled args */
		var pos_args = new ArrayList<string>();
		var parsed_args = new TreeMap<string,string>();

		/* copy debug if it exists */
		var debug = command.getParsedArgument("debug");
		if (debug != null) {
			parsed_args.set("debug",debug);
		}

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
				if (strcmp(key,"id") == 0) {
					parsed_args.set(key, value);
				} else if (strcmp(key,"debug") == 0) {
					parsed_args.set(key, value);
				} else {
					if (haveArgumentEntry(
							entries, key)
						) {
						/* and assign it */
						parsed_args.set(key, value);
					} else {
						pos_args.add(arg);
					}
				}
			}
		}

		/* do some customized translations
		 * prior to the default positional parser*/
		if (! modifyParsedArguments(parsed_args, pos_args) ) {
			return false;
		}

		/* now handle the positional args and also set the defaults */
		foreach(var entry in entries) {
			if (parsed_args.has_key(entry.name)) {
				/* do nothing */
			} else if (entry.is_positional) {
				if (pos_args.size>0) {
					parsed_args.set(
						entry.name,
						pos_args.remove_at(0)
						);
				} else if (entry.default_value != null) {
					parsed_args.set(
						entry.name,
						entry.default_value);
				} else {
					stderr.printf("Positional argument"
						+ "for %s not given\n",
						entry.name);
					return false;
				}
			} else if (entry.name!=null) {
				parsed_args.set(entry.name,
						entry.default_value);
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

		/* now set it in command context */
		if (! setCommandContext(command, parsed_args)) {
			return false;
		}

		/* dump what we have found */
		if (parsed_args.get("debug")!=null)  {
			foreach(var arg in parsed_args) {
				stderr.printf("   Parsed arg: %s = %s\n",
					arg.key,arg.value);
			}
		}

		/* and return OK */
		return true;
	}

	/* by default try to use "name", "vname" or "id" */
	protected virtual string getPrefixName(
		rrd_command cmd,
		TreeMap<string,string> parsed) {
		var prefix=parsed.get("name");
		if (prefix != null) { return prefix; }
		prefix=parsed.get("vname");
		if (prefix != null) { return prefix; }
		prefix=parsed.get("id");
		if (prefix != null) { return prefix; }
		/* otherwise we get the command */
		return cmd.getNewName(get_type().name());
	}

	protected virtual bool setCommandContext(
		rrd_command command,
		TreeMap<string,string> parsed)
	{
		/* get the prefix to use */
		var prefix=getPrefixName(command, parsed);

		/* now we need to set it in the command context */
		foreach(var kv in parsed) {
			command.setParsedArgument(prefix+"."+kv.key,kv.value);
		}
		return true;
	}

	protected bool haveArgumentEntry(
		rrd_argument_entry[] entries, string key)
	{
		foreach(var entry in entries) {
			if (strcmp(entry.name,key) == 0) {
				return true;
			}
		}
		return false;
	}
}
