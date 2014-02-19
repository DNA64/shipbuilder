import 'dart:html';
import 'cube.dart' show CubeBlock;

class Block extends CubeBlock{
	Block(int x, int y, String color){	
		this.x = x;
		this.y = y;
		this.color = color;
	}
	
	draw(bool middle, CanvasRenderingContext2D context){
		context.fillStyle = color;
		if(active){
			if(middle){
				if(blocktype=="ArmorBlock" || blocktype=="HeavyBlockArmorBlock"){				
					context.beginPath();
					context.rect(this.x,this.y,sqwidth,sqheight);
					context.fill();	
					context.closePath();
				}
			}else{
				if(blocktype=="ArmorBlock" || blocktype=="HeavyBlockArmorBlock"){
					context.beginPath();
					context.rect(this.x~/2,this.y~/2,sqwidth~/2,sqheight~/2);
					context.fill();	
					context.closePath();
				}
			}
		}		
	}
	
}