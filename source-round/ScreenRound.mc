using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
import Toybox.Lang;

//fonts
// https://developer.garmin.com/connect-iq/user-experience-guide/appendices/


//four fields top, two middle, bottom
//Name			Left	Top	Width	Height	Obscurity Flags	Obscure Left	Obscure Right	Obscure Top	Obscure Bottom
//Field One		0		0	240	77	7	TRUE	TRUE	TRUE	FALSE
//Field Two		0	79	119	82	1	TRUE	FALSE	FALSE	FALSE
//Field Three	121	79	119	82	4	FALSE	TRUE	FALSE	FALSE
//Field Four	0	163	240	77	13	TRUE	TRUE	FALSE	TRUE

class ScreenLayout extends ScreenLayoutCommon {

	function initialize() {
		ScreenLayoutCommon.initialize();
		System.println(">ScreenLayout:initialize [round]");
	}
	
	
	const WIDTH= 240;
	const HEIGHT = 240;

//	const TOP_H = 79;
//	const MIDDLE_H = 142 - TOP_H;
//	const LOWER_H = HEIGHT - (TOP_H + MIDDLE_H);
	
	
	
	const VCENTER = WIDTH/2;
	const MINI_W =  32;
	const MINI_H = 36;
	const MINI_X = VCENTER - MINI_W /2;
	const MINI_Y = 0;
	

	var first = true;
	var h;
	var w;
	var cx;
	
	var tinyh;
	
	var rowh;
	
	var row0y = 0;
	var row1y;
	var row2y;
	var row3y;
	var row4y;
	var row5y;
	var row6y;
	
	var colw;
	var col0;
	var col1;
	var col2;
	
	var tlxc;
	var tlyc;
	var trxc;
	var tryc;

	var smlxc;
	var smlyc;
	var smmxc;
	var smmyc;
	var smrxc;
	var smryc;

	var imlxc;
	var imlyc;
	var immxc;
	var immyc;
	var imrxc;
	var imryc;

	var lmlxc;
	var lmlyc;
	var lmmxc;
	var lmmyc;
	var lmrxc;
	var lmryc;

	var blxc;
	var blyc;
	var brxc;
	var bryc;
	var bxc;
	var byc;
	var bw;

	var tlxc_bg;
	var tlyc_bg;
	var tlyw_bg;
	var trxc_bg;
	var tryc_bg;
	var tryw_bg;

	var smlxc_bg;
	var smlyc_bg;
	var smlyw_bg;
	var smmxc_bg;
	var smmyc_bg;
	var smmyw_bg;
	var smrxc_bg;
	var smryc_bg;
	var smryw_bg;

	var imlxc_bg;
	var imlyc_bg;
	var imlyw_bg;
	var immxc_bg;
	var immyc_bg;
	var immyw_bg;
	var imrxc_bg;
	var imryc_bg;
	var imryw_bg;

	var lmlxc_bg;
	var lmlyc_bg;
	var lmlyw_bg;
	var lmmxc_bg;
	var lmmyc_bg;
	var lmmyw_bg;
	var lmrxc_bg;
	var lmryc_bg;
	var lmryw_bg;

	var blxc_bg;
	var blyc_bg;
	var blyw_bg;
	var brxc_bg;
	var bryc_bg;
	var bryw_bg;
	
	var bxc_bg;
	var byc_bg;
	var byw_bg;

	var bigw;
	
	var head_tail_font;
	
	function init(dc) {
	
		head_tail_font = Graphics.FONT_MEDIUM;
		h = dc.getHeight(); 
//		System.println("h " + h);
		w = dc.getWidth(); 
//		System.println("w " + w);
		cx = w/2;
//		h = System.getDeviceSettings().screenHeight; 
//		w = System.getDeviceSettings().screenWidth; 
		
		first=false;
		
		//tinyh = dc.getFontHeight(Graphics.FONT_XTINY); //#!JFS£#
		tinyh = dc.getFontHeight(head_tail_font);
//		System.println("tinyh " + tinyh);
		rowh = (h-(2*tinyh))/5; 

		row0y = tinyh / 2;
//		System.println("rowh " + rowh);
		row1y = tinyh;
//		System.println("row1y " + row1y);
		row2y = row1y + rowh;
//		System.println("row2y " + row2y);
		row3y = row2y + rowh;
//		System.println("row3y " + row3y);
		row4y = row3y + rowh;
//		System.println("row4y " + row4y);
		row5y = row4y + rowh;
//		System.println("row4y " + row4y);
		row6y = row5y + rowh;
//		System.println("row4y " + row4y);

		colw = w/3;
		col0=0;
		col1=colw;
		col2=col1+colw;	 
		
		bigw = colw + (cx-colw)/2; //add in half the cut off area
		
		tlxc = bigw/2 + (cx-bigw);
		tlyc = row1y+rowh/2;
		tlxc_bg = 0;
		tlyc_bg = row1y;
		tlyw_bg = cx;

		trxc = w - tlxc;
		tryc = row1y+rowh/2;
		trxc_bg = cx;
		tryc_bg = row1y;
		tryw_bg = cx;
		
		smlxc = colw/2 + 2; //#!JFS#!;
		smlyc = row2y+rowh/2;
		smlxc_bg = 0;
		smlyc_bg = row2y;
		smlyw_bg = colw;
		
		smmxc = colw/2 + colw;
		smmyc = row2y+rowh/2;
		smmxc_bg = colw;
		smmyc_bg = row2y;
		smmyw_bg = colw;
		
		smrxc = colw/2 + colw*2  - 5; //#!JFS#!;
		smryc = row2y+rowh/2;
		smrxc_bg = colw*2;
		smryc_bg = row2y;
		smryw_bg = colw;

		imlxc = colw/2  + 2; //#!JFS#!;
		imlyc = row3y+rowh/2;
		imlxc_bg = 0;
		imlyc_bg = row3y;
		imlyw_bg = colw;
		
		immxc = colw/2 + colw;
		immyc = row3y+rowh/2;
		immxc_bg = colw;
		immyc_bg = row3y;
		immyw_bg = colw;
		
		imrxc = colw/2 + colw*2 - 5; //#!JFS#!;
		imryc = row3y+rowh/2;
		imrxc_bg = colw*2;
		imryc_bg = row3y;
		imryw_bg = colw;

		lmlxc = colw/2  + 2; //#!JFS#!;
		lmlyc = row4y+rowh/2;
		lmlxc_bg = 0;
		lmlyc_bg = row4y;
		lmlyw_bg = colw;
		
		lmmxc = colw/2 + colw;
		lmmyc = row4y+rowh/2;
		lmmxc_bg = colw;
		lmmyc_bg = row4y;
		lmmyw_bg = colw;
		
		lmrxc = colw/2 + colw*2 - 5; //#!JFS#!;
		lmryc = row4y+rowh/2;
		lmrxc_bg = colw*2;
		lmryc_bg = row4y;
		lmryw_bg = colw;

		blxc = bigw/2 + (cx-bigw);
		blyc = row5y+rowh/2;
		blxc_bg = 0;
		blyc_bg = row5y;
		blyw_bg = cx;

		brxc = w - tlxc;
		bryc = row5y+rowh/2;
		brxc_bg = cx;
		bryc_bg = row5y;
		bryw_bg = cx;

		//bottom full width
		bxc = cx;
		byc = row6y+rowh/2;
		bxc_bg = 0;
		byc_bg = row6y;
		byw_bg = w;
		bw = w - (w * 18 / 100); //about 18% narrower
	}
	
	function DisplayData(dc, BgColorFG) {
	
		if(first) {
			init(dc);
		}
		
		if(banner != null) {
	//		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        	dc.drawText(w/2, h/2, Graphics.FONT_SMALL,  banner, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        	return;
		}
		//drawLine(x1, y1, x2, y2)
		//Draw horizontal lines
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0,   row1y,  w, row1y);
        dc.drawLine(0,   row2y,  w, row2y);
        dc.drawLine(0,   row3y,  w, row3y);
        dc.drawLine(0,   row4y,  w, row4y);
        dc.drawLine(0,   row5y,  w, row5y);
        dc.drawLine(0,   row6y,  w, row6y);

		//draw center line for row one
        dc.drawLine(cx,   row1y,  cx, row2y);
        if(varB == null) {
        	//draw center line for row 4
	        dc.drawLine(cx,   row5y,  cx, row6y);
		}
		
		//draw vertical line
        dc.drawLine(col1,   row2y,  col1, row5y);
        dc.drawLine(col2,   row2y,  col2, row5y);


		drawTextbg(dc, posHead, 0, 0, w, rowh);
		drawText(dc, posHead, cx, row0y, w, rowh);

		//top
		drawTextbg(dc, posTL, tlxc_bg, tlyc_bg, tlyw_bg, rowh);
		drawText(dc, posTL, tlxc, tlyc, bigw, rowh);

        drawTextbg(dc, posTR, trxc_bg, tryc_bg, tryw_bg, rowh);
        drawText(dc, posTR, trxc, tryc, bigw, rowh);
		
		//superior middle
        drawTextbg(dc, posSML, smlxc_bg, smlyc_bg, smlyw_bg, rowh);
        drawText(dc, posSML, smlxc, smlyc, colw, rowh);

        drawTextbg(dc, posSMM, smmxc_bg, smmyc_bg, smmyw_bg, rowh);
        drawText(dc, posSMM, smmxc, smmyc, colw, rowh);

        drawTextbg(dc, posSMR, smrxc_bg, smryc_bg, smryw_bg, rowh);
        drawText(dc, posSMR, smrxc, smryc, colw, rowh);

		//inferior middle
        drawTextbg(dc, posIML, imlxc_bg, imlyc_bg, imlyw_bg, rowh);
        drawText(dc, posIML, imlxc, imlyc, colw, rowh);

        drawTextbg(dc, posIMM, immxc_bg, immyc_bg, immyw_bg, rowh);
        drawText(dc, posIMM, immxc, immyc, colw, rowh);

        drawTextbg(dc, posIMR, imrxc_bg, imryc_bg, imryw_bg, rowh);
        drawText(dc, posIMR, imrxc, imryc, colw, rowh);

		//lower middle
        drawTextbg(dc, posLML, lmlxc_bg, lmlyc_bg, lmlyw_bg, rowh);
        drawText(dc, posLML, lmlxc, lmlyc, colw, rowh);

        drawTextbg(dc, posLMM, lmmxc_bg, lmmyc_bg, lmmyw_bg, rowh);
        drawText(dc, posLMM, lmmxc, lmmyc, colw, rowh);

        drawTextbg(dc, posLMR, lmrxc_bg, lmryc_bg, lmryw_bg, rowh);
        drawText(dc, posLMR, lmrxc, lmryc, colw, rowh);

		drawTextbg(dc, posBL, blxc_bg, blyc_bg, blyw_bg, rowh);
		drawText(dc, posBL, blxc, blyc, bigw, rowh);

		drawTextbg(dc, posBR, brxc_bg, bryc_bg, bryw_bg, rowh);
		drawText(dc, posBR, brxc, bryc, bigw, rowh);

		//tail

		//drawTextbg(dc, posTail, bxc_bg, byc_bg, byw_bg, rowh);
		//drawText(dc, posTail, bxc, byc, bigw, rowh);

		drawTextbg(dc, posTail, bxc_bg, byc_bg, byw_bg, rowh);
		drawText(dc, posTail, bxc, byc, bigw, rowh);

		/*
		dc.setColor(ColorFGTailBG, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, row6y, w, tinyh+2);
        dc.setColor(ColorFGTailFG, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, row6y, head_tail_font, varTail, Graphics.TEXT_JUSTIFY_CENTER);
*/
    }


/* debug layout
	var colorList = [		
Graphics.COLOR_LT_GRAY ,
Graphics.COLOR_DK_GRAY ,
Graphics.COLOR_RED ,
Graphics.COLOR_DK_RED ,
Graphics.COLOR_ORANGE ,
Graphics.COLOR_YELLOW ,
Graphics.COLOR_GREEN ,
Graphics.COLOR_DK_GREEN ,
Graphics.COLOR_BLUE ,
Graphics.COLOR_DK_BLUE ,
Graphics.COLOR_PURPLE ,
Graphics.COLOR_PINK ,
	];

	function drawTextbg(dc, pos, bgx, bgy, bgw, bgh) {

		var i = pos % colorList.size();

		dc.setColor(colorList[i], Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(bgx+1, bgy+1, bgw-1, bgh-1);
	}
*/


	function drawTextbg(dc, pos, bgx, bgy, bgw, bgh) {

		if(screenData.screenFields != null && screenData.screenFields.size() > pos && screenData.screenFields[pos] != null) {
			var bgSym = screenData.screenFields[pos][:background] as Lang.Symbol;

			if(screenData has bgSym) {

				var bg = screenData[bgSym]; //use a symbol like an array reference to get the data out of the object screenData. Idea copied from ActiveLook
				if(bg != Graphics.COLOR_TRANSPARENT) {
					dc.setColor(bg.toNumber(), Graphics.COLOR_TRANSPARENT);
					dc.fillRectangle(bgx+1, bgy+1, bgw-1, bgh-1);
				}
			}
		}
	}

	
	function drawText(dc, pos, x, y, w, h) {

		var oops = null;
		if(screenData.screenFields != null && screenData.screenFields.size() > pos && screenData.screenFields[pos] != null) {
			var bgSym = screenData.screenFields[pos][:background] as Lang.Symbol;
			var isNumSym = screenData.screenFields[pos][:isNum] as Lang.Symbol;
			var valSym = screenData.screenFields[pos][:val] as Lang.Symbol;
			var name = screenData.screenFields[pos][:name] as Lang.String;


			if(screenData has bgSym && screenData has isNumSym && screenData has valSym) {

				var bg = screenData[bgSym]; //use a symbol like an array reference to get the data out of the object screenData. Idea copied from ActiveLook
				var isNum = screenData[isNumSym]; //use a symbol like an array reference to get the data out of the object screenData. Idea copied from ActiveLook
				var val = screenData[valSym]; //use a symbol like an array reference to get the data out of the object screenData. Idea copied from ActiveLook
				//var name = screenData[nameSym]; //use a symbol like an array reference to get the data out of the object screenData. Idea copied from ActiveLook
				//System.println("display[" + pos + "], name [" + name + "] value [" + val + "]");

				var fg = foregroundForBackground(bg);

				if(val == null) {
					val = "-";
					isNum = true;
				}

				//val = "XXX"; //uncomment to debug laout
				dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
				dc.drawText(x, y, getFont(dc, val, isNum, w, h), val, Graphics.TEXT_JUSTIFY_CENTER |Graphics.TEXT_JUSTIFY_VCENTER);
			} else {
				
				if(!(screenData has valSym)) {
					System.println("display[" + pos + "] screenData lacks val symbol for " + name);
				}
				if(!(screenData has bgSym)) {
					System.println("display[" + pos + "] screenData lacks bg symbol for " + name);
				}
				if(!(screenData has isNumSym)) {
					System.println("display[" + pos + "] screenData lacks isNum symbol for " + name);
				}
				
				oops = "Oops1";
			}
		} else {
			System.println("display[" + pos + "] no entry");
			oops = "Oops2";
		}

		if(oops != null) {
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_WHITE);
			var avar = oops;
			var isNum = false;
			dc.drawText(x, y, getFont(dc, avar, isNum, w, h), avar, Graphics.TEXT_JUSTIFY_CENTER |Graphics.TEXT_JUSTIFY_VCENTER);
		}
	}

	function foregroundForBackground(bg) {
		var red = (bg & 0xFF0000) >> 16;
		var green = (bg & 0x00FF00) >> 8;
		var blue = (bg & 0xFF);
		var total = red + blue + green;
		//3*127=381
		if(total > 381) {
			return Graphics.COLOR_BLACK;
		} else {
			return Graphics.COLOR_WHITE;
		}
	}

	//https://developer.garmin.com/connect-iq/reference-guides/devices-reference/#f%C4%93nix%C2%AE5xtactix%C2%AEcharlie
	//https://developer.garmin.com/connect-iq/user-experience-guidelines/fenix-2022/ 
//Font Symbol					Font Face			Font Size (pixels high?) 	Font
//FONT_XTINY					Roboto Condensed	26	FENIX5_ROBOTOCONDENSEDREGULAR_26PX
//FONT_TINY						Roboto Condensed	26	FENIX5_ROBOTOCONDENSEDBOLD_26PX
//FONT_SMALL					Roboto Condensed	29	FENIX5_ROBOTOCONDENSEDBOLD_29PX
//FONT_MEDIUM					Roboto Condensed	34	FENIX5_ROBOTOCONDENSEDBOLD_34PX
//FONT_LARGE					Roboto Condensed	37	FENIX5_ROBOTOCONDENSEDBOLD_37PX

//FONT_NUMBER_MILD				Chronos				26	FENIX5_CHRONOSSEMIBOLDCONDENSED_26PX
//FONT_NUMBER_MEDIUM			Chronos				36	FENIX5_CHRONOSSEMIBOLDCONDENSED_36PX
//FONT_NUMBER_HOT				Chronos				52	FENIX5_CHRONOSSEMIBOLDCONDENSED_52PX
//FONT_NUMBER_THAI_HOT			Chronos				58	FENIX5_CHRONOSSEMIBOLDCONDENSED_58PX

//FONT_SYSTEM_XTINY				Roboto Condensed	26	FENIX5_ROBOTOCONDENSEDREGULAR_26PX
//FONT_SYSTEM_TINY				Roboto Condensed	26	FENIX5_ROBOTOCONDENSEDBOLD_26PX
//FONT_SYSTEM_SMALL				Roboto Condensed	29	FENIX5_ROBOTOCONDENSEDBOLD_29PX
//FONT_SYSTEM_MEDIUM			Roboto Condensed	34	FENIX5_ROBOTOCONDENSEDBOLD_34PX
//FONT_SYSTEM_LARGE				Roboto Condensed	37	FENIX5_ROBOTOCONDENSEDBOLD_37PX

//FONT_SYSTEM_NUMBER_MILD		Chronos				26	FENIX5_CHRONOSSEMIBOLDCONDENSED_26PX
//FONT_SYSTEM_NUMBER_MEDIUM		Chronos				36	FENIX5_CHRONOSSEMIBOLDCONDENSED_36PX
//FONT_SYSTEM_NUMBER_HOT		Chronos				52	FENIX5_CHRONOSSEMIBOLDCONDENSED_52PX
//FONT_SYSTEM_NUMBER_THAI_HOT	Chronos				58	FENIX5_CHRONOSSEMIBOLDCONDENSED_58PX

	function getFont(dc, msg, isNum, width, height) {
	
		//The [width, height] of the String in pixels
		
		var use_number_fonts = false;
		msg = msg.toString();
		if(isNum && use_number_fonts ) {
	
			var size;

/*
			size = dc.getTextDimensions(msg, Graphics.FONT_NUMBER_THAI_HOT);
			System.println("FONT_NUMBER_THAI_HOT: " + msg + ", h " + size[1] + ", w " + size[0] + ", h " + height + ", w " + width);
			if(size[0] <= width && size[1] <= height) {
				return Graphics.FONT_NUMBER_THAI_HOT;
			}
			*/
			size = dc.getTextDimensions(msg, Graphics.FONT_NUMBER_HOT);
			//System.println("FONT_NUMBER_HOT: " + msg + ", h " + size[1] + ", w " + size[0] + ", h " + height + ", w " + width);
			if(size[0] <= width && size[1] <= height) {
				return Graphics.FONT_NUMBER_HOT;
			}
			size = dc.getTextDimensions(msg, Graphics.FONT_NUMBER_MEDIUM);
			//System.println("FONT_NUMBER_MEDIUM: " + msg + ", h " + size[1] + ", w " + size[0] + ", h " + height + ", w " + width);
			if(size[0] <= width && size[1] <= height) {
				return Graphics.FONT_NUMBER_MEDIUM;
			}
			size = dc.getTextDimensions(msg, Graphics.FONT_NUMBER_MILD);
			//System.println("FONT_NUMBER_MILD: " + msg + ", h " + size[1] + ", w " + size[0] + ", h " + height + ", w " + width);
			if(size[0] <= width && size[1] < height) {
				return Graphics.FONT_NUMBER_MILD;
			}
			return Graphics.FONT_XTINY;
		} else {
			var size;
			size = dc.getTextDimensions(msg, Graphics.FONT_LARGE);
			//System.println("FONT_LARGE: " + msg + ", h " + size[1] + ", w " + size[0] + ", h " + height + ", w " + width);
			if(size[0] <= width && size[1] <= height) {
				return Graphics.FONT_LARGE;
			}
			size = dc.getTextDimensions(msg, Graphics.FONT_MEDIUM);
			//System.println("FONT_MEDIUM: " + msg + ", h " + size[1] + ", w " + size[0] + ", h " + height + ", w " + width);
			if(size[0] <= width && size[1] <= height) {
				return Graphics.FONT_MEDIUM;
			}
			
			size = dc.getTextDimensions(msg, Graphics.FONT_SMALL);
			//System.println("FONT_SMALL: " + msg + ", h " + size[1] + ", w " + size[0] + ", h " + height + ", w " + width);
			if(size[0] <= width && size[1] < height) {
				return Graphics.FONT_SMALL;
			}
			size = dc.getTextDimensions(msg, Graphics.FONT_TINY);
			//System.println("FONT_TINY: " + msg + ", h " + size[1] + ", w " + size[0] + ", h " + height + ", w " + width);
			if(size[0] <= width && size[1] < height) {
				return Graphics.FONT_TINY;
			}
			return Graphics.FONT_XTINY;
		}		
	}

}
