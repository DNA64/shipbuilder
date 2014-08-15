library board;

import 'dart:html';

import 'cube.dart' show CubeBlock;
import 'block.dart' show Block;
import 'empty.dart' show Empty;
import 'globals.dart';

import 'shipbuilder.dart';


//a board is one board, boards are stored in another list (see shipbuilder.dart)
class Board{
	//rows is a list for click calling
	List<List> rows = new List<List>();
	
	//drawList is a list for all of the blocks that are active
	List<Block> drawList = new List<Block>();
	
	int widthinblocks,heightinblocks;
	
	Board(int width, int height){
		this.widthinblocks = width;
		this.heightinblocks = height;
		createBoard();
	}
	
	createBoard(){
		List<List> tmprows = new List<List>();
		for(var i = 0; i<heightinblocks; i++){
			int rownumber = i*sqheight;
			List<Object> row = new List<CubeBlock>();
			for(var j = 0; j<widthinblocks; j++){
				row.add(new Empty(j*sqwidth,rownumber));
			}
			tmprows.add(row);
		}
		rows = tmprows;
	}
	
	fill(){
		for(var i = 0; i<heightinblocks; i++){
			int rownumber = i*sqwidth;
			for(var j = 0; j<widthinblocks; j++){
				Block b = new Block(j*sqheight,rownumber, r:getRed(), g:getGreen(), b:getBlue());
				b.activate(true);
				b.setRGB(getRed(), getGreen(), getBlue());
				drawList.add(b);
			}
		}
	}
	
	draw(int pos){
//		clear(pos);
//		for(var i = 0; i<rows.length; i++){
//			List<CubeBlock> blocks = rows.elementAt(i);
//			for(int j = 0; j<blocks.length; j++){
//				var cur = blocks.elementAt(j);			
//				if(pos == 0){
//					cur.draw(false, left_context);
//				}else if(pos==1){
//					cur.draw(true, middle_context);
//				}else if(pos==2){
//					cur.draw(false, right_context);
//				}
//				
//			}
//		}
		clear(pos);
		for(Block b in drawList){
			switch(pos){
				case 0:
					b.draw(false, left_context);
					break;
				case 1:
					b.draw(true, middle_context);
//					print("Drawing at"+b.x.toString()+","+b.y.toString());
					break;
				case 2:
					b.draw(false, right_context);
					break;
			}
		}
	}
	
	//clears the context of the board
	static clear(int pos){
		CanvasRenderingContext2D context;
		if(pos == 0){
			context = left_context;
		}else if(pos == 1){
			context = middle_context;
		}else if(pos == 2){
			context = right_context;
		}
		int height = context.canvas.height;
		int width = context.canvas.width;
		context.clearRect(0,0,width,height); 
		context.fillStyle = '#ffffff'; 
		context.strokeStyle = '#000000'; 
		context.fillRect(0,0,width,height);
	}
	
	/**
	 * Returns the number of active blocks 
	 **/
	int activeBlocks(){
		return drawList.length;
	}
	
	CubeBlock getAt(int x, int y){
		return rows.elementAt(y).elementAt(x);
	}
	
	length(){
		return rows.length;
	}
	
	/**
	 * x - x value of mouse movement on canvas
	 * y - y value of mouse movement on canvas
	 * 
	 */
	setAt(int x, int y, double red, double green, double blue){
		for(var i = 0; i<rows.length; i++){
			List<CubeBlock> row = rows.elementAt(i);
			for(var j = 0; j<row.length; j++){
				var cur = row.elementAt(j);
				if(x>=cur.getX()&& x<=cur.getX()+sqwidth){				
					if(y>=cur.getY() && y<=cur.getY()+sqheight){
						
						Block b = new Block(cur.getX(),cur.getY());
						b.activate(true);
						//FIXME the contains check does NOT work
						if(!drawList.contains(b) && brushblocktype!="Erase"){
							b.setRGB(red, green, blue);
							b.setType(brushblocktype);
							drawList.add(b);
						}else if(brushblocktype=='Erase'){
							drawList.remove(b);
						}
		
						if(symmetry[0]){
								//left right symmetry
								try{
									var opposite = rows.elementAt(i).elementAt(widthinblocks-j);									
									Block ob = new Block(opposite.getX(), opposite.getY());
									ob.activate(true);
									if(!drawList.contains(ob) && brushblocktype!="Erase"){
										ob.setRGB(red, green, blue);
										ob.setType(brushblocktype);
										drawList.add(ob);
									}else if(brushblocktype=='Erase'){
										drawList.remove(ob);
									}
								}on RangeError{
									
								}
							}
							if(symmetry[1]){
								//top bottom symmetry
								try{
									var opposite = rows.elementAt(heightinblocks-i).elementAt(j);
									Block ob = new Block(opposite.getX(), opposite.getY());
									ob.activate(true);
									if(!drawList.contains(ob) && brushblocktype!="Erase"){
										ob.setRGB(red, green, blue);
										ob.setType(brushblocktype);
										drawList.add(ob);
									}else if(brushblocktype=='Erase'){
										drawList.remove(ob);
									}
								}on RangeError{
									//do nothing
								}
								
							}
							if(symmetry[2]){
								try{
									var opposite = rows.elementAt(heightinblocks-i).elementAt(widthinblocks-j);									
									Block ob = new Block(opposite.getX(), opposite.getY());
									ob.activate(true);
									if(!drawList.contains(ob) && brushblocktype!="Erase"){
										ob.setRGB(red, green, blue);
										ob.setType(brushblocktype);
										drawList.add(ob);
									}else if(brushblocktype=='Erase'){
										drawList.remove(ob);
									}
								}on RangeError{
									
								}
							}
					}
				}
			}
		}

		
	}
	
	getDrawList(){
		return drawList;
	}
}