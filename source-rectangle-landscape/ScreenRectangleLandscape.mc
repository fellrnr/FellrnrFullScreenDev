using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;

//tones - https://developer.garmin.com/downloads/connect-iq/monkey-c/doc/Toybox/Attention.html



class ScreenLayout extends ScreenLayoutCommon {

	function initialize() {
		System.println(">ScreenLayout:initialize [rectangle landscape]");
		ScreenLayoutCommon.initialize();
	}
	
	
	function DisplayData(dc, BgColour) {
        var mBgColour = (getBackgroundColor() == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;


		//System.println(">ScreenLayout:DisplayData  [rectangle landscape]");

    	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
		
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        //! Horizontal thirds
        dc.drawLine(0,   52,  215, 52);
        dc.drawLine(0,   110, 215, 110);

        //! Top vertical divider
        dc.drawLine(102, 26,  102, 53);

        //! Centre vertical dividers
        dc.drawLine(63,  53,  63,  110);
        dc.drawLine(142, 53,  142, 110);

        //! Bottom vertical divider
        dc.drawLine(102, 110, 102, 148);

        //! Top centre mini-field separator
        dc.drawRoundedRectangle(87, -10, 32, 36, 4);


		//middle left
//        dc.setColor(ColourLabelML, Graphics.COLOR_TRANSPARENT);
//        dc.fillRectangle(0, 53, 63, 17);
//
//		//middle middle
//        dc.setColor(ColourLabelMM, Graphics.COLOR_TRANSPARENT);
//        dc.fillRectangle(63, 53, 79, 17);		
//
//		//middle right
//        dc.setColor(ColourLabelMR, Graphics.COLOR_TRANSPARENT);
//        dc.fillRectangle(142, 53, 63, 17);
//
//
//        //! Set text colour
//        dc.setColor(BgColour, Graphics.COLOR_TRANSPARENT);
//
//
//        //! Top Middle
//        dc.drawText(102, 0, Graphics.FONT_SMALL, varHead, Graphics.TEXT_JUSTIFY_CENTER);
//
//		//
//        var x = 45;
//        dc.drawText(x, 32, Graphics.FONT_NUMBER_MEDIUM, varTL, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
//        dc.drawText(44, 6, Graphics.FONT_XTINY,  labelTL, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
//        
//    	dc.drawText(161, 32, Graphics.FONT_NUMBER_MEDIUM, varTR, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
//        dc.drawText(161, 6, Graphics.FONT_XTINY,  labelTR, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
//
//		//middle middle
//    	dc.drawText(102, 90, Graphics.FONT_NUMBER_MEDIUM, varMM, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
//        dc.drawText(102, 60, Graphics.FONT_XTINY,  labelMM, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
//
//        //! Centre left
//    	dc.drawText(31, 90, Graphics.FONT_NUMBER_MEDIUM, varML, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
//        dc.drawText(31, 60, Graphics.FONT_XTINY, labelML, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
//
//        //! Centre right
//    	dc.drawText(174, 90, Graphics.FONT_NUMBER_MEDIUM, varMR, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
//        dc.drawText(174, 60, Graphics.FONT_XTINY, labelMR, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
//
//		//bottom left
//	    dc.drawText(63, 130, Graphics.FONT_NUMBER_MEDIUM, varBL, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
//        dc.drawText(1, 118, Graphics.FONT_XTINY, labelBL, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
//
//        dc.drawText(142, 130, Graphics.FONT_NUMBER_MEDIUM, varBR, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
//        dc.drawText(203, 118, Graphics.FONT_XTINY, labelBR, Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
//        
    }
	
}
