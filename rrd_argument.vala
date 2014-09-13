using GLib;
using Gee;

class rrd_argument : GLib.Object {
	/* our own split_colon method that also takes care of escaped colons */
	public static ArrayList<string>? split_colon(string arg) {
		/* move it to an ArrayList on split
		 * but also join the ones that have been escaped
		 */
		var arglist = new ArrayList<string>();
		string merged = "";
		foreach(var str in arg.split(":")) {
			/* find trailing escape,
			 * but only ones that are not escaped itself
			 */
			if ( (str.length == 1)
				/* case one of trailing escape */
				&& (str.substring(-1, 1) == "\\") ) {
				merged+=":"+str.substring(0, str.length-1);
			} else if ( (str.length > 1)
				/* case two of trailing escape
				 * checking that the escape is not
				 * escaped itself...
				 */
				&& (str.substring(-1, 1) == "\\")
				&& (str.substring(-2, 1) != "\\\\")
				) {
				merged += ":"+str.substring(0,str.length-1);
			} else {
				/* otherwise add to list and empty merged */
				arglist.add(merged + str);
				merged = "";
			}
		}
		/* if we got a "trailing" \, then there is something wrong */
		if (merged != "") {
			stdout.printf("Error: unterminated escape \\ string\n");
			return null;
		}
		/* otherwise return arglist */
		return arglist;
	}

	/* the factory that transforms a positional argument into an object */
	public static rrd_argument? factory(
		rrd_command command, string cmdstr) {
		/* split into a list */
		var split = split_colon(cmdstr);
		if (split == null) {
			return null;
		}

		/* now start processing those entries to get the type of arg */
		string cmd_find = null;
		string cmd = null;
		foreach(var arg in split) {
			/* try to split in key/values */
			var keyvalue=arg.split("=",2);
			/* now  check if we got key+value */
			if (keyvalue.length == 1) {
				/* postitional argument */
				if ( cmd == null ) {
					cmd_find = cmd = arg;
				}
			} else {
				/* got key/value, so check if key is "cmd" */
				if (keyvalue[0] == "cmd") {
					cmd_find = arg;
					cmd = keyvalue[1];
				}
			}
		}
		/* now that we got everything remove the entries */
		if (cmd != null) {
			split.remove(cmd_find);
		}
		/* and now create the Class object */
		stderr.printf("ARG: %s\n",cmd);

		return null;
	}
}
