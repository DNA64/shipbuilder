import 'dart:html';

int width = 800;
int height = 800;

CanvasRenderingContext2D left_context;
CanvasRenderingContext2D middle_context;
CanvasRenderingContext2D right_context;

List<Square> squares;
List<List> boards = new List<List>();

int boardnumber = 0;

Element dispboardnum = new Element.html("<p>");

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
		var x = (e.offset.x);
		var y = (e.offset.y);
		List<Square> tmplist = boards.elementAt(boardnumber);
		for(var i = 0; i<tmplist.length; i++){
			var cur = tmplist.elementAt(i);
			if(x>=cur.getX()&& x<=cur.getX()+10){				
				if(y>=cur.getY() && y<=cur.getY()+10){					
					tmplist.elementAt(i).toggle();
					print("Toggle");
					break;
				}
			}
		}
		draw_board();
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
			squares.add(new Square(i*10,j*10));
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

String export_board(){
	//have to export to xml
	//returns string to download, can be complete file or snippet
	return "hello this is a test";
}

download(String value){
	var uri = Uri.parse("data:text;charset=utf-8,"+value);
	Element downloadLink = new Element.html("<a>");
	downloadLink.setAttribute("href", uri.toString());
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

class Square{
	int x;
	int y;
	String color = 'white';
	bool active = false;
	static int sqwidth = 10;
	static int sqheight = 10;
	static var translator = {
		"":""
		
	};
	
	Square(int x, int y){
		this.x = x;
		this.y = y;
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
	
	toggle(){
		if(active){
			//deactivate - color white
			color = 'white';
		}else if(!active){
			color = 'black';
		}
		active = !active;
	}
	
	getX(){return x;}
	getY(){return y;}
}

/*TODO:
 * saving support for full maps and for snippents
 * 
 * 
 * 
 * 
 * 
*/
