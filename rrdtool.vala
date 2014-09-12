using GLib;
using Gee;

class rrdtool {

  public static int main(string[] sysargs)
  {
    /* need to load these explicitly as of now - we need to get those classes registered */
    new rrd_command_graph();

    /* move to arg */
    var args=new ArrayList<string>();
    foreach(var arg in sysargs) { args.add(arg); }

    /* now create the command we shall use */
    rrd_command cmd = rrd_command.factory(args);

    /* now execute it */
    cmd.execute();

    /* and work with it */
    //foreach(var arg in args) { stdout.printf("main: arg: %s\n",arg); }

    return 0;
  }
}
