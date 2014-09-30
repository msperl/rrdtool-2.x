/* rrdobject.vala
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
 * the basic class from which all rrd objects are derived
 * it mainly contains a object factory framework
 */

public class rrd.object : GLib.Object {

	/**
	 * static factory method that instanciates by name
	 *
	 * returns a new instance of the requested class name
	 * checking that the class is a subclass of a certain name
	 *
	 * @param class_name the requested classname to instantiate
	 * @param subclassof a check to see if the requested class
	 *                    is a subclass of this class
	 *                    null if no class check is required
	 * @param key        name of key for glibObject constructor
	 *                    parameters
	 * @param value      value for glibObject constructor
	 *                    parameter
	 * @param key2       second  name of key for glibObject constructor
	 *                    parameters
	 * @param value2     second value for glibObject constructor
	 *                    parameter
	 *
	 * @return the instanciated object of null in case of
	 *         a missmatch between class_name not being a subclass of
	 *         subclassof
	 */
	public static rrd.object? classFactory(
		string class_name, string? subclassof,
		string? key=null, void* value=null,
		string? key2=null, void* value2=null
		)
	{
		/* so now try to get its class type */
		Type class_type = getTypeOfClassWithParent(
			class_name,
			subclassof);
		/* use the generic factory */
		return classFactoryByType(
			class_type,
			key, value,
			key2, value2
			);
	}

	/**
	 * static factory method that instanciates by type
	 *
	 * returns a new instance of the requested class name
	 * checking that the class is a subclass of a certain name
	 *
	 * @param Type       the requested classtypr
	 * @param key        name of key for glibObject constructor
	 *                    parameters
	 * @param value      value for glibObject constructor
	 *                    parameter
	 * @param key2       second  name of key for glibObject constructor
	 *                    parameters
	 * @param value2     second value for glibObject constructor
	 *                    parameter
	 *
	 * @return the instanciated object of null in case of
	 *         an invalid type
	 */
	public static rrd.object? classFactoryByType(
		Type class_type,
		string? key=null, void* value=null,
		string? key2=null, void* value2=null
		)
	{
		if (class_type == Type.INVALID) {
			rrd.error.setErrorStringIfNull("invalid type");
			return null;
		}
		/* now create the class and initialize it
		 * there may be an easier way, but probably
		 * not with vala for RH6
		 */
		rrd.object obj;
		if (key2 != null) {
			obj = (rrd.object) Object.new(
				class_type,
				key, value,
				key2, value2);
		} else if (key != null) {
			obj = (rrd.object) Object.new(
				class_type,
				key,value);
		} else {
			obj = (rrd.object) Object.new(
				class_type);
		}
		if ( obj == null ) {
			rrd.error.setErrorStringIfNull(
				"ERROR: error instantiating %s"
				.printf(class_type.name())
				);
			return null;
		}
		/* if we got an error, then return null */
		if (rrd.error.getError()!= null) {
			return null;
		}

		/* return a potentially delegated sub_class */
		var ret = obj.delegate();

		/* if an error is set in a constructor or similar
		 * then return null
		 * note that the GLib constructors we use can not throw
		 * exceptions, so we have to go this route...
		 */
		if ( rrd.error.getError() != null ) {
			ret = null;
		}
		return ret;
	}

	/**
	 * create a subclass of this object bases on the already parsed
	 * arguments
	 *
	 * Note that it still requires  the code to get passed the
	 * "extra arguments" that are needed
	 *Tthis code needs to parse the optional arguments
	 *
	 * @return the current intance or an instance to use instead
	 */
	public virtual rrd.object? delegate()
	{ return this; }

	/**
	 * check if the given class exists and is a subclass of subclassof
	 * @param class_name the classname which should get checked
	 * @param subclassof the class from which class_name should be
	 *                   derived
	 * @return the type of the class or Type.INVALID
	 */
	public static Type getTypeOfClassWithParent(
		string class_name, string? subclassof)
	{
		/* get the type from the name */
		Type class_type = Type.from_name(class_name);

		/* check that it is an object */
		if (class_type == Type.INVALID) {
			rrd.error.setErrorStringIfNull(
				"invalid type %s requested"
				.printf(class_name)
				);
			return class_type;
		}
		if (!class_type.is_object()) {
			rrd.error.setErrorStringIfNull(
				"type %s requested can not get instanciated as an object"
				.printf(class_name)
				);
			return Type.INVALID;
		}

		if (subclassof == null) {
			return class_type;
		}

		/* and now check ancestors */
		if (isSubClassOf(class_type,subclassof)) {
			return class_type;
		}

		/*  and error handling if it is not a subtype */
		rrd.error.setErrorStringIfNull(
			"type %s is not a subtype of %s"
			.printf(class_name,subclassof)
			);
		return Type.INVALID;
	}

	/**
	 * check if class _type is of parent class type
	 * @param class_type the classtype to check
	 * @param subclassof the class it must be a child of
	 * @return true on match
	 */
	public static bool isSubClassOf(
		Type class_type,
		string subclassof)
	{
		for ( Type p = class_type.parent ();
		      p != 0 ; p = p.parent () ) {
			if ( strcmp(p.name(),subclassof) == 0 ) {
				return true;
			}
		}
		return false;
	}
	/**
	 * get all childClasses of a certain type
	 */
	public static Gee.LinkedList<Type> get_children(Type t) {
		var ret = new Gee.LinkedList<Type>();
		var children = t.children();
		foreach (var c in children) {
			ret.add(c);
			get_children(c).drain(ret);
		}
		return ret;
	}
}
