import 'dart:html';

import 'block.dart';

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
			List<Block> row = new List<Block>();
			for(var j = 0; j<widthinblocks; j++){
				row.add(new Block(j*10,rownumber, "White", brushblocktype));
			}
			tmprows.add(row);
		}
		rows = tmprows;
	}
	
	fillBoard(){
		List<List> tmprows = new List<List>();
		for(var i = 0; i<heightinblocks; i++){
			int rownumber = i*10;
			List<Block> row = new List<Block>();
			for(var j = 0; j<widthinblocks; j++){
				row.add(new Block(j*10,rownumber, getCurrentColor(), brushblocktype));
			}
			tmprows.add(row);
		}
		rows = tmprows;
	}
	
	draw(int pos){
		clear(pos);
		for(var i = 0; i<rows.length; i++){
			List<Block> blocks = rows.elementAt(i);
			for(int j = 0; j<blocks.length; j++){
				if(pos == 0){
					blocks.elementAt(j).draw(false, left_context);
				}else if(pos==1){
					blocks.elementAt(j).draw(true, middle_context);
				}else if(pos==2){
					blocks.elementAt(j).draw(false, right_context);
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
	
	fill(){
		for(int i = 0; i<rows.length; i++){
			List<Block> row = rows.elementAt(i);
			for(int j = 0; j<row.length; j++){
				Block cur = row.elementAt(j);				
				cur.activate(getCurrentColor());
			}
		}
	}
	
	int activeBlocks(){
		int activeblocks = 0;
		for(int i = 0; i<rows.length; i++){
			List<Block> row = rows.elementAt(i);
			for(var k=0; k<rows.length; k++){
				Block square = row.elementAt(k);
				if(square.isActive()){
					activeblocks++;
				}
			}
		}
		return activeblocks;
	}
	
	Block getAt(int x, int y){
		return rows.elementAt(y).elementAt(x);
	}
	
	length(){
		return rows.length;
	}
	
	setAt(int x, int y){
		for(var i = 0; i<rows.length; i++){
			List<Block> row = rows.elementAt(i);
			for(var j = 0; j<row.length; j++){
			//j = block number in row
				Block cur = row.elementAt(j);
				if(x>=cur.getX()&& x<=cur.getX()+10){				
					if(y>=cur.getY() && y<=cur.getY()+10){
						if(brushblocktype=="ArmorBlock" || brushblocktype=="HeavyBlockArmorBlock"){
							cur.activate(getCurrentColor());
							cur.setType(brushblocktype);
							if(symmetry[0]){
								//				left right symmetry
								//			(j,i)								
								Block opposite = rows.elementAt(i).elementAt(widthinblocks-j);
								opposite.activate(getCurrentColor());
								opposite.setType(brushblocktype);							
							}
							if(symmetry[1]){
								//	top bottom symmetry
								Block opposite = rows.elementAt(heightinblocks-i).elementAt(j);
								opposite.activate(getCurrentColor());
								opposite.setType(brushblocktype);
							}
							if(symmetry[2]){
							//	axis symmetry
								Block opposite = rows.elementAt(heightinblocks-i).elementAt(widthinblocks-j);
								opposite.activate(getCurrentColor());
								opposite.setType(brushblocktype);
							}
							}else if(brushblocktype=="ArmorSlope" || brushblocktype=="HeavyBlockArmorSlope"){
								cur.activate(getCurrentColor());
								cur.setType(brushblocktype);
								cur.rotate();
								if(symmetry[0]){
									//left right symmetry
									//			(j,i)								
									Block opposite = rows.elementAt(i).elementAt(widthinblocks-j);
									opposite.activate(getCurrentColor());
									opposite.setType(brushblocktype);
									opposite.rotate();
								}
								if(symmetry[1]){
									//	top bottom symmetry
									Block opposite = rows.elementAt(heightinblocks-i).elementAt(j);
									opposite.activate(getCurrentColor());
									opposite.setType(brushblocktype);
									opposite.rotate();
								}
								if(symmetry[2]){
								//axis symmetry
									Block opposite = rows.elementAt(heightinblocks-i).elementAt(widthinblocks-j);
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
	}
}