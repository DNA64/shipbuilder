import 'dart:html';

class Block{
	int x;
	int y;
	int rotation = -1;
	String color = 'White';
	bool active = false;
	String blocktype = "ArmorBlock";
	
	static int sqwidth = 10;
	static int sqheight = 10;
	
	Block(int x, int y, String color, String type){
		this.x = x;
		this.y = y;
		this.color = color;
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

	
	draw(bool middle, CanvasRenderingContext2D context){
		context.fillStyle = color;
		context.setStrokeColorRgb(0, 0, 0, 1);
		if(active){
			if(middle){
				if(blocktype=="ArmorBlock" || blocktype=="HeavyBlockArmorBlock"){
					context.beginPath();
					context.rect(this.x,this.y,sqwidth,sqheight);
					context.fill();	
					context.closePath();
				}else if(blocktype=="ArmorSlope" || blocktype=="HeavyBlockArmorSlope"){
					//move ifs for rotation
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
	getX(){return x;}
	getY(){return y;}
	isActive(){return active;}
	String getBlockType(){return blocktype;}
	getRotation(){return rotation;}
	
}