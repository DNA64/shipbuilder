import 'dart:async';
import 'dart:math';

import 'block.dart';

import 'package:xml/xml.dart';
import 'globals.dart';

//xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"


//only what is shown on the screen (boards etc.)
exportObject(posX,posY,posZ, gridsize, boards){
	var rng = new Random();
	
	var builder = new XmlBuilder();
//	builder.processing('xml',	'version="1.0"');
	
	builder.element('MyObjectBuilder_EntityBase', nest :(){
		builder.attribute("xsi:type", "MyObjectBuilder_CubeGrid");
		builder.element("EntityId", nest:(){
			//random entity id `cause i have no idea wtf they do or how they are made
			builder.text((2403842243863731929+rng.nextInt(999)).toString());
		});
		builder.element("PersistentFlags", nest:(){
			builder.text("CastShadows InScene");
		});
		builder.element("PositionAndOrientation", nest:(){
			builder.element("Position", nest:(){
				builder.attribute("x", posX);
				builder.attribute("y", posY);
				builder.attribute("z", posZ);
			});
			builder.element("Forward", nest:(){
				//random values
				builder.attribute("x", "-0");
				builder.attribute("y", "-0");
				builder.attribute("z", "-1");
			});
			builder.element("Up", nest:(){
				//random values
				builder.attribute("x", "0");
				builder.attribute("y", "1");
				builder.attribute("z", "0");
			});
		});
		builder.element("GridSizeEnum", nest:(){
			builder.text(gridsize);
		});
		builder.element("CubeBlocks", nest:(){
			//for loop making all the blocks here
			for(int j = 0; j<boards.length; j++){
				List<Block> dList = boards.elementAt(j).getDrawList();
				for(int i =0; i<dList.length; i++){
					builder.element("MyObjectBuilder_CubeBlock", nest:(){
						builder.attribute("xsi:type", "MyObjectBuilder_CubeBlock");
						builder.element("SubtypeName", nest:(){
							builder.text(dList.elementAt(i).getBlockType());
						});
						builder.element("Min", nest:(){
							builder.attribute("x", dList.elementAt(i).getX()~/sqwidth);
							builder.attribute("y", dList.elementAt(i).getY()~/sqheight);
							builder.attribute("z", j.toString());
						});
						builder.element("BlockOrientation", nest:(){
							builder.attribute("Forward", "Forward");
							builder.attribute("Up", "Up");
						});
						builder.element("ColorMaskHSV", nest:(){
							builder.attribute("x", dList.elementAt(i).h);
							builder.attribute("y", dList.elementAt(i).s);
							builder.attribute("z", dList.elementAt(i).v);
						});
						builder.element("ShareMode",nest:(){
							builder.text("None");
						});
					});
				}
			}
		});
		builder.element("IsStatic", nest:(){
			builder.text("false"); // sets whether the thing is a station?
		});
		builder.element("Skeleton");
		builder.element("LinearVelocity", nest:(){
			builder.attribute("x", "0");
			builder.attribute("y", "0");
			builder.attribute("z", "0");
		});
		builder.element("AngularVelocity", nest:(){
			builder.attribute("x", "0");
			builder.attribute("y", "0");
			builder.attribute("z", "0");
		});
		builder.element("XMirrorxPlane", nest:(){
			builder.attribute("xsi:nil", "true"); //, namespace:"xsi"
		});
		builder.element("YMirrorxPlane", nest:(){
			builder.attribute("xsi:nil", "true"); //, namespace:"xsi"
		});
		builder.element("ZMirrorxPlane", nest:(){
			builder.attribute("xsi:nil", "true"); //, namespace:"xsi"
		});
		//block groups (eww don't look forward to this)
		builder.element("BlockGroups");
		
		builder.element("Handbrake", nest:(){
			builder.text("false");
		});
		builder.element("DisplayName", nest:(){
			builder.text("Small Ship "+rng.nextInt(9999).toString());
		});
	});
	
	XmlNode n = builder.build();
	return n.toXmlString(pretty:true);
	
}

//a completed SE save file
exportFile(){
	
}

