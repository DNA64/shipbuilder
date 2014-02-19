import 'dart:html';
import 'cube.dart' show CubeBlock;

class Slope extends CubeBlock{
	int rotation = -1;

	Slope(int x, int y, String color){	
		this.x = x;
		this.y = y;
		this.color = color;
	}
	
	draw(bool middle, CanvasRenderingContext2D context){		
		context.fillStyle = color;
		context.setStrokeColorRgb(0, 0, 0, 1);
		if(active){
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
	
	rotate(){		
		if(rotation>=12){
			rotation = -1;
			activate("Erase");
			return;
		}
		rotation++;
	}
	
	getRotation(){return rotation;}
}
