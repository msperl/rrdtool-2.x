/* rrderror.vala
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
 * the rrd error class
 * probably this should be a subclass of GLib.Error
 * unfortunately no experience yet with that...
 */
public class rrd.error {
	private string error;
	/**
	 * constructor of rrd.error
	 *
	 * @param err the error string to set
	 */
	public rrd.error.string(string err)
	{ error = err; }

	/**
	 * get the error string
	 * @return the error string of this object
	 */
	public string getString()
	{ return error ; }
}
