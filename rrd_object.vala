using GLib;
using Gee;

public class rrd.object : GLib.Object {

	public static rrd.object? classFactory(
		string class_name, string? subclassof,
		string? key=null, void* value=null)
	{
		/* so now try to get its class type */
		Type class_type = getTypeOfClassWithParent(
			class_name,subclassof);
		/* use the generic factory */
		return classFactoryByType(class_type,key,value);
	}

	public static rrd.object? classFactoryByType(
		Type class_type,
		string? key=null, void* value=null,
		string? key2=null, void* value2=null
		)
	{
		assert(class_type != Type.INVALID);
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
			stderr.printf("ERROR: error instantiating %s\n",
				class_type.name());
			return null;
		}

		return obj;

	}

	public static Type getTypeOfClassWithParent(
		string class_name, string? subclassof)
	{
		/* get the type from the name */
		Type class_type = Type.from_name(class_name);

		/* check that it is an object */
		if (!class_type.is_object()) {
			stderr.printf("ERROR: Could not find class_name %s\n",
				class_name);
			return Type.INVALID;
		}

		if (subclassof == null) {
			return class_type;
		}

		/* and now check ancestors */
		for ( Type p = class_type.parent ();
		      p != 0 ; p = p.parent () ) {
			if ( strcmp(p.name(),subclassof) == 0 ) {
				return class_type;
			}
		}
		return Type.INVALID;
	}


}
