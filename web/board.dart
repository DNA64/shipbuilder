import 'dart:html';

import 'cube.dart';
import 'slope.dart' show Slope;
import 'block.dart' show Block;
import 'empty.dart' show Empty;

import 'shipbuilder.dart';

class Board{
	List<List> rows = new List<List>();
	
	int widthinblocks,heightinblocks;
	
	Board(int width, int height){
		this.widthinblocks = width;
		this.heightinblocks = height;
		createBoard();
	}
	
	createBoard(){
		List<List> tmprows = new List<List>();
		for(var i = 0; i<heightinblocks; i++){
			int rownumber = i*10;
			List<Object> row = new List<CubeBlock>();
			for(var j = 0; j<widthinblocks; j++){
				row.add(new Empty(j*10,rownumber));
			}
			tmprows.add(row);
		}
		rows = tmprows;
	}
	
	fill(){
		List<List> tmprows = new List<List>();
		for(var i = 0; i<heightinblocks; i++){
			int rownumber = i*10;
			List<CubeBlock> row = new List<CubeBlock>();
			for(var j = 0; j<widthinblocks; j++){
				Block b = new Block(j*10,rownumber, getCurrentColor());
				b.activate(getCurrentColor());
				row.add(b);
			}
			tmprows.add(row);
		}
		rows = tmprows;
	}
	
	draw(int pos){
		clear(pos);
		for(var i = 0; i<rows.length; i++){
			List<CubeBlock> blocks = rows.elementAt(i);
			for(int j = 0; j<blocks.length; j++){
				var cur = blocks.elementAt(j);			
				if(pos == 0){
					cur.draw(false, left_context);
				}else if(pos==1){
					cur.draw(true, middle_context);
				}else if(pos==2){
					cur.draw(false, right_context);
				}
				
			}
		}
	}
	
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
	
	int activeBlocks(){
		int activeblocks = 0;
		for(int i = 0; i<rows.length; i++){
			List<CubeBlock> row = rows.elementAt(i);
			for(var k=0; k<rows.length; k++){
				CubeBlock square = row.elementAt(k);
				if(square.isActive()){
					activeblocks++;
				}
			}
		}
		return activeblocks;
	}
	
	CubeBlock getAt(int x, int y){
		return rows.elementAt(y).elementAt(x);
	}
	
	length(){
		return rows.length;
	}
	
	setAt(int x, int y){
		for(var i = 0; i<rows.length; i++){
			List<CubeBlock> row = rows.elementAt(i);
			for(var j = 0; j<row.length; j++){
//			//j = block number in row
				var cur = row.elementAt(j);
				if(x>=cur.getX()&& x<=cur.getX()+10){				
					if(y>=cur.getY() && y<=cur.getY()+10){
						if(brushblocktype=="ArmorBlock" || brushblocktype=="HeavyBlockArmorBlock"){
							if(cur is Block){
								cur.activate(getCurrentColor());
								cur.setType(brushblocktype);
								
							}else{
								rows.elementAt(i).remove(cur);
								Block b = new Block(cur.getX(),cur.getY(), getCurrentColor());
								b.activate(getCurrentColor());
								b.setType(brushblocktype);
								rows.elementAt(i).insert(j, b);
								
							}
							if(symmetry[0]){
								//left right symmetry
								//(j,i)								
								var opposite = rows.elementAt(i).elementAt(widthinblocks-j);									
								Block ob = new Block(opposite.getX(), opposite.getY(), getCurrentColor());
								row.removeAt(widthinblocks-j);
								ob.activate(getCurrentColor());
								ob.setType(brushblocktype);								
								row.insert(widthinblocks-j,ob);						
							}
							if(symmetry[1]){
								//top bottom symmetry
								var opposite = rows.elementAt(heightinblocks-i).elementAt(j);									
								Block ob = new Block(opposite.getX(), opposite.getY(), getCurrentColor());
								rows.elementAt(heightinblocks-i).removeAt(j);
								ob.activate(getCurrentColor());
								ob.setType(brushblocktype);								
								rows.elementAt(heightinblocks-i).insert(j,ob);	
							}
							if(symmetry[2]){
								var opposite = rows.elementAt(heightinblocks-i).elementAt(widthinblocks-j);									
								Block ob = new Block(opposite.getX(), opposite.getY(), getCurrentColor());
								rows.elementAt(heightinblocks-i).removeAt(widthinblocks-j);
								ob.activate(getCurrentColor());
								ob.setType(brushblocktype);								
								rows.elementAt(heightinblocks-i).insert(widthinblocks-j,ob);	
							}						
							}else if(brushblocktype=="ArmorSlope" || brushblocktype=="HeavyBlockArmorSlope"){								
								if(cur is Slope){									
									cur.activate(getCurrentColor());
									cur.setType(brushblocktype);
									cur.rotate();
									if(symmetry[0]){
									//left right symmetry
									//(j,i)								
										var opposite = rows.elementAt(i).elementAt(widthinblocks-j);									
										Slope os = new Slope(opposite.getX(), opposite.getY(), getCurrentColor());
										row.removeAt(widthinblocks-j);
										os.activate(getCurrentColor());
										os.setType(brushblocktype);
										os.rotate();
										row.insert(widthinblocks-j,os);						
									}
									if(symmetry[1]){
									//top bottom symmetry
										var opposite = rows.elementAt(heightinblocks-i).elementAt(j);									
										Slope os = new Slope(opposite.getX(), opposite.getY(), getCurrentColor());
										rows.elementAt(heightinblocks-i).removeAt(j);
										os.activate(getCurrentColor());
										os.setType(brushblocktype);
										os.rotate();
										rows.elementAt(heightinblocks-i).insert(j,os);	
									}
									if(symmetry[2]){
										var opposite = rows.elementAt(heightinblocks-i).elementAt(widthinblocks-j);									
										Slope os = new Slope(opposite.getX(), opposite.getY(), getCurrentColor());
										rows.elementAt(heightinblocks-i).removeAt(widthinblocks-j);
										os.activate(getCurrentColor());
										os.setType(brushblocktype);
										os.rotate();
										rows.elementAt(heightinblocks-i).insert(widthinblocks-j,os);	
									}
									
							}else{
							rows.elementAt(i).remove(cur);
							Slope s = new Slope(cur.getX(), cur.getY(), getCurrentColor());
							s.activate(getCurrentColor());
							s.setType(brushblocktype);
							s.rotate();
							rows.elementAt(i).insert(j, s);							
						}
							break;
						}
					}
				}
			}
		}
	}
}