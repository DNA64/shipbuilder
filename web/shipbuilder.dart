import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'block.dart';
import 'board.dart';

int width = 800;
int height = 800;

CanvasRenderingContext2D left_context;
CanvasRenderingContext2D middle_context;
CanvasRenderingContext2D right_context;

List<Board> boards = new List<Board>();

int boardnumber = 0;
var symmetry = [false,false,false];

String blocksize = "Small";
String brushblocktype = "ArmorBlock";
String gridsize = "Small";

String brushtype = "constant";

Element dispboardnum = document.getElementById("boardnumber");

Element progressbar = document.getElementById("exporting");

bool brushing = false;
bool exporting = false;

String xml = "";

void main() {
	CanvasElement left_canvas = document.getElementById("left");
	left_canvas.width = width~/2;
	left_canvas.height = height~/2;
	CanvasElement middle_canvas = document.getElementById("middle");
	middle_canvas.width = width;
	middle_canvas.height = height;
	CanvasElement right_canvas = document.getElementById("right");
	right_canvas.width = width~/2;
	right_canvas.height = height~/2;

	
	left_context = left_canvas.getContext("2d");
	middle_context = middle_canvas.getContext("2d");
	right_context = right_canvas.getContext("2d");
	init_board();
	

	document.getElementById("previous").onClick.listen((MouseEvent e){	
		previous_board();
	});
	export_board_button();
	document.getElementById("next").onClick.listen((MouseEvent e){
		next_board();
	});	
	
	middle_canvas.onClick.listen((MouseEvent e){
		if(brushtype=="constant"){
			if(brushing){
				brushing = false;				
			}else if(!brushing){
				brushing = true;				
			}
		}else if(brushtype=="dot"){
			var x = (e.offset.x);
			var y = (e.offset.y);
			boards.elementAt(boardnumber).setAt(x, y);
		}
		boards.elementAt(boardnumber).draw(1);
	});
	
	middle_canvas.onMouseMove.listen((MouseEvent e){
		if(brushtype=="constant"){
			if(brushing){
				var x = (e.offset.x);
				var y = (e.offset.y);
				boards.elementAt(boardnumber).setAt(x, y);
			}
		}
		boards.elementAt(boardnumber).draw(1);
	});
	
	document.getElementById("clearboards").onClick.listen((MouseEvent e){
		Element confirmButton = mkConfirmButton();
		document.getElementById("clearboardscontainer").nodes.add(confirmButton);
		confirmButton.onClick.listen((MouseEvent e){
	 		boards = new List<Board>();
	 		boardnumber = 0;
		 	init_board();
	 		draw_board();
	 		draw_side_boards();
	 		confirmButton.remove();
		});
		Timer removeButton = new Timer(new Duration(milliseconds:5000), (){
			try{
				confirmButton.remove();
			}catch(e){}
		});	 	
	});
	
	document.getElementById("clearboard").onClick.listen((MouseEvent e){
		Element confirmButton = mkConfirmButton();
		document.getElementById("clearboardcontainer").nodes.add(confirmButton);
		confirmButton.onClick.listen((MouseEvent e){
			boards.remove(boards.elementAt(boardnumber));
			boards.insert(boardnumber, new Board(width~/10, height~/10));
			draw_board();
			confirmButton.remove();
		});
		
		Timer removeButton = new Timer(new Duration(milliseconds:5000), (){
			try{
				confirmButton.remove();
			}catch(e){}
		});
	});
	
//	document.getElementById("import").onChange.listen((Event e){
//		//only for importing atm
//		File f = document.getElementById("import").files[0];
//		print(f.size);
//		print(f.type);
//		if(f.type.toString()=="text/xml"){
//			var reader = new FileReader();
//			reader.onLoadEnd.listen((Event e){
////				print(reader.result);
////				if(reader.result.toString().contains("SHIPBUILDERv0.2")){
//					//start loading the file
//					var lines = reader.result.toString().split("\n");
//					print(lines[0]);					
////				}
//			});
//			reader.readAsText(f.slice(0,f.size));
//		}else{
//			//throw error
//		}
//	});
	

	
	document.getElementById("fillboard").onClick.listen((MouseEvent e){
		Element confirmButton = mkConfirmButton();
		document.getElementById("fillboardcontainer").nodes.add(confirmButton);
		confirmButton.onClick.listen((MouseEvent e){
			boards.elementAt(boardnumber).fill();			
			draw_board();
			confirmButton.remove();
		});
		
		Timer removeButton = new Timer(new Duration(milliseconds:5000), (){
			try{
				confirmButton.remove();
			}catch(e){}
		});
		
	});
	
	document.getElementById("insertboard").onClick.listen((MouseEvent e){
	//shifts forward
		Element confirmButton = mkConfirmButton();
		document.getElementById("insertboardcontainer").nodes.add(confirmButton);
		confirmButton.onClick.listen((MouseEvent e){
			if(boardnumber>0){
				boards.insert(boardnumber, new Board(width~/10,height~/10));
				draw_board();
			}else{
				boards.insert(0, new Board(width~/10,height~/10));
				draw_board();
			}
			draw_side_boards();
			
			confirmButton.remove();
		});
	
		Timer removeButton = new Timer(new Duration(milliseconds:5000), (){
			try{
				confirmButton.remove();
			}catch(e){
	
			}
		});
	});
	
	document.getElementById("shiptype").onChange.listen((Event e){
		String changeTo = document.getElementById("shiptype").value;
		if(changeTo == "small"){
			blocksize = "Small";
			gridsize = "Small";
		}else if(changeTo=="large"){
			blocksize = "Large";
			gridsize = "Large";
		}
	});
	
	document.getElementById("blocktype").onChange.listen((Event e){
		String changeTo = document.getElementById("blocktype").value;
		if(changeTo=="lightarmorblock"){
			brushblocktype="ArmorBlock";
		}else if(changeTo=="lightslopearmorblock"){
			brushblocktype="ArmorSlope";
			brushtype="dot";
			document.getElementById("brushtype").value = "dot";
		}else if(changeTo=="largearmorblock"){
			brushblocktype="HeavyBlockArmorBlock";
		}else if(changeTo=="largearmorslope"){
			brushblocktype="HeavyBlockArmorSlope";
			brushtype="dot";
			document.getElementById("brushtype").value = "dot";
		}
	});
	
	symmetryToggle("leftrightsymmetry",0);
	symmetryToggle("topbottomsymmetry",1);
	symmetryToggle("axissymmetry",2);
	
	document.getElementById("brushtype").onChange.listen((Event e){
		brushtype = document.getElementById("brushtype").value;
	});
	
	document.body.onKeyDown.listen((KeyboardEvent e){
		/*
		 * 37 = <-
		 * 39 = ->
		 * 38 = ^
		 * 40 = v
		 * 
		 * number line starts at 49
		 */
		print(e.keyCode);
		if(e.keyCode == 37){
			//previous board
			previous_board();
		}else if(e.keyCode == 39){
			//next board
			next_board();
		}else if(e.keyCode == 48){
			//number 0 erase
			setCurrentColor("Erase");
		}else if(e.keyCode == 49){
			//number 1
			setCurrentColor("Black");
		}else if(e.keyCode == 50){
			//number 2
			setCurrentColor("Yellow");
		}else if(e.keyCode == 51){
			//number 3
			setCurrentColor("Red");
		}else if(e.keyCode == 52){
			//number 4
			setCurrentColor("Green");
		}else if(e.keyCode == 53){
			setCurrentColor("Blue");
		}else if(e.keyCode== 68){
			//dump debug
			
		}
	});
	

}

symmetryToggle(String id, int location){
	document.getElementById(id).onChange.listen((Event e){
		print(id);
		symmetry[location] = !symmetry[location];
	});
}

mkConfirmButton(){
	Element confirmButton = new Element.html("<input>");
	confirmButton.setAttribute("type", "button");
	confirmButton.setAttribute("value", "Confirm");
	return confirmButton;
}

init_board(){
	boards.add(new Board(width~/10, height~/10));
	draw_board();
}

draw_board(){
	//main board
	boards.elementAt(boardnumber).draw(1);
	
	dispboardnum.innerHtml = "Boardnumber: "+boardnumber.toString();
}

draw_side_boards(){
	//left board
	if(boardnumber>0){
		boards.elementAt(boardnumber-1).draw(0);		
	}else{
		Board.clear(0);
	}
	//right board
	if(boards.length>boardnumber+1){
		boards.elementAt(boardnumber+1).draw(2);		
	}else{
		Board.clear(2);
	}
}



String getFileName(){
	return document.getElementById("filename").value;
}

export_board_button(){
	document.getElementById("export").onClick.listen((MouseEvent e){
		if(!exporting){
			print("Export Button Clicked");
			export_board();
			var numblocks = boards.length*width~/10*height~/10;
			Timer t = new Timer(new Duration(milliseconds:numblocks*2), (){
				print(xml);
				download(xml);
				exporting = false;
				progressbar.setAttribute("value", "0".toString());
			});
			exporting = true;
		}
	});
}

next_board(){
	print("Next Button Clicked");
	boardnumber++;
	init_board();
	draw_side_boards();
	draw_board();
}

previous_board(){
	print("Previous Button Clicked");
	if(boardnumber>0){
		boardnumber--;
		draw_side_boards();
		draw_board();
	}
}

getPosition(String xyz){
	return document.getElementById(xyz+"count").innerHtml;
}

String export_board(){
	xyzString(String x, String y, String z){
		String tmps = "";
		tmps+="<X>"+x+"</X>\n";
		tmps+="<Y>"+y+"</Y>\n";
		tmps+="<Z>"+z+"</Z>\n";
		return tmps;
	}
	
	//have to export to xml
	var numboards = boards.length;
	int progress = 0;
	var numblocks = numboards*width~/10*height~/10;
	progressbar.setAttribute("max", numblocks.toString());
	progressbar.setAttribute("value", progress.toString());
	var rng = new Random();
	
	//returns string to download, can be complete file or snippet
	xml = '<!-- SHIPBUILDERv0.2 -->' 
	'<MyObjectBuilder_EntityBase xsi:type="MyObjectBuilder_CubeGrid">\n'
	'<EntityId>'+(2403842243863731929+rng.nextInt(999)).toString()+'</EntityId>\n' //needs to be randomized?
	'<PersistentFlags>CastShadows InScene</PersistentFlags>\n'
	'<PositionAndOrientation>\n'
	'<Position>\n';
	xml+=xyzString(getPosition('x')+".00000000",getPosition('y')+".00000000",getPosition('z')+".00000000");
	xml+= '</Position>\n<Forward>\n';
	xml+=xyzString("0.20000000","0.30000000","0.40000000");
	xml+='</Forward>\n<Up>\n';
	xml+=xyzString("0.20000000","0.30000000","0.40000000");
	xml+='</Up>\n'
	'</PositionAndOrientation>\n'
	'<GridSizeEnum>'+gridsize+'</GridSizeEnum>\n'
	'<CubeBlocks>\n'	
	;
	int activeblocks = 0;
	for(var i=0; i<boards.length; i++){
		Board board = boards.elementAt(i);
		activeblocks+=board.activeBlocks();			
	}
	print("ActiveBlocks: "+activeblocks.toString());

	for(var i=0; i<boards.length; i++){
		Board board = boards.elementAt(i);
		for(var j=0; j<width~/10; j++){
			for(var k=0; k<height~/10; k++){
				Timer t = new Timer(new Duration(milliseconds:i*j*k+2), (){
				Block square = board.getAt(j,k);
				if(square.isActive()){
					xml += '<MyObjectBuilder_CubeBlock>\n';
					xml += '<SubtypeName>'+square.getType(blocksize)+'</SubtypeName>\n';
					xml += '<EntityId>0</EntityId>\n';
					xml += '<PersistentFlags>None</PersistentFlags>\n';
					xml += '<Min>\n';
					xml += xyzString((square.getX()~/10).toString(), (square.getY()~/10).toString(), i.toString());
					xml += '</Min>\n';
					xml += '<Max>\n';
					xml += xyzString((square.getX()~/10).toString(), (square.getY()~/10).toString(), i.toString());
					xml += '</Max>\n';
					xml += '<Orientation>\n';
					if(square.getBlockType()=="ArmorBlock" || square.getBlockType()=="HeavyBlockArmorBlock"){
						xml += xyzString("0", "0", "0");
						xml += '<W>1</W>\n';
					}else if(square.getBlockType()=="ArmorSlope" || square.getBlockType()=="HeavyBlockArmorSlope"){
						int rot = square.getRotation();
						if(rot == 0){
							//correct
							xml += xyzString("0.5", "-0.5", "0.5");
							xml += '<W>0.5</W>\n';
						}else if(rot==1){
							//correct
							xml += xyzString("0.5", "0.5", "-0.5");
							xml += '<W>0.5</W>\n';
						}else if(rot==2){
							//correct
							xml += xyzString("0.5", "0.5", "0.5");
							xml += '<W>-0.5</W>\n';
						}else if(rot==3){
							//correct
							xml += xyzString("0.5", "-0.5", "-0.5");
							xml += '<W>-0.5</W>\n';
						}else if(rot==4){
							//correct
							xml += xyzString("-0.707106769","0","0");
							xml += '<W>0.707106769</W>\n';
						}else if(rot==5){
							//correct
							xml += xyzString("1", "0", "0");
							xml += '<W>0</W>\n';
						}else if(rot==6){
							//correct
							xml += xyzString("0", "0", "0");
							xml += '<W>1</W>\n';
						}else if(rot==7){
							//correct
							xml += xyzString("0.707106769","0","0");
							xml += '<W>0.707106769</W>\n';
						}else if(rot==8){							
							xml += xyzString("0.707106769","0.707106769","0");
							xml += '<W>0</W>\n';
						}else if(rot==9){
							xml += xyzString("0.707106769","-0.707106769","0");
							xml += '<W>0</W>\n';
						}else if(rot==10){
							xml += xyzString("0", "0", "-0.707106769");
							xml += '<W>0.707106769</W>\n';
						}else if(rot==11){
							xml += xyzString("0","0", "0.707106769");
							xml += '<W>0.707106769</W>\n';
						}					
					}
					xml += '</Orientation>\n';
					xml += '</MyObjectBuilder_CubeBlock>\n';
				}
					progress++;
					progressbar.setAttribute("value", progress.toString());
//					print(progress);
				});
			}
		}
	}
	
	Timer ts = new Timer(new Duration(milliseconds:activeblocks*2+6400*boards.length), (){
		print("Finishing");
		xml+="</CubeBlocks>\n";
		xml+="<IsStatic>false</IsStatic>\n";
		xml+="<Skeleton />\n";
		xml+="<LinearVelocity>\n";
		xml+=xyzString("0", "0","0");
		xml+="</LinearVelocity>\n";
		xml+="<AngularVelocity>\n";
		xml+=xyzString("0","0","0");
		xml+="</AngularVelocity>\n";
		xml+="<XMirroxPlane xsi:nil=\"true\" />\n";
		xml+="<YMirroxPlane xsi:nil=\"true\" />\n";
		xml+="<ZMirroxPlane xsi:nil=\"true\" />\n";
		xml+="</MyObjectBuilder_EntityBase>\n";

		return xml;
	});	

}


download(String value){
	Element downloadLink = new Element.html("<a>");
	downloadLink.setAttribute("href","data:text;charset=utf-8,"+Uri.encodeComponent(value));
	downloadLink.setAttribute("download", getFileName());
	document.body.nodes.add(downloadLink);
	downloadLink.click();
	document.body.nodes.remove(downloadLink);
}

getCurrentColor(){
	return document.getElementById("color").value;
}

setCurrentColor(String color){
	document.getElementById("color").value = color;
}


/*TODO:
 * saving support for full maps
 * import from file/text
 * brush sizes
 * add in white and default color block somehow
 * other block types
 * webgl 3d rendering
 * find way to set value without throwing warnings
 * neighbor lists (calculate at creation)
 * 
 *  acceptable color list
 *  Yellow
 *  Green
 *  Red
 *  Black
 *  White
 *  Blue
 *  
*/