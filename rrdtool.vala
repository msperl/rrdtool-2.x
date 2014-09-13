using GLib;
using Gee;

class rrdtool {

	public static int main(string[] sysargs)
	{

		/* now create the command we shall use */
		rrd_command cmd = rrd_command.factorySysArgs(sysargs);

		/* now execute it */
		if (cmd != null) {
			cmd.execute();
		} else {

		}

		return 0;
	}
}
