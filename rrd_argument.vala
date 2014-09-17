using GLib;
using Gee;

public struct rrd_argument_entry {
	public unowned string    name;
	public char              short_name;
	public string            class_name;
	public string            default_value;
	public bool              is_positional;
	public unowned string    description;
	public unowned string    arg_description;
}

public class rrd_argument : rrd_value {
        public ArrayList<string> argsList { get; construct; }
        construct {
		assert(argsList != null);
		parseArgs(argsList);
        }

	public bool execute(rrd_command cmd) {
		return true;
	}

	private TreeMap<string,rrd_value> parsed_args;

	public bool hasParsedArgument(string key)
	{ return parsed_args.has_key(key); }

	public rrd_value? getParsedArgument(string key)
	{ return parsed_args.get(key); }

	public rrd_value? getParsedArgumentValue(
		string key, rrd_command cmd)
	{
		rrd_value res = getParsedArgument(key);
		if (res != null) {
			return res.getValue(cmd,null);
		}
		return res;
	}

	protected bool setParsedArgument(string key, string value) {
		/* create a new class */
		rrd_value val = getClassForKey(key,value);
		/* if it is set, then it is in entries */
		if (val != null) {
			parsed_args.set(key,val);
			return true;
		} else {
			return false;
		}
	}

	public void dump() {
		stderr.printf("%s.dump():\n",get_type().name());
		foreach(var arg in parsed_args) {
			stderr.printf("   Parsed arg: %s = %s\n",
				arg.key,arg.value.to_string());
		}
	}

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
	public static new rrd_argument? factory(
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
				"rrd_argument",
				"argsList",split);

		return argclass;
	}

	protected const rrd_argument_entry[] DEFAULT_ARGUMENT_ENTRIES =
		{ };

	protected virtual rrd_argument_entry[] getArgumentEntries()
	{ return DEFAULT_ARGUMENT_ENTRIES; }

	protected virtual bool modifyParsedArguments(
		ArrayList<string> positional)
	{ return true; }

	public void linkToCommand(rrd_command command) {
		/* copy debug from global context if it exists
		 * and we have not set it locally */
		if (! hasParsedArgument("debug")) {
			var cmd_debug = command.getParsedArgument("debug")
				?? new rrd_value_flag(false);
			/* this is an exception */
			parsed_args.set("debug", cmd_debug);
		}

		/* now link it in command context
		 * - mostly for rpn calculations */

		/* get the prefix to use */
		var prefix=getPrefixName(command);

		/* link the argument itself */
		linkToCommandFullName(command,prefix);

		/* now set it in the command context
		 * - this should be a reference */
		foreach(var kv in parsed_args) {
			command.setParsedArgument(
				prefix+"."+kv.key,
				kv.value);
		}
	}

	protected virtual void linkToCommandFullName(
		rrd_command command,
		string prefix)
	{ command.setParsedArgument(prefix,this); }

	protected bool parseArgs(ArrayList<string>? arg_list)
	{
		/* list of positional=unhandled args */
		var pos_args = new ArrayList<string>();
		/* initialize map of keys */
		parsed_args = new TreeMap<string,rrd_value>();

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
				rrd_value val = null;
				if (strcmp(key,"debug") == 0) {
					val = new rrd_value_flag(true);
					parsed_args.set(key,val);
				} else {
					if (! setParsedArgument(key,value)) {
						pos_args.add(arg);
					}
				}
			}
		}

		/* do some customized translations
		 * prior to the default positional parser
		 */
		if (! modifyParsedArguments(pos_args) ) {
			return false;
		}

		/* now handle the positional args and also set the defaults */
		/* get the arg info for this class */
		var entries = getArgumentEntries();

		foreach(var entry in entries) {
			if (hasParsedArgument(entry.name)) {
				/* do nothing */
			} else if (entry.is_positional) {
				if (pos_args.size>0) {
					/* create a new class */
					setParsedArgument(
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
					setParsedArgument(
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
		if (parsed_args.get("debug")!=null)  {
			dump();
		}

		/* and return OK */
		return true;
	}

	/* by default try to use "name", "vname" or "id" */
	protected virtual string getPrefixName(
		rrd_command cmd) {
		/* some defaults to minimize coding */
		if (hasParsedArgument("name")) {
			return getParsedArgument("name").to_string();
		} else if (hasParsedArgument("vname")) {
			return getParsedArgument("vname").to_string();
		} else if (hasParsedArgument("id")) {
			return getParsedArgument("id").to_string();
		} else {
			/* otherwise we get the generated version */
			return cmd.getNewName(get_type().name());
		}
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

	protected rrd_argument_entry? getArgumentEntry(string name)
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

	protected rrd_value? getClassForKey(
		string name, string value)
	{
		/* get the argument entry */
		var ae = getArgumentEntry(name);
		if (ae == null) {
			return null;
		}
		/* now use the class factory */
		var obj = rrd_value.factory(
			ae.class_name,
			value);
		return obj;
	}

	public override bool parse_String()
	{
		return false;
	}

	public override string? to_string()
	{
		return "TODO";
	}
}
