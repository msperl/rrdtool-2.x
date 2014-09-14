using GLib;
using Gee;

class rrd_command : rrd_object {

	/* the parsed arguments so far */
	protected Map<string,string> parsed_args;

	public void setParsedArgument(string key, string? value)
	{
		parsed_args.set(key,value);
	}
	public string getParsedArgument(string key)
	{ return parsed_args.get(key); }

	/* the common arguments */
	protected const OptionEntry[] COMMON_OPTIONS = {
		/* format: long option, short option char, flags, argstype,
		 * argdata,description,arg_description)
		 */
		{ "debug", 'd', OptionFlags.NO_ARG, OptionArg.CALLBACK,
		  (void *)optionCallback, "debug", ""},
		{ "verbose", 'v', OptionFlags.NO_ARG, OptionArg.CALLBACK,
		  (void *)optionIncreaseCallback, "verbose",""},
		{ null }
	};

	/* the command options that the implementations have */
	protected virtual OptionEntry[]? getCommandOptions()
	{ return null; }

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
		}
		return true;
	}

	/* common method to get the "complete" name */
	protected string? getLongNameFromArg(string name)
	{
		/* this is a bit more complicated than necessary,
		 * but that is the way that GOptions works...
		 */
		/* if we have the long name, then use it */
		if(name.substring(0,2) == "--") {
			return name.substring(2,-1);
		}
		/* else we need to translate shorts to long names */
		string short_name = name.substring(1,1);
		/* transform short name to long name */
		foreach(var option in COMMON_OPTIONS) {
			if (option.short_name.to_string() == short_name) {
				return option.long_name;
			}
		}
		/* now try the specific names */
		var command_options = getCommandOptions();
		if (command_options != null) {
			foreach(var option in command_options) {
				if (option.short_name.to_string()
					== short_name) {
					return option.long_name;
				}
			}
		}
		/* in case of no match return the short name */
		return short_name;
	}

	/* the callback to set the values */
	protected static bool optionCallback(
		string name,
		string? val,
		rrd_command data,
		ref OptionError error)
		throws OptionError
	{
		/* translate name */
		var n = data.getLongNameFromArg(name);
		/* set in array */
		data.parsed_args.set(n,val ?? "1");
		/* return OK */
		return true;
	}

	/* callback to set values, but increase by 1 every time we find it */
	protected static bool optionIncreaseCallback(
		string name,
		string? val,
		rrd_command data,
		ref OptionError error)
		throws OptionError
	{
		/* translate name */
		var n = data.getLongNameFromArg(name);
		/* now get the old value */
		int v = 0;
		if (data.parsed_args.has_key(n)) {
			v = data.parsed_args.get(n).to_int();
		}
		/* and set the incremented version */
		data.parsed_args.set(n,"%d".printf(v+1));
		/* and return OK */
		return true;
	}

	/* the constructor */
	public rrd_command(ArrayList<string>? args = null,
			bool ignore_ukn = false,
			bool help_en = true)
	{
		parseArgs(args,ignore_ukn,help_en);
	}

	/* the constructor using arguments - public only with subclasses */
	protected bool parseArgs(ArrayList<string>? args,
				bool ignore_ukn = false,
				bool help_en = true)
	{
		/* if the args are null, then return */
		if (args == null) {
			return false;
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

		/* allocate the map of parsed args */
		this.parsed_args = new TreeMap<string,string>();

		/* try to parse the args for now */
		try {
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
			opt_group_common.add_entries(COMMON_OPTIONS);
			/* add it to the context */
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
				opt_group_command.add_entries(
					command_options);
				/* and add it to the context */
				opt_context.add_group(
					(owned)opt_group_command);
			}
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
			return parsePositionalArguments(args);
		}
		return true;
	}

	public virtual bool execute()
	{
		stderr.printf("SHOULD NOT GET HERE\n");
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
		new rrd_command(args_copy,true,false);

		/* now check if we got a command  */
		if (args_copy.size <2) {
			stderr.printf("Unexpected length"
				+ "- need at least 1 arg as command!\n");
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
		rrd_command cmdclass =
			(rrd_command) rrd_object.classFactory(
				"rrd_command_" + command,
				"rrd_command");

		/* trigger the parser again
		 * I have not found a means to do that with the above new */
		if (cmdclass!=null) {
			cmdclass.parseArgs(args);
		}

		/* and return the class */
		return cmdclass;
	}

}
