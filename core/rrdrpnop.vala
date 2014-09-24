/* rrdrpnop.vala
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
 * the rpn operator class from with all rpn oerators are derived
 */
public abstract class rrd.rpnop : rrd.value
{
	/**
	 * parse the string to string
	 * nothing to get done really - we pares only on demand!
	 */
	protected override void parse_String()
	{ ; }

	/**
	 * overriden to_string method
	 * @returns the class name/operator name
	 */
	public override string? to_string()
	{ return get_type().name().substring(10); }

	/**
	 * the main computational method
	 * for calculating final values to return
	 * @param cmd   the command to which this belongs (if there
	 *              is the need for a context to lookup other values)
	 * @param stack the rpn_stack to work with - if null, then this is
	 *              not part of a rpn calculation
	 * @returns rrd_value with the value given - may be this
	 */
	public override rrd.value? getValue(
		rrd.command cmd,
		rrd.rpn_stack? stack = null)
	{
		rrd.error.setErrorString(
			"rrd.rpnop.getvalue not overridden!"
			);
		return null;
	}

	/**
	 * a map of operator aliases
	 */
	protected static Gee.TreeMap<string,string> aliases;

	/**
	 * fill in the aliases
	 */
	protected static void fillAliases() {
		/* note: that ideally this would happen on loading,
		 * but unfortunately this is not the case
		 */
		/* and register the types */
		registerAlias("add","+");
		registerAlias("sub","-");
		registerAlias("mul","*");
		registerAlias("div","/");
		registerAlias("mod","%");
	}

	/**
	 * register a operator translation
	 * @param real_name  the real name of the operator
	 * @param alias_name the alias name of the operator
	 */
	protected static void registerAlias(
		string real_name, string alias_name)
	{
		/* create aliases if not set */
		if (aliases == null) {
			aliases = new Gee.TreeMap<string,string>();
		}
		/* and set it */
		aliases.set(alias_name, real_name);
	}

	/**
	 * the factory of rpn values
	 * it does also some "translations"
	 * @param opname the operator name to look up
	 * @return an operator instance or null
	 */
	public new static rrd.rpnop? factory(
		string opname_a)
	{
		/* create aliases if needed */
		if (aliases == null) {
			fillAliases();
		}
		/* try to find some translation classes */
		string opname=opname_a;
		if ( aliases.has_key(opname) ) {
			var opname_new = aliases.get(opname);
			opname = opname_new;
		}

		/* now call the factory */
		return (rrd.rpnop) rrd.object.classFactory(
			"rrdrpnop_"+opname.down(),
			"rrdrpnop",
			"String", "");
	}
}
