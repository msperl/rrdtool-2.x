using GLib;
using Gee;

class rrd_object : GLib.Object {
	public static rrd_object? classFactory(
		string class_name, string subclassof,...)
	{
		/* so now try to get its class type */
		Type class_type = getTypeOfClassWithParent(
			class_name,subclassof);

		/* and check that it is a child of subclassof
		 * (not necessarily a direct child) */
		if (class_type == Type.INVALID) {
			stderr.printf("ERROR: the found implementation of"
				+ " %s is not derived from %s\n",
				class_name,subclassof);
			return null;
		}

		/* now create the class and initialize it */
		rrd_object obj =
			(rrd_object) Object.new(class_type);
		if ( obj == null ) {
			stderr.printf("ERROR: error instantiating %s\n",
				class_name);
			return null;
		}

		return obj;

	}

	static Type getTypeOfClassWithParent(
		string class_name, string subclassof)
	{
		/* get the type from the name */
		Type class_type = Type.from_name(class_name);

		/* check that it is an object */
		if (!class_type.is_object()) {
			stderr.printf("ERROR: Could not find class_name %s\n",
				class_name);
			return Type.INVALID;
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
