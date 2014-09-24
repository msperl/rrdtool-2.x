/* rrdvalue_timestamp.vala
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
 * timestamp value class derived from value_number
 */
public class rrd.value_timestamp : rrd.value_number {
	/**
	 * overriden String parser method
	 * takes the String and converts it to a number(double)
	 * using timestamps strings
	 */
	protected override void parse_String()
	{
		time_t now = time_t();
		if (strcmp(String,"now")==0) {
			value = now;
		} else if (strcmp(String,"-1day")==0) {
			value = now - 86400;
		} else {
			rrd.error.setErrorString(
				"Unsupported time definition: %s"
				.printf(String));
		}
	}
}
