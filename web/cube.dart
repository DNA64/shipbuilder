import 'dart:html';
import 'dart:math';
import 'globals.dart';

abstract class CubeBlock{
	int x;
	int y;
	double r,g,b;
	num h,s,v;
	bool active = false;
	String blocktype = "ArmorBlock";
	
	CubeBlock.make(int x, int y){
		this.x = x;
		this.y = y;
	}
	
	CubeBlock(){
	
	}
	
	
	draw(bool middle, CanvasRenderingContext2D context){}
	
	//true to turn on 
	//false to turn off
	activate(bool f){
		if(!f){
			active = false;
		}else if(f){			
			active = true;
		}
	}
	
	setType(String type){blocktype = type;}	
	getX(){return x;}
	getY(){return y;}
	getR(){return r;}
	getG(){return g;}
	getB(){return b;}
	isActive(){return active;}
	String getBlockType(){return blocktype;}	
}