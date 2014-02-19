import 'dart:html';

abstract class CubeBlock{
	int x;
	int y;
	String color = 'White';
	bool active = false;
	String blocktype = "ArmorBlock";
	
	int sqwidth = 10;
	int sqheight = 10;
	
	CubeBlock.make(int x, int y){
		this.x = x;
		this.y = y;
	}
	
	CubeBlock(){
	
	}
	
	String getType(String blocksize){
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

	
	draw(bool middle, CanvasRenderingContext2D context){}
	
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
	
	setType(String type){blocktype = type;}	
	getX(){return x;}
	getY(){return y;}
	isActive(){return active;}
	String getBlockType(){return blocktype;}

	
}