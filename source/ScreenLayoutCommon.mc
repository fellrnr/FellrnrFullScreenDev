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

	var countdown = 10;

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

	function initialize() {
	}

}
