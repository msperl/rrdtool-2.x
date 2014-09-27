/* rrdcommand_graph_tsgraph.vala
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
 * the tsgraph implementation
 */
public class rrd.command_graph_tsgraph : rrd.argument {
	/**
	 * the defined fields
	 */
	protected const rrd.argument_entry[] GRAPH_ARGUMENT_ENTRIES = {
		{ "id",       0, "rrdvalue_string", null,
		  false, "the frame id to use"
		},
		{ "x",        0, "rrdvalue_rpn", "0",
		  false, "the starting x coordinate of the graph"
		},
		{ "y",        0, "rrdvalue_rpn", "0",
		  false, "the starting y coordinate of the graph"
		},
		{ "width",    0, "rrdvalue_rpn",
		  "!xend,!x,-",
		  false, "the width of this graph"
		},
		{ "height",   0, "rrdvalue_rpn",
		  "!yend,!y,-",
		  false, "the height of this graph"
		},
		{ "xend",   0, "rrdvalue_rpn",
		  "!ylabelframe.xend,!yaxisframe.xend,!graphframe.xend,3,MAX",
		  false, "the height of this graph"
		},
		{ "yend",   0, "rrdvalue_rpn",
		  "!titleframe.yend,!xlabelframe.yend,!xaxisframe.yend,!graphframe.yend,4,MAX",
		  false, "the height of this graph"
		},
		{ "title",   0, "rrdvalue_string", "title",
		  false, "the title to print"
		},
		{ "xlabel",   0, "rrdvalue_rpn", null,
		  false, "the x label to print"
		},
		{ "xonbottom",     0, "rrdvalue_bool", "true",
		  false, "the position of the x-axis - top or bottom"
		},
		{ "ylabel",   0, "rrdvalue_rpn", null,
		  false, "the y label to print"
		},
		{ "yonleft",     0, "rrdvalue_bool", "1",
		  false, "the position of the y-axis - left or right"
		}
		/* the subframes - should not get set */
		,{ "titleframe",    0, "rrdcommand_graph_frame",
		  "x=!x:y=!y:width=!graphframe.xend:height=!title?\"\",gettextheight",
		   false,"the implicit titleframe"
		}
		,{ "ylabelframe",    0, "rrdcommand_graph_frame",
		   /* we use textheight, as it is rotated */
		   "x=!x,!yaxisframe.xend,!yonleft,rif:y=!titleframe.yend:width=!ylabel?\"\",gettextheight:height=height",
		  false,"the implicit ylabel"
		}
		,{ "yaxisframe",    0, "rrdcommand_graph_frame",
		  "x=!ylabelframe.xend,!graphframe.xend,!yonleft,rif:y=!ylabelframe.y:width=\"CalcAxisLabelText\",gettextwidth:height=!ylabelframe.height",
		  false,"the implicit yaxis"
		}
		,{ "graphframe",    0, "rrdcommand_graph_frame",
		  "x=!yaxisframe.xend,!x,!yonleft,rif:y=!yaxisframe.y:width=width:height=height",
		  false,"the implicit graph frame"
		}
		,{ "xaxisframe",    0, "rrdcommand_graph_frame",
		   "x=!graphframe.x:y=!graphframe.yend:width=!graphframe.width:height=\"axistextsize\",gettextheight",
		  false,"the implicit xaxis frame"
		}
		,{ "xlabelframe",    0, "rrdcommand_graph_frame",
		   "x=!xaxisframe.x:y=!xaxisframe.yend:width=!xaxisframe.width:height=xlabel?\"\",gettextheight",
		  false,"the implicit xaxis label frame"
		}
	};

	/**
	 * return the defined option fields
	 * @return array of rrd.argument_entry[]
	 */
	protected override rrd.argument_entry[] getArgumentEntries()
	{ return GRAPH_ARGUMENT_ENTRIES; }
}

public class rrd.command_graph_rpnop_gettextheight : rrd.rpnophelper_obj {
	/**
	 * abstract method that is called to handle
	 * the object from stack
	 * @param val   the value object
	 * @param cmd   the command context
	 * @param stack the command stack
	 * @return rrd_value result
	 */
	public override rrd.value? getValue1(
		rrd.value val,
		rrd.command cmd,
		rrd.rpn_stack? stack)
	{
		string str = val.to_string();
		if (str.length>0) {
			return new rrd.value_number.double(8);
		} else {
			return new rrd.value_number.double(0);
		}
	}
}

public class rrd.command_graph_rpnop_gettextwidth : rrd.rpnophelper_obj {
	/**
	 * abstract method that is called to handle
	 * the object from stack
	 * @param val   the value object
	 * @param cmd   the command context
	 * @param stack the command stack
	 * @return rrd_value result
	 */
	public override rrd.value? getValue1(
		rrd.value val,
		rrd.command cmd,
		rrd.rpn_stack? stack)
	{
		string str = val.to_string();
		if (str.length>0) {
			return new rrd.value_number.double(8*str.length);
		} else {
			return new rrd.value_number.double(0);
		}
	}
}
