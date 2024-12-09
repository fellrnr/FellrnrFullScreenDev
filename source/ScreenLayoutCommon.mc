using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
import Toybox.Lang;

class ScreenLayoutCommon {

/*
	typedef FieldData as {
		var data,
		var isNum,
		var bgColor,
		var fgColor,
	};
*/

	const ENTRIES = 15;

	var screenData = new ScreenData();

	//var dc;
	var banner = null;

	const posHead = 0;
	const posTL = 1;
	const posTR = 2;
	const posSML = 3;
	const posSMM = 4;
	const posSMR = 5;
	const posIML = 6;
	const posIMM = 7;
	const posIMR = 8;
	const posLML = 9;
	const posLMM = 10;
	const posLMR = 11;
	const posBL =  12;
	const posBR =  13;
	const posTail = 14;

	var varB = null;

/*

	var varTL = "";
	var varTR = "";
	var varSML = "";
	var varSMM = "";
	var varSMR = "";
	var varIML = "";
	var varIMM = "";
	var varIMR = "";
	var varLML = "";
	var varLMM = "";
	var varLMR = "";
	var varBL = "";
	var varBR = "";
	
	var isNumTL = true;
	var isNumTR = true;
	var isNumSML = true;
	var isNumSMM = true;
	var isNumSMR = true;
	var isNumIML = true;
	var isNumIMM = true;
	var isNumIMR = true;
	var isNumLML = true;
	var isNumLMM = true;
	var isNumLMR = true;
	var isNumBL = true;
	var isNumBR = true;
	var isNumB = true;
	var isNumTail = true;
	
	
	var varHead = "";
	var varTail = "";
	
	var ColorHeadFG = Graphics.COLOR_WHITE;
	var ColorHeadBG = Graphics.COLOR_WHITE;
	
	var ColorFGVarTL = Graphics.COLOR_BLACK;
	var ColorFGVarTR = Graphics.COLOR_BLACK;

	var ColorFGVarSML = Graphics.COLOR_BLACK;
	var ColorFGVarSMM = Graphics.COLOR_BLACK;
	var ColorFGVarSMR = Graphics.COLOR_BLACK;
	var ColorFGVarIML = Graphics.COLOR_BLACK;
	var ColorFGVarIMM = Graphics.COLOR_BLACK;
	var ColorFGVarIMR = Graphics.COLOR_BLACK;
	var ColorFGVarLML = Graphics.COLOR_BLACK;
	var ColorFGVarLMM = Graphics.COLOR_BLACK;
	var ColorFGVarLMR = Graphics.COLOR_BLACK;


	var ColorFGVarBL = Graphics.COLOR_BLACK;
	var ColorFGVarBR = Graphics.COLOR_BLACK;
	var ColorFGVarB = Graphics.COLOR_BLACK;
	var ColorFGVarTail = Graphics.COLOR_BLACK;

	var ColorBGVarTL = Graphics.COLOR_WHITE;
	var ColorBGVarTR = Graphics.COLOR_WHITE;
	var ColorBGVarSML = Graphics.COLOR_WHITE;
	var ColorBGVarSMM = Graphics.COLOR_WHITE;
	var ColorBGVarSMR = Graphics.COLOR_WHITE;
	var ColorBGVarIML = Graphics.COLOR_WHITE;
	var ColorBGVarIMM = Graphics.COLOR_WHITE;
	var ColorBGVarIMR = Graphics.COLOR_WHITE;
	var ColorBGVarLML = Graphics.COLOR_WHITE;
	var ColorBGVarLMM = Graphics.COLOR_WHITE;
	var ColorBGVarLMR = Graphics.COLOR_WHITE;
	var ColorBGVarBL = Graphics.COLOR_WHITE;
	var ColorBGVarBR = Graphics.COLOR_WHITE;
	var ColorBGVarB = Graphics.COLOR_WHITE;
	var ColorBGVarTail = Graphics.COLOR_WHITE;


	var ColorFGTailFG = Graphics.COLOR_BLACK;
	var ColorFGTailBG = Graphics.COLOR_YELLOW;
*/
	function initialize() {
	}

}
