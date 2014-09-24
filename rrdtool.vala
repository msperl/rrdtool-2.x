/* rrdtool.vala
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

/**
 * command line interface to rrdtool
 */

public class rrdtool {

	/**
	 * the main implementation
	 */
	public static int main(string[] sysargs)
	{
		int ret = 0;

		/* now create the command we shall use */
		rrd.command cmd = rrd.command.factorySysArgs(sysargs);

		/* now execute it if it is not null */
		if (cmd != null) {
			/* check for help */
			rrd.value_bool help =
				(rrd.value_bool) cmd.getOption("help");
			if (help.to_bool()) {
				stderr.printf("%s",cmd.getHelp());
				ret = 127;
			} else  {
				/* and set return value */
				ret = cmd.execute() ? 0 : 1;
			}
		} else {
			ret = 2;
		}

		/* check for errors and print them */
		var err = rrd.error.getErrorString();
		if (err != null) {
			stderr.printf("%s: %s\n",
				sysargs[0],
				err
				);
		}
		/* return with error code calculated above */
		return ret;
	}
}
