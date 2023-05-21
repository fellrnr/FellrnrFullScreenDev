using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;

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
		byc = row5y+rowh/2;
		bxc_bg = 0;
		byc_bg = row5y;
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



		//head
		dc.setColor(ColorHeadBG, Graphics.COLOR_TRANSPARENT);
		//drawRectangle(x, y, width, height)
        dc.fillRectangle(0, 0, w, row1y);
		dc.setColor(ColorHeadFG, Graphics.COLOR_TRANSPARENT);
		dc.drawText(cx, 0, head_tail_font, varHead, Graphics.TEXT_JUSTIFY_CENTER);



		//top
		drawTextbg(dc, ColorFGVarTL, ColorBGVarTL, tlxc_bg, tlyc_bg, tlyw_bg, rowh);
		drawText(dc, ColorFGVarTL, ColorBGVarTL, tlxc, tlyc, bigw, rowh, isNumTL, varTL);

        drawTextbg(dc, ColorFGVarTR, ColorBGVarTR, trxc_bg, tryc_bg, tryw_bg, rowh);
        drawText(dc, ColorFGVarTR, ColorBGVarTR, trxc, tryc, bigw, rowh, isNumTR, varTR);
		
		//superior middle
        drawTextbg(dc, ColorFGVarSML, ColorBGVarSML, smlxc_bg, smlyc_bg, smlyw_bg, rowh);
        drawText(dc, ColorFGVarSML, ColorBGVarSML, smlxc, smlyc, colw, rowh, isNumSML, varSML);

        drawTextbg(dc, ColorFGVarSMM, ColorBGVarSMM, smmxc_bg, smmyc_bg, smmyw_bg, rowh);
        drawText(dc, ColorFGVarSMM, ColorBGVarSMM, smmxc, smmyc, colw, rowh, isNumSMM, varSMM);

        drawTextbg(dc, ColorFGVarSMR, ColorBGVarSMR, smrxc_bg, smryc_bg, smryw_bg, rowh);
        drawText(dc, ColorFGVarSMR, ColorBGVarSMR, smrxc, smryc, colw, rowh, isNumSMR, varSMR);

		//inferior middle
        drawTextbg(dc, ColorFGVarIML, ColorBGVarIML, imlxc_bg, imlyc_bg, imlyw_bg, rowh);
        drawText(dc, ColorFGVarIML, ColorBGVarIML, imlxc, imlyc, colw, rowh, isNumIML, varIML);

        drawTextbg(dc, ColorFGVarIMM, ColorBGVarIMM, immxc_bg, immyc_bg, immyw_bg, rowh);
        drawText(dc, ColorFGVarIMM, ColorBGVarIMM, immxc, immyc, colw, rowh, isNumIMM, varIMM);

        drawTextbg(dc, ColorFGVarIMR, ColorBGVarIMR, imrxc_bg, imryc_bg, imryw_bg, rowh);
        drawText(dc, ColorFGVarIMR, ColorBGVarIMR, imrxc, imryc, colw, rowh, isNumIMR, varIMR);

		//lower middle
        drawTextbg(dc, ColorFGVarLML, ColorBGVarLML, lmlxc_bg, lmlyc_bg, lmlyw_bg, rowh);
        drawText(dc, ColorFGVarLML, ColorBGVarLML, lmlxc, lmlyc, colw, rowh, isNumLML, varLML);

        drawTextbg(dc, ColorFGVarLMM, ColorBGVarLMM, lmmxc_bg, lmmyc_bg, lmmyw_bg, rowh);
        drawText(dc, ColorFGVarLMM, ColorBGVarLMM, lmmxc, lmmyc, colw, rowh, isNumLMM, varLMM);

        drawTextbg(dc, ColorFGVarLMR, ColorBGVarLMR, lmrxc_bg, lmryc_bg, lmryw_bg, rowh);
        drawText(dc, ColorFGVarLMR, ColorBGVarLMR, lmrxc, lmryc, colw, rowh, isNumLMR, varLMR);

		//bottom
        if(varB == null) {
	        drawTextbg(dc, ColorFGVarBL, ColorBGVarBL, blxc_bg, blyc_bg, blyw_bg, rowh);
	        drawText(dc, ColorFGVarBL, ColorBGVarBL, blxc, blyc, bigw, rowh, isNumBL, varBL);
	
	        drawTextbg(dc, ColorFGVarBR, ColorBGVarBR, brxc_bg, bryc_bg, bryw_bg, rowh);
	        drawText(dc, ColorFGVarBR, ColorBGVarBR, brxc, bryc, bigw, rowh, isNumBR, varBR);
		} else {
	        drawTextbg(dc, ColorFGVarB, ColorBGVarB, bxc_bg, byc_bg, byw_bg, rowh);
	        drawText(dc, ColorFGVarB, ColorBGVarB, bxc, byc, bw, rowh, isNumB, varB);
		}
		//tail
		dc.setColor(ColorFGTailBG, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, row6y, w, tinyh+2);
        dc.setColor(ColorFGTailFG, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, row6y, head_tail_font, varTail, Graphics.TEXT_JUSTIFY_CENTER);
		
    }

	function drawTextbg(dc, fg, bg, bgx, bgy, bgw, bgh) {

        if(bg != Graphics.COLOR_TRANSPARENT) {
	        dc.setColor(bg, Graphics.COLOR_TRANSPARENT);
    	    dc.fillRectangle(bgx+1, bgy+1, bgw-1, bgh-1);
	    }
	}

	
	function drawText(dc, fg, bg, x, y, w, h, isNum, avar) {
        dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
		dc.drawText(x, y, getFont(dc, avar, isNum, w, h), avar, Graphics.TEXT_JUSTIFY_CENTER |Graphics.TEXT_JUSTIFY_VCENTER);
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
