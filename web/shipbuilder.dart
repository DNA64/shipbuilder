library shipbuilder;

import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'globals.dart';
import 'xmlexport.dart';



//import 'cube.dart' show CubeBlock;
import 'board.dart' show Board;

int width = 800;
int height = 800; //so symmetry works better

CanvasRenderingContext2D left_context;
CanvasRenderingContext2D middle_context;
CanvasRenderingContext2D right_context;

List<Board> boards = new List<Board>();

int boardnumber = 0;
var symmetry = [false,false,false];

String blocksize = "Large";
String brushblocktype = "LargeBlockArmorBlock";
String gridsize = "Large";

String brushtype = "constant";

Element dispboardnum = document.querySelector("#boardnumber");

//Element progressbar = document.querySelector("#exporting");

bool brushing = false;
bool exporting = false;

String xml = "";

void main() {
	CanvasElement left_canvas = document.querySelector("#left");
	left_canvas.width = width~/2;
	left_canvas.height = height~/2;
	CanvasElement middle_canvas = document.querySelector("#middle");
	middle_canvas.width = width;
	middle_canvas.height = height;
	CanvasElement right_canvas = document.querySelector("#right");
	right_canvas.width = width~/2;
	right_canvas.height = height~/2;

	
	left_context = left_canvas.getContext("2d");
	middle_context = middle_canvas.getContext("2d");
	right_context = right_canvas.getContext("2d");
	init_board();
	

	document.querySelector("#previous").onClick.listen((MouseEvent e){	
		previous_board();
	});
	export_board_button();
	document.querySelector("#next").onClick.listen((MouseEvent e){
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
			boards.elementAt(boardnumber).setAt(x, y, getRed(), getGreen(), getBlue());
		}
		boards.elementAt(boardnumber).draw(1);
	});
	
	middle_canvas.onMouseMove.listen((MouseEvent e){
		Timer passoff = new Timer(new Duration(milliseconds:1), (){
			if(brushtype=="constant"){
      			if(brushing){
      				var x = (e.offset.x);
      				var y = (e.offset.y);
      				boards.elementAt(boardnumber).setAt(x, y, getRed(), getGreen(), getBlue());
      			}
      		}
      		boards.elementAt(boardnumber).draw(1);
		});
	});
	
	
	document.querySelector("#clearboards").onClick.listen((MouseEvent e){
		Element confirmButton = mkConfirmButton();
		document.querySelector("#clearboardscontainer").nodes.add(confirmButton);
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
	
	document.querySelector("#clearboard").onClick.listen((MouseEvent e){
		Element confirmButton = mkConfirmButton();
		document.querySelector("#clearboardcontainer").nodes.add(confirmButton);
		confirmButton.onClick.listen((MouseEvent e){
			boards.remove(boards.elementAt(boardnumber));
			boards.insert(boardnumber, new Board(width~/sqwidth, height~/sqheight));
			draw_board();
			confirmButton.remove();
		});
		
		Timer removeButton = new Timer(new Duration(milliseconds:5000), (){
			try{
				confirmButton.remove();
			}catch(e){}
		});
	});
	
//	document.querySelector("#importsave").onChange.listen((Event e){
//		//only for importing atm
//		File f = document.querySelector("#importsave").files[0];
//		print(":"+f.size.toString()+":");
//		print(f.name);
//		print(f.type);
//		var reader = new FileReader();
//		reader.onLoadEnd.listen((Event e){
//			print(reader.result);
//			//start processing and loading the file
////				if(reader.result.toString().contains("SHIPBUILDERv0.2")){
//				//start loading the file
////				var lines = reader.result.toString().split("\n");
////				print(lines[0]);					
////				}
//			});
//			reader.readAsText(f.slice(0,f.size));
//	});
	
	document.querySelector("#importimage").onChange.listen((Event e){
		//only for importing atm
		File f = document.querySelector("#importimage").files[0];
		print(":"+f.size.toString()+":");
		print(f.name);
		print(f.type);
		
		
		var reader = new FileReader();
		reader.onLoadEnd.listen((Event e){
			document.querySelector("#preview").attributes["src"]= reader.result;
			ImageElement img = document.querySelector("#preview");
			CanvasElement cvs = document.querySelector("#hiddencanvas");
			cvs.attributes['width'] = img.naturalWidth.toString();
			cvs.attributes['height'] = img.naturalHeight.toString();
			
			CanvasRenderingContext2D previewImage = cvs.getContext("2d");
			previewImage.drawImage(img, 0,0);
			int imageWidth = int.parse(cvs.attributes['width']);
			int imageHeight = int.parse(cvs.attributes['height']);
			ImageData imgData = previewImage.getImageData(0, 0, imageWidth, imageHeight);
			List<int> pixels = imgData.data;
			print(pixels);
			int x = 1;
			int y = 1;
			for(int i =0; i<pixels.length;i+=4){
				if((i~/4)%(imageHeight)==0 && i!=0){
					y+=sqheight;
					x=1;
				}
				//RGBA
//				print(pixels[i].toString()+", "+pixels[i+1].toString()+", "+pixels[i+2].toString()+", "+pixels[i+3].toString());
				//set everything but 255,255,255,255 (white or blank)
				if(pixels[i]==255 && pixels[i+1]==255 && pixels[i+2]==255 && pixels[i+3]==255){
					//do nothing
				}else{
//					print(x.toString()+", "+y.toString());
					boards.elementAt(boardnumber).setAt(x, y, pixels[i].toDouble(), pixels[i+1].toDouble(), pixels[i+2].toDouble());
				}
				//increase width everytime, reset when i/4 == width of image
				x+=sqwidth;
				//increase height only when i/4==height of image
//				print((i~/4).toString()+" "+imageHeight.toString());
//				print(i~/4%imageHeight);
//				print(x.toString()+", "+y.toString());

			}
			boards[boardnumber].draw(1);
			});
			reader.readAsDataUrl(f.slice(0,f.size));
	});
	

	
	document.querySelector("#fillboard").onClick.listen((MouseEvent e){
		Element confirmButton = mkConfirmButton();
		document.querySelector("#fillboardcontainer").nodes.add(confirmButton);
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
	
	document.querySelector("#insertboard").onClick.listen((MouseEvent e){
	//shifts forward
		Element confirmButton = mkConfirmButton();
		document.querySelector("#insertboardcontainer").nodes.add(confirmButton);
		confirmButton.onClick.listen((MouseEvent e){
			if(boardnumber>0){
				boards.insert(boardnumber, new Board(width~/sqwidth,height~/sqheight));
				draw_board();
			}else{
				boards.insert(0, new Board(width~/sqwidth,height~/sqheight));
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
	
	document.querySelector("#shiptype").onChange.listen((Event e){
		String changeTo = document.querySelector("#shiptype").value;
		if(changeTo == "small"){
			blocksize = "Small";
			gridsize = "Small";
		}else if(changeTo=="large"){
			blocksize = "Large";
			gridsize = "Large";
		}
	});
	
	document.querySelector("#blocktype").onChange.listen((Event e){
		String changeTo = document.querySelector("#blocktype").value;
		
		if(changeTo=="largearmorblock"){
			brushblocktype="HeavyBlockArmorBlock";
		}else if(changeTo=="blastblock"){
			brushblocktype="ArmorCenter";
		}
		print(brushblocktype);
	});
	
	symmetryToggle("leftrightsymmetry",0);
	symmetryToggle("topbottomsymmetry",1);
	symmetryToggle("axissymmetry",2);
	
	document.querySelector("#brushtype").onChange.listen((Event e){
		brushtype = document.querySelector("#brushtype").value;
	});
	
	document.querySelector("#color").onChange.listen((Event e){
		brushblocktype = document.querySelector("#color").value;
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
//		print(e.keyCode);
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
			setCurrentColor("Block");
		}else if(e.keyCode== 68){
			//dump debug
			for(int i=0; i<boards.length; i++){
				Board b = boards.elementAt(i);
				for(int j=0; j<b.length(); j++){
					print(b.getAt(i, j).active);
				}
			}
		}
	});
	

}

symmetryToggle(String id, int location){
	document.querySelector('#'+id).onChange.listen((Event e){
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
	boards.add(new Board(width~/sqwidth, height~/sqheight));
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
	return document.querySelector("#filename").value;
}

export_board_button(){
	document.querySelector("#export").onClick.listen((MouseEvent e){
		if(!exporting){
			print("Export Button Clicked");
			String s = export_board();
			var numblocks = boards.length*width~/sqwidth*height~/sqheight;
//			Timer t = new Timer(new Duration(milliseconds:numblocks*2), (){
				print(s);
				download(s);
				exporting = false;
//				progressbar.setAttribute("value", "0".toString());
//			});
//			exporting = true;
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
	return document.querySelector('#'+xyz+"count").innerHtml;
}

String export_board(){
	var s= exportObject(getPosition('x'), getPosition('y'), getPosition('z'), gridsize, boards).toString();
	return s;
}


download(String value){
//	print(value.length);
	var data = new Blob([value]);
	Element downloadLink = new Element.html("<a>");
//	downloadLink.setAttribute("href","data:text;charset=utf-8,"+Uri.encodeComponent(value));
	downloadLink.setAttribute("href",Url.createObjectUrl(data));
//	downloadLink.setAttribute("download", getFileName());
	downloadLink.setAttribute("download", "Space Engineers.xml");
	document.body.nodes.add(downloadLink);
	downloadLink.click();
	document.body.nodes.remove(downloadLink);
}

setCurrentColor(String color){
	document.querySelector("color").value = color;
}

double getRed(){
	return double.parse(document.querySelector("#red").value);
}

double getBlue(){
	return double.parse(document.querySelector("#blue").value);
}

double getGreen(){
	return double.parse(document.querySelector("#green").value);
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
 * RGB to HSV (WOO FUCKING HOO!)
 * Import Image and crudely render
 * 		Freely scalable grid
 * Export xml using dart xml
 * Undo function (lol no)
 * FIXME TODO FIXME
 * Reimplement the progress bar thing
 * GIF Support (lol so funny)
 * 
*/