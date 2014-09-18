using GLib;
using Gee;

public class rrdtool {

	public static int main(string[] sysargs)
	{

		/* now create the command we shall use */
		rrd.command cmd = rrd.command.factorySysArgs(sysargs);

		/* now execute it */
		if (cmd != null) {
			cmd.execute();
		} else {

		}

		return 0;
	}
}
