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
public class rrd.error : Object {
	~rrderror()
	{
		stderr.printf("Destroy - %s\n",
			getString());
	}

	/**
	 * private thread-local member variable for keeping
	 * error messages
	 */
	private static Private _rrd_error;

	/**
	 * the destructor - not sure if this is "correct" code
	 */
	private static void _rrd_error_DestroyNotify(void* data)
	{
		if (data == null) {
			return;
		}
		rrd.error* err = (rrd.error*) data;
		delete err;
	}

	/**
	 * get the current error
	 *
	 * @return returns current error or null
	 */
	public static unowned rrd.error? getError()
	{
		if (_rrd_error == null)
			return null;
		return (rrd.error*)_rrd_error.get();
	}

	/**
	 * get the current error string
	 *
	 * @return returns current error string or null
	 */
	public static string getErrorString()
	{
		unowned rrd.error err=rrd.error.getError();
		return (err == null) ? null : err.getString();
	}

	/**
	 * set the current tread error string
	 * @param error string
	 */
	public static void setErrorString(string errmsg)
	{
		rrd.error* err = new rrd.error.string(errmsg);
		rrd.error.setError(err);
	}

	/**
	 * set the current error
	 * @param error the error object to set
	*/
	public static void setError(rrd.error* error)
	{
		/* set the string now - there is something wrong somewhere!
		 * since it worked with vala 0.10
		 */
		if (_rrd_error == null) {
			_rrd_error = new Private(
				_rrd_error_DestroyNotify
				);
			_rrd_error.set(null);
		}
		/* set or increment */
		if(_rrd_error.get() == null) {
			_rrd_error.set(error);
		} else {
			_rrd_error.replace(error);
		}
	}

	/**
	 * set the current tread error string
	 * @param error string
	 */
	public static void setErrorStringIfNull(string errmsg)
	{
		if ( (_rrd_error==null) || (_rrd_error.get() == null) ){
			setErrorString(errmsg);
		}
	}

	/**
	 * set the current error if there is no error set already
	 * @param error the error object to set
	*/
	public static void setErrorIfNull(rrd.error* error)
	{
		if(_rrd_error.get() == null) {
			setError(error);
		}
	}

	/**
	 * clear the rrd error variable
	 */
	public static void clearError()
	{ setError(null); }


	private string _error;
	/**
	 * constructor of rrd.error
	 *
	 * @param err the error string to set
	 */
	public rrd.error.string(string err)
	{ _error = err; }

	/**
	 * get the error string
	 * @return the error string of this object
	 */
	public string getString()
	{ return _error ; }

}
