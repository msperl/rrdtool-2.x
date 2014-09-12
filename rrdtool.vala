using GLib;
using Gee;

class rrdtool {

  public static int main(string[] sysargs)
  {

    /* move to arg */
    var args=new ArrayList<string>();
    foreach(var arg in sysargs) { args.add(arg); }

    /* now create the command we shall use */
    rrd_command cmd = rrd_command.factory(args);

    /* now execute it */
    if (cmd != null) {
      cmd.execute();
    }

    /* and work with it */
    //foreach(var arg in args) { stdout.printf("main: arg: %s\n",arg); }

    return 0;
  }
}