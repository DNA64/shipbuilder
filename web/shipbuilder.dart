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

String blocksize = "SmallBlock";
String brushblocktype = "ArmorBlock";
String gridsize = "Small";

String brushtype = "constant";

Element dispboardnum = new Element.html("<p>");

bool brushing = false;

void main() {
	Element canvasdiv = divElement("canvasdiv");
	CanvasElement left_canvas_ = left_canvas(canvasdiv);
	CanvasElement middle_canvas = DrawingCanvas(canvasdiv);
	CanvasElement right_canvas_ = right_canvas(canvasdiv);

	
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
		List<List> tmplist = boards.elementAt(boardnumber);
		for(var i = 0; i<tmplist.length; i++){
			List<Block> blocks = tmplist.elementAt(i);
			for(var j = 0; j<blocks.length; j++){
				Block cur = blocks.elementAt(j);
				if(x>=cur.getX()&& x<=cur.getX()+10){				
					if(y>=cur.getY() && y<=cur.getY()+10){					
						if(brushblocktype=="ArmorBlock"){
							cur.activate(getCurrentColor());
							cur.setType(brushblocktype);
						}else if(brushblocktype=="ArmorSlope"){
							cur.activate(getCurrentColor());
							cur.setType(brushblocktype);
							cur.rotate();
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
	
	
	
	document.getElementById("shiptype").onChange.listen((Event e){
		String changeTo = document.getElementById("shiptype").value;
		if(changeTo == "small"){
			blocksize = "SmallBlock";
			gridsize = "Small";
		}else if(changeTo=="large"){
			blocksize = "LargeBlock";
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
		}
	});
	
	document.getElementById("brushtype").onChange.listen((Event e){
		brushtype = document.getElementById("brushtype").value;
	});
	
	document.body.onKeyDown.listen((KeyboardEvent e){
		/*
		 * 37 = <-
		 * 39 = ->
		 * 38 = ^
		 * 40 = v
		 */
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
		}
	});
	
	Element infodiv = divElement("infodiv");
	dispboardnum.id = "display";
	infodiv.children.add(dispboardnum);
	document.body.nodes.add(infodiv);

}

mkConfirmButton(){
	Element confirmButton = new Element.html("<input>");
	confirmButton.setAttribute("type", "button");
	confirmButton.setAttribute("value", "Confirm");
	return confirmButton;
}

init_board(){
	rows = new List<List>();
	for(var i = 0; i<height~/10; i++){
		int rownumber = i*10;
		List<Block> row = new List<Block>();
		for(var j = 0; j<width~/10; j++){
			row.add(new Block(j*10,rownumber, "White", brushblocktype));
		}
		rows.add(row);
	}
	boards.add(rows);
	draw_board();
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
	if(boards.length-1>boardnumber+1){
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

Element left_canvas(Element addTo){
	var canvas = new Element.html('<canvas/>');
	canvas.width = width~/2;
	canvas.height = height~/2;
	canvas.id = "left";
	addTo.children.add(canvas);
	return canvas;
}

Element right_canvas(Element addTo){
	var canvas = new Element.html('<canvas/>');
	canvas.width = width~/2;
	canvas.height = height~/2;
	canvas.id = "right";
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



Element export_board_button(Element addTo){
	var button = new Element.html("<button>");
	button.type = "button";
	button.innerHtml = "Export";
	button.id = "export";
	button.onClick.listen((MouseEvent e){
		print("Export Button Clicked");
		download(export_board());
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
	var rng = new Random();
	
	//returns string to download, can be complete file or snippet
	String xml = '<MyObjectBuilder_EntityBase xsi:type="MyObjectBuilder_CubeGrid">\n'
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

	
	for(var i=0; i<boards.length; i++){
		List<List> boardlist = boards.elementAt(i);
		for(var j=0; j<boardlist.length; j++){
			List<Block> rows = boardlist.elementAt(j);
			for(var k=0; k<rows.length; k++){
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
					if(square.getBlockType()=="ArmorBlock"){
						xml += '<X>0</X>\n';
						xml += '<Y>0</Y>\n';
						xml += '<Z>0</Z>\n';
						xml += '<W>1</W>\n';
					}else if(square.getBlockType()=="ArmorSlope"){
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
			}
		}
	}
	
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
}

download(String value){
	Element downloadLink = new Element.html("<a>");
	downloadLink.setAttribute("href","data:text;charset=utf-8,"+Uri.encodeComponent(value));
	downloadLink.setAttribute("download", "SpaceEngineers.xml");
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
			return blocksize+blocktype;
		}else{
			return blocksize+blocktype+color;
		}
	}

	
	draw(bool middle, CanvasRenderingContext2D context){
		context.fillStyle = color;
		context.setStrokeColorRgb(0, 0, 0, 1);
		if(active){
			if(middle){
				if(blocktype=="ArmorBlock"){
					context.beginPath();
					context.rect(this.x,this.y,sqwidth,sqheight);
					context.fill();	
					context.closePath();
				}else if(blocktype=="ArmorSlope"){
					//move ifs for rotation
					context.beginPath();
					if(rotation==0){
						drawTriangleLines(context, new Point(x, y+sqheight), new Point(x+sqwidth, y+sqheight), new Point(x+sqwidth, y));
						return;
					}else if(rotation==1){
						drawTriangleLines(context, new Point(x,y), new Point(x, y+sqheight), new Point(x+sqwidth, y+sqheight));
						return;
					}else if(rotation==2){
						drawTriangleLines(context, new Point(x,y), new Point(x+sqwidth, y), new Point(x, y+sqheight));
						return;
					}else if(rotation==3){
						drawTriangleLines(context, new Point(x,y), new Point(x+sqwidth, y), new Point(x+sqwidth, y+sqheight));
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