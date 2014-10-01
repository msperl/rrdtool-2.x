/* rrdcommand_graph_def_daemon.vala
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

public class rrd.command_graph_def_daemon : rrd.command_graph_def {

	protected override rrd.value_timestring?
		fillTimeString(rrd.value_timestring result)
	{
		/* get a Daemon connect */
		var daemon = rrd.daemon_client.get(getOption("daemon"));
		if (daemon == null)
			return null;

		/* the start/step/end values */
		rrd.value_timestamp start =
			(rrd.value_timestamp) getOptionValue(
				"start", command);
		rrd.value_number step =
			(rrd.value_number) getOptionValue(
				"step", command);
		rrd.value_timestamp end =
			(rrd.value_timestamp) getOptionValue(
				"end", command);

		/* the information that is specific to rrdfile */
		rrd.value_string rrdfile =
			(rrd.value_string) getOptionValue(
				"rrdile", command);
		rrd.value_string rrdfield =
			(rrd.value_string) getOptionValue(
				"rrdfield", command);
		rrd.value_string cf =
			(rrd.value_string) getOptionValue(
				"cf", command);

		/* execute the command */
		var ts=daemon.fetch(rrdfile.to_string(),
				rrdfield.to_string(),
				cf.to_string(),
				start.to_double(),
				end.to_double());
		if (ts == null)
			return null;

		/* now copy the data over */
		int i=0;
		double time;
		for(
			time=result.getStart(),i=0;
			time<result.getEnd();
			time+=result.getStep(),i++)
		{
			result.setData(
				i,
				ts.getDataTS(i)
				);
		}

		return result;
	}
}
