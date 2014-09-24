/* rrdcommand.vala
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
 * the rrd command object
 *
 * from this object all commands are derived
 */

public class rrd.command : rrd.object {

	/**
	 * the parent rrd_command from which we are derived
	 */
	public rrd.command parent { get; construct; }

	/**
	 * the list of arguments to get processed when using
	 * the GObject constructor
	 */
	public LinkedList<string> args { get; protected construct set; }

	/**
	 * the parsed positional argument objects in sequence
	 */
	protected LinkedList<rrd.argument> parsed_args;

	/**
	 * the parsed options as a map for quick access.
	 * this also contains the options of arguments,
	 * so that the parameters of those can also get
	 * used for rpn calculations
	 */
	protected TreeMap<string,rrd.value> options;

	/**
	 * the created complete stack of command options
	 * only really used for --help
	 */
	protected OptionContext completeCommandOptions;

	/**
	 * the main constructor that handles things differently
	 * if we are delegated or not
	 */
	construct {
		/* if we got a parent so this is happening during delegation
		 * copy the things from parent - we can highjack it, as it
		 * (should) get destroyed anyway inside the factory
		 */
		if (parent != null) {
			args =
				parent.args;
			parsed_args = (owned)
				parent.parsed_args;
			options = (owned)
				parent.options;
			completeCommandOptions = (owned)
				parent.completeCommandOptions;
			parent = null;
			/* and parse the arguments again,
			 * but this time using the new class*/
			parseArgs();
		} else {
			/* otherwise hope that we got something in args */
			if (args == null) {
				rrd.error.setErrorString(
					"construct %s without args set"
					.printf(this.get_type().name()));
			} else {
				parsed_args = new LinkedList<rrd.argument>();
				options = new TreeMap<string,rrd.value>();
				/* create the basic command options */
				completeCommandOptions = new OptionContext (
					"- rrdtool common arguments");
				completeCommandOptions
					.set_help_enabled(false);
				completeCommandOptions
					.set_ignore_unknown_options(true);
				/* and parse the arguments */
				parseArgs();
			}
		}
	}

	/**
	 * the common arguments during parsing
	 */
	protected const rrd.argument_entry[] COMMON_ARGUMENT_ENTRIES = {
		{ "help",  '?',
		  "rrdvalue_bool",
		  "false",
		  false,
		  "help flag" },
		{ "debug",   0,
		  "rrdvalue_bool",
		  "false",
		  false,
		  "enable debugging" },
		{ "verbose", 'v',
		  "rrdvalue_bool",
		  "false",
		  false,
		  "increase verbosity" }
	};

	/**
	 * the command options that we need to check during this iteration
	 * @return array of rrd.argument_entry
	 */
	protected virtual rrd.argument_entry[] getCommandOptions()
	{ return COMMON_ARGUMENT_ENTRIES; }

	/**
	 * set option key to value
	 * @param key the key to set
	 * @param value the value to set
	 */
	public void setOption(string key, rrd.value value)
	{
		options.set(key,value);
	}

	/**
	 * check if we have an option
	 * @param key the key to check
	 * @return if the key exists in the list of options
	 */
	public bool hasOption(string key)
	{
		return options.has_key(key);
	}

	/**
	 * get the option value with name key
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
	 * dump the option state of this command
	 */
	public void dump()
	{
		stderr.printf("Command: %s\n",get_type().name());
		/* iterate all options */
		foreach(var val in options) {
			/* get the value */
			rrd.value v = val.value;
			if (val.value == null) {
				stderr.printf("\t%-40s\t = NULL\n",
					val.key);
			} else {
				/* get the class of the value */
				var vtype = v.get_type().name();
				/* as well as its  value to print */
				var vstr = v.to_string();
				/* if it is a rpn type value */
				if (v is rrd.value_rpn) {
					/* then try to get the effective
					 * value as well */
					var vobj = v.getValue(
						this, null);
					if (vobj == null) {
						stderr.printf(
							"\t%-40s\t = (%s)"
							+ "\t%s = ERROR: %s\n",
							val.key,
							vtype,
							vstr,
							rrd.error.getErrorString()
							);
					} else {
						/* otherwise convert final
						 * value to string and get
						 * the cass-name to print
						 */
						var vval =
							vobj.to_string();
						var vobjtype =
							vobj.get_type().name();
						stderr.printf(
							"\t%-40s\t = (%s)"
							+ "\t%s = (%s) %s\n",
							val.key,
							vtype,
							vstr,
							vobjtype,
							vval
							);
					}
				} else {
					/* just print the rrd_value */
					stderr.printf(
						"\t%-40s\t = (%s)\t%s\n",
						val.key,
						vtype,
						vstr
						);
				}
			}
		}
	}

	/**
	 * create a name for arguments, that do not require explicit
	 * identification, but rely on optional id arguments
	 *
	 * @param group the group name for which we want to create
	 * @return name of the new group - guaranteed to be unique
	 */
	public string getNewName(string group = "default")
	{
		var key = ".unnamed_counter." + group;
		var count = getOption(key);
		if (count == null) {
			count = new rrd.value_counter();
			setOption(key,count);
		}

		/* and get the value to print */
		return group+count.to_string();
	}

	/**
	 * get the corresponding argument entry for an option string
	 * @param name the name of the option
	 * @return the corresponding argument_entry or null
	 */
	protected rrd.argument_entry? getArgumentEntry(string name)
	{
		/* get the arg info for this class */
		var entries = getCommandOptions();
		/* iterate to find */
		foreach(var ae in entries) {
			if (strcmp(ae.name,name)==0) {
				return ae;
			}
		}
		/* return empty */
		return null;
	}

	/**
	 * internal factory function to create a corresponding rrd_value
	 * looking up the key in the argument entries if it does not
	 * exist already
	 * @param key   to look for
	 * @param value the value to set
	 * @return returns the corresponding rrd.value object
	 *         based on the information from the argument_entries
	 *         or null if not found
	 */
	protected rrd.value? getClassForKey(
		string key, string value)
	{
		/* get the argument entry */
		var ae = getArgumentEntry(key);
		if (ae == null) {
			rrd.error.setErrorStringIfNull(
				"Could not find %s in argument entries"
				.printf(key)
				);
			return null;
		}
		/* now use the class factory of rrd_value */
		return rrd.value.factory(
			ae.class_name,
			value);
	}

	/**
	 * parse arguments that have not been identified as options
	 * @return false on failure
	 */
	protected virtual bool
		parsePositionalArguments()
	{
		/* walk the command options to fill in
		 * the defined positional arguments from
		 * the Command Options
		 */
		var command_options = getCommandOptions();
		foreach (var entry in command_options) {
			if (hasOption(entry.name)) {
				/* do nothing */
			} else if (entry.is_positional) {
				if (args.size>0) {
					/* create a new value class */
					var res = getClassForKey(
						entry.name,
						args.poll_head()
						);
					/* return false on parsing errors */
					if (res == null) {
						return false;
					}
					/* and set it as option */
					setOption(
						entry.name,
						res
						);
				} else {
					rrd.error.setErrorString(
						"Positional argument"
						+ "for %s not given"
						.printf(entry.name)
						);
					return false;
				}
			}
		}

		/* iterate the arguments still pending */
		foreach(var arg in args) {
			/* get the argument factory to work */
			var argclass=rrd.argument.factory(this,arg);
			if (argclass==null) {
				return false;
			}
			/* now link the argument hashes here
			 * - mostly to make rpns work (easily)
			 */
			argclass.linkToCommand(this);

			/* add to list of arguments */
			parsed_args.add(argclass);
		}
		return true;
	}

	/**
	 * helper method to get the argument_entry for the option name
	 * @args
	 * */
	protected rrd.argument_entry? getArgEntryForOption(string fullname)
	{
		/* get the command options */
		var command_options = getCommandOptions();

		/* get the name to look into */
		if(
			( fullname.data[0] == '-' )
			&& ( fullname.data[1] == '-' )
			) {
			/* get the substring */
			var name = fullname.substring(2,-1);
			/* and iterate to find the correct one */
			foreach(var option in command_options) {
				if (strcmp(option.name,name)==0) {
					return option;
				}
			}
		} else {
			/* get the short name */
			char short_name = (char) fullname.data[1];
			/* and iterate to find the correct one */
			foreach(var option in command_options) {
				if (option.short_name == short_name) {
					return option;
				}
			}
		}

		/* in case of no match return empty */
		return null;
	}

	/**
	 * the callback used by the option argument
	 * @param name  the name of the argument (short or long!!!)
	 * @param value the value of the argument (if given)
	 * @param data  the data context - in our case rrd.command
	 * @param error an error object to set/clear
	 * @return success or failure
	 */
	protected static bool optionCallback(
		string name,
		string? value,
		rrd.command data,
		ref OptionError error)
		throws OptionError
	{
		/* translate name */
		var arg_entry = data.getArgEntryForOption(name);
		/* create the value needed */
		var value_obj = rrd.value.from_ArgEntry(arg_entry, value);
		/* set in array */
		data.options.set(arg_entry.name, value_obj);
		/* return OK */
		return true;
	}
	/**
	 * helper function that adds command_options to the option group
	 * @param the option group
	 */
	protected void add_command_args(OptionGroup group)
	{
		var command_options = getCommandOptions();
		foreach (var co in command_options) {
			/* set the default values to the structure */
			rrd.value def = null;
			if (co.default_value != null) {
				assert(co.is_positional != true);
				def = (rrd.value) classFactory(
					co.class_name, "rrdvalue",
					"String", co.default_value);
				options.set(co.name, def);
			}
			/* first  create the  option entry */
			var optentries = new OptionEntry[1];
			/* copy some stuff */
			optentries[0].long_name       = co.name;
			optentries[0].short_name      = co.short_name;
			optentries[0].description     = co.description;
			optentries[0].arg_description = co.arg_description;
			optentries[0].arg             = OptionArg.CALLBACK;
			optentries[0].arg_data
				= (void *)optionCallback;
			/* set the flags depending on args */
			optentries[0].flags           =
				(optentries[0].arg_description == null)
				? OptionFlags.NO_ARG : 0;
			/* and add the entries */
			group.add_entries(optentries);
		}
	}

	/**
	 * parse the given constructor arguments
	 */
	protected void parseArgs()
	{
		/* add entries to the option group */
		setOptionGroup();

		/* get the args as an array - we need to pass an array
		 * to GOption, otherwise we lose the resizes on
		 * function return
		 */
		string[] args_array = new string[args.size+1];
		int i = 0;

		/* dummy to make OptionContext.parse() happy */
		args_array[i++] = "rrdool";
		foreach(var arg in args) {
			args_array[i++] = arg;
		}

		/* now try to parse the remaining arguments*/
		try {
			/* and try to parse everything so far */
			completeCommandOptions.parse(ref args_array);
		} catch (OptionError e) {
			rrd.error.setErrorString("parse.error: %s"
						.printf(e.message)
				);
		}
		/* and convert args_array back to args for the caller
		 * to have the info of what is left
		 */
		args.clear();
		foreach(var arg in args_array) { args.add(arg); }

		/* and stript the "dummy" ARGUMENT 0 again */
		args.poll_head();
	}

	/**
	 * set the option group
	 */
	protected void setOptionGroup() {
		OptionGroup opt_group = createOptionGroup();
		/* transform the arguments */
		add_command_args(opt_group);
		/* and add it to the context */
		if (strcmp(get_type().name(),"rrdcommand")==0) {
			completeCommandOptions.set_main_group(
				(owned)opt_group);
		} else {
			completeCommandOptions.add_group(
				(owned)opt_group);
		}

	}

	/**
	 * create the option group
	 * allows classes to override this
	 */
	protected virtual OptionGroup createOptionGroup() {
		/* handle the rrdcommand class case differently */
		var class_name = get_type().name();
		if (strcmp(class_name,"rrdcommand")==0) {
			return new OptionGroup(
				"common",
				"round robin database tool",
				"Common Arguments",
				this);
		}

		/* get the name of the class stripping rrdcommand_*/
		var cmdname = class_name.substring(11);

		/* create a option group */
		return new OptionGroup(
			cmdname,
			cmdname + " arguments",
			"show " + cmdname
			+ " Arguments",
			this);
	}

	/**
	 * execute the command
	 */
	public virtual bool execute()
	{
		stderr.printf("SHOULD NOT GET HERE\n");
		assert(false);
		return false;
	}
	/**
	 * return the help string
	 * @return help string
	 */
	public string getHelp()
	{
		return completeCommandOptions.get_help(false,null);
	}

	/**
	 * delegate method that will take parse the class arguments
	 * that have not been parsed and return a replacement version
	 * @return the new rrd_object
	 */
	public override rrd.object? delegate()
	{
		/* if we are not of type rrdcommand then parse args */
		string cname=this.get_type().name();
		if( strcmp(cname,"rrdcommand") != 0) {
			/* parse the positional arguments */
			if (! parsePositionalArguments()) {
				/* on error return null */
				return null;
			}
			/* otherwise return this */
			return this;
		}

		/* check if we got a command with one
		 * of the additional args */
		if (args.size <1) {
			/* check if we got help */
			rrd.error.setErrorString(
				"Unexpected length"
				+ " - need at least 1 arg as command!");
			return null;
		}
		/* now get the command itself in lower case
		 * - it is the first positional arg by now
		 */
		string command = args.poll_head().down();
		/* and delegate to it using parent */
		return (rrd.command) classFactory(
			"rrdcommand_" + command,
			"rrdcommand",
			"parent",this
			);
	}

	/**
	 * the factory method for rrd_commands in he form of an array of strings
	 * @param args list of arguments passed on the command line
	 * @return returns an rrd.command object  that corresponds to the
	 *         arguments given.
	 */
	public static rrd.command? factorySysArgs(string[] sysargs)
	{
		/* move to args as list */
		var args=new LinkedList<string>();
		for(int i=1;i<sysargs.length;i++) {
			args.add(sysargs[i]);
		}
		/* and call the "normal" factory */
		return factory(args);
	}

	/**
	 * the factory method for rrd_commands
	 * @param args list of arguments passed on the command line
	 * @return returns an rrd.command object  that corresponds to the
	 *         arguments given.
	 */
	public static rrd.command? factory(LinkedList<string> args)
	{
		return  (rrd.command) classFactory(
			"rrdcommand",
			null,
			"args", args
			);
	}
}
