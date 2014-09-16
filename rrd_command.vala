using GLib;
using Gee;

public class rrd_command : rrd_object {

	public ArrayList<string> argsList { get; construct; }
	construct {
		assert(argsList != null);
		parseArgs(argsList);
	}

	/* the constructor */
	public rrd_command(ArrayList<string> args)
	{ Object(argsList: args); }

	/* the argument objects in sequence */
	protected ArrayList<rrd_argument> arg_list =
		new ArrayList<rrd_argument>();

	/* the parsed arguments so far */
	protected TreeMap<string,rrd_value> parsed_args =
		new TreeMap<string,rrd_value>();

	/* the common arguments */
	protected const rrd_argument_entry[] COMMON_ARGUMENT_ENTRIES = {
		{ "debug",   0,
		  "rrd_value_flag",
		  "0",
		  false,
		  "enable debugging" },
		{ "verbose", 'v',
		  "rrd_value_flag",
		  "0",
		  false,
		  "increase verbosity" }
	};
	/* the command options that the implementations have */
	protected virtual rrd_argument_entry[]? getCommandOptions()
	{ return null; }

	public void setParsedArgument(string key, rrd_value value)
	{
		parsed_args.set(key,value);
	}

	public rrd_value? getParsedArgument(string key)
	{
		if (parsed_args.has_key(key)) {
			return parsed_args.get(key);
		}
		return null;
	}

	public void dump()
	{
		stderr.printf("Command: %s\n",get_type().name());
		foreach(var val in parsed_args) {
			rrd_value v = val.value;
			if (val.value == null) {
				stderr.printf("\t%-40s\t = NULL\n",
					val.key);
			} else {
				var vtype = v.get_type().name();
				var vstr = v.to_string();
				stderr.printf("\t%-40s\t = (%s)\t%s\n",
					val.key,
					vtype,
					vstr);
			}
		}
	}

	public string getNewName(string group = "default")
	{
		var key = ".unnamed_counter." + group;
		var count = getParsedArgument(key);
		if (count == null) {
			count = new rrd_value_counter();
			setParsedArgument(key,count);
		}

		/* and get the value to print */
		return group+count.to_string();
	}

	/* and the positional Argument Parser */
	protected virtual bool
		parsePositionalArguments(ArrayList<string> args)
	{
		/* iterate the arguments */
		foreach(var arg in args) {
			var argclass=rrd_argument.factory(this,arg);
			if (argclass==null) {
				return false;
			}
			/* now link the argument hashes here
			 * - mostly to make rpns work (easily)
			 */
			argclass.linkToCommand(this);

			/* add to list of arguments */
			arg_list.add(argclass);
		}
		return true;
	}

	/* common method to get the "complete" name */
	protected rrd_argument_entry? getArgEntryForName(string fullname)
	{
		/* get the command options */
		var command_options = getCommandOptions();

		/* get the name to look into */
		if(fullname.substring(0,2) == "--") {
			var name = fullname.substring(2,-1);
			foreach(var option in COMMON_ARGUMENT_ENTRIES) {
				if (strcmp(option.name,name)==0) {
					return option;
				}
			}
			if (command_options != null) {
				foreach(var option in command_options) {
					if (strcmp(option.name,name)==0) {
						return option;
					}
				}
			}
		} else {
			char short_name = (char) fullname.data[1];
			foreach(var option in COMMON_ARGUMENT_ENTRIES) {
				if (option.short_name == short_name) {
					return option;
				}
			}
			if (command_options != null) {
				foreach(var option in command_options) {
					if (option.short_name == short_name) {
						return option;
					}
				}
			}
		}
		/* in case of no match return empty */
		return null;
	}

	/* the callback to set the values */
	protected static bool optionCallback(
		string nam,
		string? val,
		rrd_command data,
		ref OptionError error)
		throws OptionError
	{
		/* translate name */
		var ae = data.getArgEntryForName(nam);
		/* create the value needed */
		var value = rrd_value.from_ArgEntry(ae,val);
		/* set in array */
		data.parsed_args.set(ae.name,value);
		/* return OK */
		return true;
	}

	protected void add_command_args(OptionGroup group,
				 rrd_argument_entry[] command_options)
	{
		foreach (var co in command_options) {
			/* add also the default values to the structure */
			rrd_value def = null;
			if (co.default_value != null) {
				assert(co.is_positional != true);
				def = (rrd_value) classFactory(
					co.class_name, "rrd_value",
					"String", co.default_value);
				parsed_args.set(co.name, def);
			}
			/* first  create the  option entry */
			var optentries = new OptionEntry[1];
			/* copy some stuff */
			optentries[0].long_name       = co.name;
			optentries[0].short_name      = co.short_name;
			optentries[0].description     = co.description;
			optentries[0].arg_description = co.arg_description;
			optentries[0].arg             = OptionArg.CALLBACK;
			/* assume default settings */
			optentries[0].flags           = 0;
			optentries[0].arg_data
				= (void *)optionCallback;
			/* now based on default do something special */
			if (def != null) {
				def.modifyOptEntry(ref optentries[0]);
			}
			/* and add the entries */
			group.add_entries(optentries);
		}
	}


	/* the constructor using arguments - public only with subclasses */
	protected void parseArgs(ArrayList<string> args)
	{
		/* based on the class st values differently */
		bool ignore_ukn = false;
		bool help_en = true;
		if (strcmp(get_type().name(),"rrd_command")==0) {
			ignore_ukn = true;
			help_en = false;
		}

		/* get the args as an array - we need to pass an array
		 * to GOption, otherwise we lose the resizes on
		 * function return
		 */
		string[] args_array = new string[args.size+1];
		int i = 0;
		/* dummy to make OptionContext.parse() happy */
		args_array[i++] = "rrdtool";
		foreach(var arg in args) {
			args_array[i++] = arg;
		}

		/* create main context */
		var opt_context = new OptionContext (
			"- rrdtool common arguments");
		opt_context.set_help_enabled (help_en);
		opt_context.set_ignore_unknown_options(ignore_ukn);

		/* create the common context */
		OptionGroup opt_group_common =
			new OptionGroup("common",
					"round robin database tool",
					"Common Arguments",
					this);

		/* add entries to group */
		add_command_args(opt_group_common,
				COMMON_ARGUMENT_ENTRIES);
		/* add it to the main context */
		opt_context.set_main_group((owned)opt_group_common);

		/* add the command specific options
		 * - overridden by subclass */
		var command_options = getCommandOptions();
		if (command_options != null) {
			/* get the name of the class */
			var cmdname =
				this.get_type().name()
				/* stripping rrd_command_ */
				.substring(12);

			/* create a option group */
			OptionGroup opt_group_command =
				new OptionGroup(
					cmdname,
					cmdname + " arguments",
					"show " + cmdname
					+ " Arguments",
					this);
			/* transform the arguments */
			add_command_args(opt_group_command,
					command_options);
			/* and add it to the context */
			opt_context.add_group(
				(owned)opt_group_command);
		}
		/* now try to parse */
		try {
			/* and try to parse everything so far */
			opt_context.parse(ref args_array);
		} catch (OptionError e) {
			stderr.printf ("error: %s\n", e.message);
		}

		/* and convert args_array back to args for the caller
		 * to have the info of what is left
		 */
		args.clear();
		foreach(var arg in args_array) { args.add(arg); }

		/* and stript the "dummy" command again */
		args.remove_at(0);

		/* and parse the Positional Arguments
		 * if we are NOT of type rrd_command itself */
		if(strcmp(this.get_type().name(),"rrd_command") != 0) {
			parsePositionalArguments(args);
		}
	}

	public virtual bool execute()
	{
		stderr.printf("SHOULD NOT GET HERE\n");
		assert(false);
		return false;
	}

	public static rrd_command? factorySysArgs(string[] sysargs)
	{
		/* move to args as list */
		var args=new ArrayList<string>();
		for(int i=1;i<sysargs.length;i++) {
			args.add(sysargs[i]);
		}
		/* and call the "normal" factory */
		return factory(args);
	}

	public static new rrd_command? factory(ArrayList<string> args)
	{
		/* here we need to create a copy of the ArrayList first,
		 * as we need to parse/strip the common args first once
		 * to get to the command
		 */
		var args_copy = new ArrayList<string>();
		foreach(var arg in args) { args_copy.add(arg); }

		/* now create a generic rrd_command to strip out the
		 * common arguments so that we get to the command
		 * we forget about it immediately
		 */
		var base_cmd = new rrd_command(args_copy);
		base_cmd = null; /*just to avoid warnings */

		/* now check if we got a command  */
		if (args_copy.size <1) {
			/* check if we got help */
			stderr.printf("Unexpected length"
				+ " - need at least 1 arg as command!\n");
			return null;
		}
		/* now get the command itself in lower case
		 * - it is the first positional arg by now
		 */
		string command = args_copy.remove_at(0).down();

		/* also remove the string from the final argument list */
		if (!args.remove(command)) {
			stderr.printf("could not find %s in argument list"
				+ " - it should be there!\n", command);
			return null;
		}

		/* create an object with a predefined name and a subclass */
		rrd_command cmdclass = (rrd_command) classFactory(
			"rrd_command_" + command,
			"rrd_command",
			"argsList", args
			);

		/* and return the class */
		return cmdclass;
	}

}
