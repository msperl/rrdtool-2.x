using GLib;
using Gee;

class rrd_command : GLib.Object {

  /* the common arguments */
  private const OptionEntry[] common_options = {
    /* format: long option, short option char, flags, argstype, argdata,description,arg_description) */
    { "debug",'d',OptionFlags.NO_ARG,OptionArg.CALLBACK,(void *)optionCallback,"debug",""},
    { "verbose",'v',OptionFlags.NO_ARG,OptionArg.CALLBACK,(void *)optionIncreaseCallback,"verbose",""},
    { null }
  };

  /* common method to get the "complete" name */
  private string? getLongNameFromArg(string name) {
    /* this is a bit more complicated than necessary, but that is the way it is... */
    if(name.substring(0,2)=="--") { return name.substring(2,-1); }
    /* else we need to translate shorts to long names somehow... */
    string short_name=name.substring(1,1);
    /* TODO: transformation */
    foreach(var option in common_options) {
      if (option.short_name.to_string()==short_name) {
	return option.long_name;
      }
    }
    return null;
  }

  /* the callback to set the values */
  protected static bool optionCallback(string name, string? val,rrd_command data,ref OptionError error) throws OptionError
  {
    /* translate name */
    var n=data.getLongNameFromArg(name);
    /* set in array */
    data.parsed_args.set(n,val);
    /* return OK */
    return true;
  }

  /* same as above, but increase by 1 every time we find it */
  protected static bool optionIncreaseCallback(string name, string? val,rrd_command data,ref OptionError error) throws OptionError
  {
    /* translate name */
    var n=data.getLongNameFromArg(name);
    /* now get the old value */
    int v=0;
    if (data.parsed_args.has_key(n)) {
      v=data.parsed_args.get(n).to_int();
    }
    /* and set the incremented version */
    data.parsed_args.set(n,"%d".printf(v+1));
    /* and return OK */
    return true;
  }

  /* the parsed arguments so far */
  protected Map<string,string> parsed_args;

  private rrd_command(ArrayList<string> args) {

    /* get the args as an array */
    string[] args_array=new string[args.size];
    int i=0;
    foreach(var arg in args) { args_array[i]=arg; i++; }
    
    /* allocate the map of parsed args */
    this.parsed_args=new TreeMap<string,string>();

    /* try to parse the args for now */
    try {
      /* create main context */
      var opt_context = new OptionContext ("- rrdtool common");
      opt_context.set_help_enabled (true);
      opt_context.set_ignore_unknown_options(true);
      /* create the common context */
      OptionGroup opt_group_common= new OptionGroup("common","Common arguments","Common Arguments",this);
      opt_group_common.add_entries(common_options);
      /* add it to the context */
      opt_context.set_main_group((owned)opt_group_common);
      /* and try to parse everything so far */
      opt_context.parse(ref args_array);
    } catch (OptionError e) {
      stdout.printf ("error: %s\n", e.message);
    }

    /* and convert args_array back to args for the caller to have the info */
    args.clear();foreach(var arg in args_array) { args.add(arg); }
  }

  public virtual void init(rrd_command basecmd, ArrayList<string> args) {
    /* this should raise an exception!!! */
    stdout.printf("SHOULD NOT GET HERE\n");
  }

  public virtual bool execute() {
    stdout.printf("SHOULD NOT GET HERE\n");
    return false;
  }

  public static rrd_command? factory(ArrayList<string> args) {
    /* parsing of common options*/
    var self=new rrd_command(args);

    /* check that we got at least one argument */
    if (args.size <2) {
      stdout.printf("Unexpected length - need at least 1 arg as command!\n");
      return null;
    }

    /* now get the command itself - removing it from the command */
    string command=args.remove_at(1);
    string class_name="rrd_command_"+command;

    /* so now try to get its class info */
    Type class_type=Type.from_name(class_name);

stderr.printf("XXX %s\n",class_type.name());

    /* check that it is an object */
    if (!class_type.is_object()) {
      stdout.printf("ERROR: Could not find command %s\n",command);
      return null;
    }
    /* and check that it is a child of rrd_command */
    bool is_command=false;
    for ( Type p = class_type.parent (); p != 0 ; p = p.parent () ) {
      if ( p.name()=="rrd_command" ) { is_command=true; }
    }
    if (! is_command) {
      stdout.printf("ERROR: the found implementation of %s is not derived from rrd_command\n",class_name);
      return null;
    }
    /* now create the class and initialize it */
    rrd_command cmdclass=(rrd_command) Object.new(class_type);
    if ( cmdclass == null ) {
      stdout.printf("ERROR: error instantiating %s\n",class_name);
      return null;
    }
    /* initialize with the common args already found and the parsed ones */
    cmdclass.init(self,args);

    return self;
  }

}
