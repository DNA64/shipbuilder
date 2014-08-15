library block;

import 'dart:html';
import 'dart:math';

import 'cube.dart' show CubeBlock;
import 'globals.dart';
//import 'package:dartemis_toolbox/colors.dart';

class Block extends CubeBlock {

	// the x and y are the actual location of the canvas when the top-left corner of the rect is
	Block(int x, int y, {double r: 0.0, double g: 0.0, double b: 0.0}) {
		this.x = x;
		this.y = y;
		this.r = r;
		this.g = g;
		this.b = b;
	}

	draw(bool middle, CanvasRenderingContext2D context) {
		context.setFillColorRgb(r.toInt(), g.toInt(), b.toInt());
		if (active) {
			if (middle) {
				context.beginPath();
				context.rect(this.x, this.y, sqwidth, sqheight);
				context.fill();
				context.closePath();
			} else {
				context.beginPath();
				context.rect(this.x ~/ 2, this.y ~/ 2, sqwidth ~/ 2, sqheight ~/ 2);
				context.fill();
				context.closePath();
			}
		}
	}

	setRGB(double r, double g, double b) {
		this.r = r;
		this.g = g;
		this.b = b;
		//RGB->HSL->HSV
		//		print(v);
		var hsv = rgb2hsv(r,g,b);
		h = hsv[0];
		s = hsv[1];
		v = hsv[2];
//		print('####');
//		print(hsv[0]);
//		print(hsv[1]);
//		print(hsv[2]);
		
	}
	
	rgb2hsv(num red, num green, num blue){
		var rr, gg, bb,
						r = red / 255,
						g = green / 255,
						b = blue / 255,
						h, s,
						v = max(r, max(g, b)),
						diff = v - min(r, min(g, b)),
						diffc = (c){
								return (v - c) / 6 / diff + 1 / 2;
						};

				if (diff == 0) {
						h = s = 0;
				} else {
						s = diff / v;
						rr = diffc(r);
						gg = diffc(g);
						bb = diffc(b);

						if (r == v) {
								h = bb - gg;
						}else if (g == v) {
								h = (1 / 3) + rr - bb;
						}else if (b == v) {
								h = (2 / 3) + gg - rr;
						}
						if (h < 0) {
								h += 1;
						}else if (h > 1) {
								h -= 1;
						}
				}
				s=s*2-1;
				v=v*2-1;
				return [h,s,v];
	}
//FIXME better way to do this?
	//ONLY DOING THIS SO NO DUPLICATES IN THE DRAWLIST
	//ANY OTHER WAY I COULD SEE WOULD BE MORE INTENSIVE COMPUTATIONALLY
	operator ==(other){
		if(other is! Block) return false;
		Block block = other;

		return(block.x==x && block.y==y);
	}
	
	//from the example on the dart ch03
	int get hashCode{
		int result = 17;
		result = 37 * result + x.hashCode;
		result = 37 * result + y.hashCode;
		return result;
	}



}
