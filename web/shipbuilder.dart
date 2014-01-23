import 'dart:html';
import 'dart:math';

int width = 800;
int height = 800;

CanvasRenderingContext2D left_context;
CanvasRenderingContext2D middle_context;
CanvasRenderingContext2D right_context;

List<Square> squares;
List<List> boards = new List<List>();
List<Square> brushlist;

int boardnumber = 0;

String blocksize = "SmallBlock";
String blocktype = "ArmorBlock";
String gridsize = "Small";

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
		if(brushing){
			brushing = false;
			for(var i = 0; i<brushlist.length; i++){
				brushlist.elementAt(i).change(false);
			}
			squares = brushlist;
		}else if(!brushing){
			brushing = true;
			brushlist = squares;
		}
		// keep this around for indiviual square painting later possibly
//		var x = (e.offset.x);
//		var y = (e.offset.y);
//		List<Square> tmplist = boards.elementAt(boardnumber);
//		for(var i = 0; i<tmplist.length; i++){
//			var cur = tmplist.elementAt(i);
//			if(x>=cur.getX()&& x<=cur.getX()+10){				
//				if(y>=cur.getY() && y<=cur.getY()+10){					
//					tmplist.elementAt(i).toggle();
////					print("Toggle");
//					break;
//				}
//			}
//		}
//		draw_board();
	});
	
	middle_canvas.onMouseMove.listen((MouseEvent e){
		if(brushing){
			var x = (e.offset.x);
			var y = (e.offset.y);
			for(var i = 0; i<brushlist.length; i++){
				var cur = brushlist.elementAt(i);
				if(x>=cur.getX()&& x<=cur.getX()+10){				
					if(y>=cur.getY() && y<=cur.getY()+10){
						if(!brushlist.elementAt(i).changed()){
							brushlist.elementAt(i).toggle(getCurrentColor());
							brushlist.elementAt(i).change(true);
							print("Toggle");
						}
						
						break;
					}
				}
			}
			draw_brush_board();
		}
	});
	
	document.getElementById("clearboard").onClick.listen((MouseEvent e){
	 	boards = new List<List>();
	 	init_board();
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
	
	document.body.onKeyDown.listen((KeyboardEvent e){
		/*
		 * 37 = <-
		 * 39 = ->
		 * 38 = ^
		 * 40 = v
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
		}
	});
	
	Element infodiv = divElement("infodiv");
	dispboardnum.id = "display";
	infodiv.children.add(dispboardnum);
	document.body.nodes.add(infodiv);

}

init_board(){
	squares = new List<Square>();
	for(var i = 0; i<width~/10; i++){
		for(var j = 0; j<height~/10; j++){
			squares.add(new Square(i*10,j*10, "White"));
		}
	}
	boards.add(squares);
	draw_board();
}

draw_board(){
	//main board
	clearBoard(middle_context);
	List<Square> middlelist = boards.elementAt(boardnumber);
	for(var i=0; i<middlelist.length; i++){
		middlelist.elementAt(i).draw(true, middle_context);
	}
	
	dispboardnum.innerHtml = "Boardnumber: "+boardnumber.toString();
}

draw_brush_board(){
	//	main board
	clearBoard(middle_context);
	for(var i=0; i<brushlist.length; i++){
		brushlist.elementAt(i).draw(true, middle_context);
	}

	dispboardnum.innerHtml = "Boardnumber: "+boardnumber.toString();
}

draw_side_boards(){
	//left board
	clearBoard(left_context);
	if(boardnumber>0){
		List<Square> leftlist = boards.elementAt(boardnumber-1);
		for(var i = 0; i<leftlist.length; i++){
			leftlist.elementAt(i).draw(false, left_context);
		}
	}else{
	//clear board method
		clearBoard(left_context);
	}

	//right board
	clearBoard(right_context);
	print(boards.length);
	print(boardnumber);
	print(boards.length-1>boardnumber+1);
	if(boards.length-1>boardnumber+1){
		List<Square> rightlist = boards.elementAt(boardnumber+1);
		for(var i = 0; i<rightlist.length; i++){
			rightlist.elementAt(i).draw(false, right_context);
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
		List<Square> tmps = boards.elementAt(i);
		for(var j=0; j<tmps.length; j++){
			Square square = tmps.elementAt(j);
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
				xml += '<X>0</X>\n';
				xml += '<Y>0</Y>\n';
				xml += '<Z>0</Z>\n';
				xml += '<W>1</W>\n';
				xml += '</Orientation>\n';
				xml += '</MyObjectBuilder_CubeBlock>\n';
				print(square.getX()~/10);
				print(square.getY()~/10);
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

//	print(xml);
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

class Square{
	int x;
	int y;
	String color = 'White';
	bool active = false;
	bool hasBeenChanged = false;
	
	static int sqwidth = 10;
	static int sqheight = 10;
	
	Square(int x, int y, String color){
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
		if(active){
			if(middle){
				context.beginPath();
				context.rect(this.x,this.y,sqwidth,sqheight);
				context.fillStyle = color;
				context.fill();	
				context.closePath();
			}else{
				context.beginPath();
				context.rect(this.x~/2,this.y~/2,sqwidth~/2,sqheight~/2);
				context.fillStyle = color;
				context.fill();	
				context.closePath();
			}
		}

	}
	
	toggle(String color){
		if(color == 'Erase'){
			//deactivate - color white
			this.color = 'White';
			active = false;
		}else if(color != 'Erase'){			
			this.color = getCurrentColor();
			print(this.color);
			active = true;
		}

	}
	
	change(bool change){hasBeenChanged = change;}
	bool changed(){return hasBeenChanged;}
	getX(){return x;}
	getY(){return y;}
	isActive(){return active;}
}
/*TODO:
 * saving support for full maps
 * brush sizes
 * confirmation for clearing board
 * add in white and default color block somehow
 * other block types
 * 
 * 	
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