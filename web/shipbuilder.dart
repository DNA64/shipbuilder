import 'dart:html';
import 'dart:math';
import 'dart:async';

int width = 800;
int height = 800;

CanvasRenderingContext2D left_context;
CanvasRenderingContext2D middle_context;
CanvasRenderingContext2D right_context;


List<List> rows;
List<List> boards = new List<List>();
List<List> brushlist;

int boardnumber = 0;
var symmetry = [false,false,false];

String blocksize = "Small";
String brushblocktype = "ArmorBlock";
String gridsize = "Small";

String brushtype = "constant";

Element dispboardnum = new Element.html("<p>");

Element progressbar = document.getElementById("exporting");

bool brushing = false;
bool exporting = false;

String xml = "";

void main() {
	Element canvasdiv = divElement("canvasdiv");
	CanvasElement left_canvas_ = side_canvas(canvasdiv, "left");
	CanvasElement middle_canvas = DrawingCanvas(canvasdiv);
	CanvasElement right_canvas_ = side_canvas(canvasdiv, "right");

	
	left_context = left_canvas_.getContext("2d");
	middle_context = middle_canvas.getContext("2d");
	right_context = right_canvas_.getContext("2d");
	init_board();
	
	clearBoard(left_context);
	clearBoard(middle_context);
	clearBoard(right_context);
	
	
	Element div = divElement("buttondiv");
	Element p = new Element.html("<p>");
	previous_board_button(p);
	export_board_button(p);
	next_board_button(p);
	div.children.add(p);
	
	middle_canvas.onClick.listen((MouseEvent e){
		if(brushtype=="constant"){
			if(brushing){
				brushing = false;
				for(var i = 0; i<brushlist.length; i++){
					List<Block> blocks = brushlist.elementAt(i);
					for(var j=0; j<blocks.length; j++){
						blocks.elementAt(j).change(false);
					}
				}
				rows = brushlist;
			}else if(!brushing){
				brushing = true;
				brushlist = rows;
			}
		}else if(brushtype=="dot"){
			var x = (e.offset.x);
			var y = (e.offset.y);
			List<List> listrows = boards.elementAt(boardnumber);
			for(var i = 0; i<listrows.length; i++){
				// i = rownumber
				List<Block> blocks = listrows.elementAt(i);
				for(var j = 0; j<blocks.length; j++){
					//j = block number in row
					Block cur = blocks.elementAt(j);
					if(x>=cur.getX()&& x<=cur.getX()+10){				
						if(y>=cur.getY() && y<=cur.getY()+10){
							if(brushblocktype=="ArmorBlock" || brushblocktype=="HeavyBlockArmorBlock"){
								cur.activate(getCurrentColor());
								cur.setType(brushblocktype);
								if(symmetry[0]){
								//left right symmetry
								//(j,i)								
									Block opposite = listrows.elementAt(i).elementAt(width~/10-j);
									opposite.activate(getCurrentColor());
									opposite.setType(brushblocktype);							
								}
								if(symmetry[1]){
								//top bottom symmetry
									Block opposite = listrows.elementAt(height~/10-i).elementAt(j);
									opposite.activate(getCurrentColor());
									opposite.setType(brushblocktype);
								}
								if(symmetry[2]){
								//axis symmetry
									Block opposite = listrows.elementAt(height~/10-i).elementAt(width~/10-j);
									opposite.activate(getCurrentColor());
									opposite.setType(brushblocktype);
								}
							}else if(brushblocktype=="ArmorSlope" || brushblocktype=="HeavyBlockArmorSlope"){
								cur.activate(getCurrentColor());
								cur.setType(brushblocktype);
								cur.rotate();
								if(symmetry[0]){
								//left right symmetry
								//(j,i)								
									Block opposite = listrows.elementAt(i).elementAt(width~/10-j);
									opposite.activate(getCurrentColor());
									opposite.setType(brushblocktype);
									opposite.rotate();
								}
								if(symmetry[1]){
								//top bottom symmetry
									Block opposite = listrows.elementAt(height~/10-i).elementAt(j);
									opposite.activate(getCurrentColor());
									opposite.setType(brushblocktype);
									opposite.rotate();
								}
								if(symmetry[2]){
								//axis symmetry
									Block opposite = listrows.elementAt(height~/10-i).elementAt(width~/10-j);
									opposite.activate(getCurrentColor());
									opposite.setType(brushblocktype);
									opposite.rotate();
								}
							}
						
							break;
						}
					}
				}
			}
			draw_board();
		}

	});
	
	middle_canvas.onMouseMove.listen((MouseEvent e){
		if(brushtype=="constant"){
			if(brushing){
				var x = (e.offset.x);
				var y = (e.offset.y);
				for(var i = 0; i<brushlist.length; i++){
					List<Block> blocks = brushlist.elementAt(i);
					for(var j = 0; j<blocks.length; j++){
						Block cur = blocks.elementAt(j);
						if(x>=cur.getX()&& x<=cur.getX()+10){				
							if(y>=cur.getY() && y<=cur.getY()+10){
								if(!cur.changed()){
									cur.activate(getCurrentColor());
									cur.setType(brushblocktype);
									cur.change(true);
									if(symmetry[0]){
									//left right symmetry
									//(j,i)								
										Block opposite = brushlist.elementAt(i).elementAt(width~/10-j);
										opposite.activate(getCurrentColor());
										opposite.setType(brushblocktype);
										opposite.change(true);
									}
									if(symmetry[1]){
								//top bottom symmetry
										Block opposite = brushlist.elementAt(height~/10-i).elementAt(j);
										opposite.activate(getCurrentColor());
										opposite.setType(brushblocktype);
										opposite.change(true);
									}
									if(symmetry[2]){
									//axis symmetry
										Block opposite = brushlist.elementAt(height~/10-i).elementAt(width~/10-j);
										opposite.activate(getCurrentColor());
										opposite.setType(brushblocktype);
										opposite.change(true);
									}
									
								}
								break;
							}
						}
					}
				}
				draw_brush_board();
			}
		}
	});
	
	document.getElementById("clearboards").onClick.listen((MouseEvent e){
		Element confirmButton = mkConfirmButton();
		document.getElementById("clearboardscontainer").nodes.add(confirmButton);
		confirmButton.onClick.listen((MouseEvent e){
	 		boards = new List<List>();
	 		boardnumber = 0;
		 	init_board();
		 	brushlist = rows;
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
			boards.remove(rows);
			init_board();
			brushlist = rows;
			draw_board();
			confirmButton.remove();
		});
		
		Timer removeButton = new Timer(new Duration(milliseconds:5000), (){
			try{
				confirmButton.remove();
			}catch(e){}
		});
	});
	

	
	document.getElementById("fillboard").onClick.listen((MouseEvent e){
		Element confirmButton = mkConfirmButton();
		document.getElementById("fillboardcontainer").nodes.add(confirmButton);
		confirmButton.onClick.listen((MouseEvent e){
			for(var i=0; i<rows.length; i++){
				List<Block> blocks = rows.elementAt(i);
				for(var j=0; j<blocks.length; j++){
					blocks.elementAt(j).activate(getCurrentColor());
				}
			}
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
			rows = mkBlankBoard();
			if(boardnumber>0){
				boards.insert(boardnumber, rows);
				draw_board();
			}else{
				boards.insert(0, rows);
				draw_board();
			}
			brushlist = rows;
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
			print("Previous Button Clicked");
			if(boardnumber>0){
				boardnumber--;
				draw_board();
				draw_side_boards();
			}
		}else if(e.keyCode == 39){
			//next board
			print("Next Button Clicked");
			boardnumber++;
			init_board();
			draw_side_boards();
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
			print(boards);
			for(var i =0; i<rows.length; i++){
				String tmpstring = "";
				for(var j = 0; j<rows.elementAt(i).length; j++){
					tmpstring+=(rows.elementAt(i).elementAt(j).active).toString()+", ";
				}
				print(tmpstring);
			}
		}
	});
	
	Element infodiv = divElement("infodiv");
	dispboardnum.id = "display";
	infodiv.children.add(dispboardnum);
	document.body.nodes.add(infodiv);

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
	rows = mkBlankBoard();
	boards.add(rows);
	draw_board();
}

List<List> mkBlankBoard(){
	List<List> tmprows = new List<List>();
	for(var i = 0; i<height~/10; i++){
		int rownumber = i*10;
		List<Block> row = new List<Block>();
		for(var j = 0; j<width~/10; j++){
			row.add(new Block(j*10,rownumber, "White", brushblocktype));
		}
		tmprows.add(row);
	}
	return tmprows;
}

draw_board(){
	//main board
	clearBoard(middle_context);
	List<List> middlelist = boards.elementAt(boardnumber);
	for(var i=0; i<middlelist.length; i++){
		List<Block> blocks = middlelist.elementAt(i);
		for(var j = 0; j<blocks.length; j++){
			blocks.elementAt(j).draw(true, middle_context);
		}
		
	}
	
	dispboardnum.innerHtml = "Boardnumber: "+boardnumber.toString();
}

draw_brush_board(){
	//	main board
	clearBoard(middle_context);
	for(var i=0; i<brushlist.length; i++){
		List<Block> blocks = brushlist.elementAt(i);
		for(var j=0;j<blocks.length; j++){
			blocks.elementAt(j).draw(true, middle_context);
		}
	}

	dispboardnum.innerHtml = "Boardnumber: "+boardnumber.toString();
}

draw_side_boards(){
	//left board
	clearBoard(left_context);
	if(boardnumber>0){
		List<List> leftlist = boards.elementAt(boardnumber-1);
		for(var i = 0; i<leftlist.length; i++){
			List<Block> blocks = leftlist.elementAt(i);
			for(var j=0; j<blocks.length; j++){
				blocks.elementAt(j).draw(false, left_context);
			}
		}
	}else{
	//clear board method
		clearBoard(left_context);
	}

	//right board
	clearBoard(right_context);
	if(boards.length>boardnumber+1){
		List<List> rightlist = boards.elementAt(boardnumber+1);
		for(var i = 0; i<rightlist.length; i++){
			List<Block> blocks = rightlist.elementAt(i);
			for(var j = 0; j<blocks.length; j++){
				blocks.elementAt(j).draw(false, right_context);
			}
		}
	}
}

DivElement divElement(String ID){
	var div = new Element.html('<div />');
	div.id = ID;
	document.body.nodes.add(div);
	return div;
}

Element side_canvas(Element addTo, String side){
	var canvas = new Element.html('<canvas/>');
	canvas.width = width~/2;
	canvas.height = height~/2;
	canvas.id = side;
	addTo.children.add(canvas);
	return canvas;
}

Element DrawingCanvas(Element addTo){
	var canvas = new Element.html('<canvas/>');
	canvas.width = width;
	canvas.height = height;
	canvas.id = "middle";
	addTo.children.add(canvas);
	return canvas;
}

String getFileName(){
	return document.getElementById("filename").value;
}


Element export_board_button(Element addTo){
	var button = new Element.html("<button>");
	button.type = "button";
	button.innerHtml = "Export";
	button.id = "export";
	button.onClick.listen((MouseEvent e){
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
	addTo.children.add(button);
	
	return button;
}

Element next_board_button(Element addTo){
	var button = new Element.html("<button>");
	button.type = "button";
	button.innerHtml = "Next";
	button.id = "next";
	button.onClick.listen((MouseEvent e){
		print("Next Button Clicked");
		boardnumber++;
		init_board();
		draw_side_boards();
	});
	addTo.children.add(button);
	
	return button;
	
}

Element previous_board_button(Element addTo){
	var button = new Element.html("<button>");
	button.type = "button";
	button.innerHtml = "Previous";
	button.id = "previous";
	button.onClick.listen((MouseEvent e){	
		print("Previous Button Clicked");
		if(boardnumber>0){
			boardnumber--;
			draw_board();
			draw_side_boards();
		}
	});
	addTo.children.add(button);
}

getPosition(String xyz){
	return document.getElementById(xyz+"count").innerHtml;
}

String export_board(){
	//have to export to xml
	var numboards = boards.length;
	int progress = 0;
	var numblocks = numboards*width~/10*height~/10;
	progressbar.setAttribute("max", numblocks.toString());
	progressbar.setAttribute("value", progress.toString());
	var rng = new Random();
	
	//returns string to download, can be complete file or snippet
	xml = '<MyObjectBuilder_EntityBase xsi:type="MyObjectBuilder_CubeGrid">\n'
	'<EntityId>'+(2403842243863731929+rng.nextInt(999)).toString()+'</EntityId>\n' //needs to be randomized?
	'<PersistentFlags>CastShadows InScene</PersistentFlags>\n'
	'<PositionAndOrientation>\n'
	'<Position>\n'
	'<X>'+getPosition('x')+'.00000000</X>\n' //it appears to need some kind of position with decimals
	'<Y>'+getPosition('y')+'.00000000</Y>\n'
	'<Z>'+getPosition('z')+'.00000000</Z>\n'
	'</Position>\n'
	'<Forward>\n'
	'<X>0.20000000</X>\n' //decimals needed here too?
	'<Y>0.30000000</Y>\n'
	'<Z>0.40000000</Z>\n'
	'</Forward>\n'
	'<Up>\n'
	'<X>0.30000000</X>\n'
	'<Y>0.20000000</Y>\n'
	'<Z>0.40000000</Z>\n'
	'</Up>\n'
	'</PositionAndOrientation>\n'
	'<GridSizeEnum>'+gridsize+'</GridSizeEnum>\n'
	'<CubeBlocks>\n'	
	;
	var activeblocks = 0;
	for(var i=0; i<boards.length; i++){
		List<List> boardlist = boards.elementAt(i);
			for(var j=0; j<boardlist.length; j++){
				List<Block> rows = boardlist.elementAt(j);
				for(var k=0; k<rows.length; k++){
					Block square = rows.elementAt(k);
					if(square.isActive()){
						activeblocks++;
					}
				}
			}
	}
	print("ActiveBlocks: "+activeblocks.toString());

	for(var i=0; i<boards.length; i++){
		List<List> boardlist = boards.elementAt(i);
		for(var j=0; j<boardlist.length; j++){
			List<Block> rows = boardlist.elementAt(j);
			for(var k=0; k<rows.length; k++){
				Timer t = new Timer(new Duration(milliseconds:i*j*k+2), (){
				Block square = rows.elementAt(k);
				if(square.isActive()){
					xml += '<MyObjectBuilder_CubeBlock>\n';
					xml += '<SubtypeName>'+square.getType()+'</SubtypeName>\n';
					xml += '<EntityId>0</EntityId>\n';
					xml += '<PersistentFlags>None</PersistentFlags>\n';
					xml += '<Min>\n';
					xml += '<X>'+(square.getX()~/10).toString()+'</X>\n';
					xml += '<Y>'+(square.getY()~/10).toString()+'</Y>\n';
					xml += '<Z>'+i.toString()+'</Z>\n';
					xml += '</Min>\n';
					xml += '<Max>\n';
					xml += '<X>'+(square.getX()~/10).toString()+'</X>\n';
					xml += '<Y>'+(square.getY()~/10).toString()+'</Y>\n';
					xml += '<Z>'+i.toString()+'</Z>\n';
					xml += '</Max>\n';
					xml += '<Orientation>\n';
					if(square.getBlockType()=="ArmorBlock" || square.getBlockType()=="HeavyBlockArmorBlock"){
						xml += '<X>0</X>\n';
						xml += '<Y>0</Y>\n';
						xml += '<Z>0</Z>\n';
						xml += '<W>1</W>\n';
					}else if(square.getBlockType()=="ArmorSlope" || square.getBlockType()=="HeavyBlockArmorSlope"){
						int rot = square.getRotation();
						if(rot == 0){
							//correct
							xml += '<X>0.5</X>\n';
							xml += '<Y>-0.5</Y>\n';
							xml += '<Z>0.5</Z>\n';
							xml += '<W>0.5</W>\n';
						}else if(rot==1){
							//correct
							xml += '<X>0.5</X>\n';
							xml += '<Y>0.5</Y>\n';
							xml += '<Z>-0.5</Z>\n';
							xml += '<W>0.5</W>\n';
						}else if(rot==2){
							//correct
							xml += '<X>0.5</X>\n';
							xml += '<Y>0.5</Y>\n';
							xml += '<Z>0.5</Z>\n';
							xml += '<W>-0.5</W>\n';
						}else if(rot==3){
							//correct
							xml += '<X>0.5</X>\n';
							xml += '<Y>-0.5</Y>\n';
							xml += '<Z>-0.5</Z>\n';
							xml += '<W>-0.5</W>\n';
						}else if(rot==4){
							//correct
							xml += '<X>-0.707106769</X>\n';
							xml += '<Y>0</Y>\n';
							xml += '<Z>0</Z>\n';
							xml += '<W>0.707106769</W>\n';
						}else if(rot==5){
							//correct
							xml += '<X>1</X>\n';
							xml += '<Y>0</Y>\n';
							xml += '<Z>0</Z>\n';
							xml += '<W>0</W>\n';
						}else if(rot==6){
							//correct
							xml += '<X>0</X>\n';
							xml += '<Y>0</Y>\n';
							xml += '<Z>0</Z>\n';
							xml += '<W>1</W>\n';
						}else if(rot==7){
							//correct
							xml += '<X>0.707106769</X>\n';
							xml += '<Y>0</Y>\n';
							xml += '<Z>0</Z>\n';
							xml += '<W>0.707106769</W>\n';
						}else if(rot==8){
							xml += '<X>0.707106769</X>\n';
							xml += '<Y>0.707106769</Y>\n';
							xml += '<Z>0</Z>\n';
							xml += '<W>0</W>\n';
						}else if(rot==9){
							xml += '<X>0.707106769</X>\n';
							xml += '<Y>-0.707106769</Y>\n';
							xml += '<Z>0</Z>\n';
							xml += '<W>0</W>\n';
						}else if(rot==10){
							xml += '<X>0</X>\n';
							xml += '<Y>0</Y>\n';
							xml += '<Z>-0.707106769</Z>\n';
							xml += '<W>0.707106769</W>\n';
						}else if(rot==11){
							xml += '<X>0</X>\n';
							xml += '<Y>0</Y>\n';
							xml += '<Z>0.707106769</Z>\n';
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
		xml+="<X>0</X>\n";
		xml+="<Y>0</Y>\n";
		xml+="<Z>0</Z>\n";
		xml+="</LinearVelocity>\n";
		xml+="<AngularVelocity>\n";
		xml+="<X>0</X>\n";
		xml+="<Y>0</Y>\n";
		xml+="<Z>0</Z>\n";
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

clearBoard(CanvasRenderingContext2D context){
	context.clearRect(0,0,width,height); 
	context.fillStyle = '#ffffff'; 
	context.strokeStyle = '#000000'; 
	context.fillRect(0,0,width,height);
}

getCurrentColor(){
	return document.getElementById("color").value;
}

setCurrentColor(String color){
	document.getElementById("color").value = color;
}

class Block{
	int x;
	int y;
	int rotation = -1;
	String color = 'White';
	bool active = false;
	bool hasBeenChanged = false;
	String blocktype = "ArmorBlock";
	
	static int sqwidth = 10;
	static int sqheight = 10;
	
	Block(int x, int y, String color, String type){
		this.x = x;
		this.y = y;
		this.color = color;
	}
	
	
	String getType(){
		if(color=='White'){
			if(blocktype=="HeavyBlockArmorBlock" || blocktype=="HeavyBlockArmorSlope"){
				//heavy blocks don't need the "Block"
				return blocksize+blocktype;
			}else{
				//other blocks do
				return blocksize+"Block"+blocktype;
			}
		}else{
			if(blocktype=="HeavyBlockArmorBlock" || blocktype=="HeavyBlockArmorSlope"){
				return blocksize+blocktype+color;
			}else{
				return blocksize+"Block"+blocktype+color;
		}
		}
	}

	
	draw(bool middle, CanvasRenderingContext2D context){
		context.fillStyle = color;
		context.setStrokeColorRgb(0, 0, 0, 1);
		if(active){
			if(middle){
				if(blocktype=="ArmorBlock" || blocktype=="HeavyBlockArmorBlock"){
					context.beginPath();
					context.rect(this.x,this.y,sqwidth,sqheight);
					context.fill();	
					context.closePath();
				}else if(blocktype=="ArmorSlope" || blocktype=="HeavyBlockArmorSlope"){
					//move ifs for rotation
					context.beginPath();
					Point topleft = new Point(x,y);
					Point topright = new Point(x+sqwidth, y);
					Point bottomleft = new Point(x, y+sqheight);
					Point bottomright = new Point(x+sqwidth, y+sqheight);
					if(rotation==0){
						drawTriangleLines(context, bottomleft, bottomright, topright);
						return;
					}else if(rotation==1){
						drawTriangleLines(context, topleft, bottomleft, bottomright);
						return;
					}else if(rotation==2){
						drawTriangleLines(context, topleft, topright, bottomleft);
						return;
					}else if(rotation==3){
						drawTriangleLines(context, topleft, topright, bottomright);
						return;
					}else if(rotation==4){
						//square with line at top
						context.rect(this.x, this.y, sqwidth, sqheight);	
						context.setFillColorRgb(255, 255, 255, 1);
						context.moveTo(x+2, y+2);
						context.lineTo(x+sqwidth-2, y+2);
					}else if(rotation==5){
						context.rect(this.x, this.y, sqwidth, sqheight);
						context.setFillColorRgb(255, 255,255,1);
						context.moveTo(x+2, y+sqheight-2);
						context.lineTo(x+sqwidth-2, y+sqheight-2);
					}else if(rotation==6){
						context.rect(this.x, this.y, sqwidth, sqheight);
						context.fill();
						context.stroke();
						context.closePath();						
						
						context.beginPath();
						context.moveTo(x+2, y+2);
						context.lineTo(x+sqwidth-2, y+2);
						context.setStrokeColorRgb(255,255,255,1);
						context.stroke();
						context.closePath();
						return;
					}else if(rotation==7){
						context.rect(this.x, this.y, sqwidth, sqheight);
						context.fill();
						context.stroke();
						context.closePath();						
						
						context.beginPath();
						context.moveTo(x+2, y+sqheight-2);
						context.lineTo(x+sqwidth-2, y+sqheight-2);
						context.setStrokeColorRgb(255,255,255,1);
						context.stroke();
						context.closePath();
						return;
					}else if(rotation==8){
						context.rect(this.x, this.y, sqwidth, sqheight);
						context.setFillColorRgb(255, 255,255,1);
						context.moveTo(x+2, y+2);
						context.lineTo(x+2, y+sqheight-2);
					}else if(rotation==9){
						context.rect(this.x, this.y, sqwidth, sqheight);
						context.setFillColorRgb(255, 255,255,1);
						context.moveTo(x+sqwidth-2, y+2);
						context.lineTo(x+sqwidth-2, y+sqheight-2);
					}else if(rotation==10){
						context.rect(this.x, this.y, sqwidth, sqheight);
						context.fill();
						context.stroke();
						context.closePath();					
					
						context.beginPath();
						context.moveTo(x+2, y+2);
						context.lineTo(x+2, y+sqheight-2);
						context.setStrokeColorRgb(255,255,255,1);
						context.stroke();
						context.closePath();
						return;
					}else if(rotation==11){
						context.rect(this.x, this.y, sqwidth, sqheight);
						context.fill();
						context.stroke();
						context.closePath();					
					
						context.beginPath();
						context.moveTo(x+sqwidth-2, y+2);
						context.lineTo(x+sqwidth-2, y+sqheight-2);
						context.setStrokeColorRgb(255,255,255,1);
						context.stroke();
						context.closePath();
						return;
					}
					context.fill();
					context.stroke();
					context.closePath();
				}
			}else{
				if(blocktype=="ArmorBlock"){
					context.beginPath();
					context.rect(this.x~/2,this.y~/2,sqwidth~/2,sqheight~/2);
					context.fill();	
					context.closePath();
				}else if(blocktype=="ArmorSlope"){
				
				}
			}
		}

	}
	
	drawTriangleLines(CanvasRenderingContext2D context, Point p1, Point p2, Point p3){
		context.moveTo(p1.x, p1.y);
		context.lineTo(p2.x, p2.y);
		context.lineTo(p3.x, p3.y);
		context.lineTo(p1.x, p1.y);
		context.fill();
		context.stroke();
		context.closePath();
	}
	
	activate(String color){
		if(color == 'Erase'){
			//deactivate - color white
			this.color = 'White';
			active = false;
		}else if(color != 'Erase'){			
			this.color = color;
			active = true;
		}

	}
	
	rotate(){		
		if(rotation>=12){
			rotation = -1;
			activate("Erase");
			return;
		}
		rotation++;
	}

	
	setType(String type){blocktype = type;}	
	change(bool change){hasBeenChanged = change;}
	bool changed(){return hasBeenChanged;}
	getX(){return x;}
	getY(){return y;}
	isActive(){return active;}
	String getBlockType(){return blocktype;}
	getRotation(){return rotation;}
	
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
 * nicer files (not one big massive one)
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