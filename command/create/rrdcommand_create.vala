/* rrdcommand_create.vala
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
 * the command create
 */
public class rrd.command_create : rrd.command {
	/**
	 * the defined options
	 */
	protected const rrd.argument_entry[] COMMAND_ARGUMENT_ENTRIES = {
		{ "start", 's', "rrdvalue_timestamp", "-1day", false,
		  "start time", "<timestamp>"
		},
		{ "step", 'S', "rrdvalue_rpn", "300", false,
		  "step time", "<seconds>"
		}
	};

	/**
	 * return the defined option fields
	 * @return array of rrd.argument_entry[]
	 */
	protected override rrd.argument_entry[] getCommandOptions()
	{ return COMMAND_ARGUMENT_ENTRIES; }

	/**
	 * the execution method
	 * @return false on errors
	 */
	public override bool execute() {
		stderr.printf("rrdcommand_create.execute()\n");
		return true;
	}

}
