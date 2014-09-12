using GLib;
using Gee;

class rrd_command_create : rrd_command {

  public override void init(rrd_command base_args,ArrayList<string> args) {
    stdout.printf("rrd_command_create.init()\n");
    /* and the remaining args */
    foreach(string x in args) { stdout.printf("rrd_command_create.args:"+x+"\n"); }
    foreach (var entry in base_args.parsed_args.entries) {
      stdout.printf ("rrd_command_create.parsed: %s => %s\n", entry.key, entry.value);
    }
  }

  public override bool execute() {
    stdout.printf("rrd_command_create.execute()\n");
    return true;
  }

}
