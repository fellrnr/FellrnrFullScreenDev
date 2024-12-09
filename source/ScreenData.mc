using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
import Toybox.Lang;

class ScreenData {


	var d_elapsedTime = null;
	var d_clockTime = null;
    var d_times = null;
	var d_timesBG = Graphics.COLOR_WHITE;
	var d_cadence = null;
	var d_cadenceBG = Graphics.COLOR_WHITE;
	var d_deltaElevation = null; 
	var d_gradeAdjustedPace = null;
	var d_heartRate = null;
	var d_heartRateBG = Graphics.COLOR_WHITE;
	var d_heartRateIsNum = false;
	var d_power = null;
	var d_powerBG = Graphics.COLOR_WHITE;
	var d_hrPwr = null;
	var d_hrPwrBG = Graphics.COLOR_WHITE;
	var d_hrPwrIsNum = false;
	var d_grade = null;
	var d_altitude = null;
	var d_totalAscent = null;
	var d_totalDescent = null;
	var d_totalAscentDescent = null;
	var d_totalAscentDescentBG = Graphics.COLOR_WHITE;
	var d_distanceDisplay = null;
	var d_currentPace = null;
	var d_averagePace = null;
	var d_distanceRemaining = null;
	var d_strideLength = null;
    var d_smoothPace=0;
	var d_cadiacCost = null;
	var d_cardiacCostIsNum = false;
	var d_dutyFactor = null;
	var d_stanceOccelation = null;
	var d_verticalOscillationMM = null;
	var d_groundContactTimeMs = null;

	var defaultBG = Graphics.COLOR_WHITE;
	var defaultIsNum = true;

	typedef FieldDatum as {
			:name as Lang.String,
            :val as Lang.Symbol,
            :background as Lang.Symbol,
            :isNum as Lang.Symbol,
    };

	const fieldData as Lang.Dictionary<Lang.String, FieldDatum> = {
		"cadence" => {:name => "cadence", :val => :d_cadence, :background  => :d_cadenceBG, :isNum => :defaultIsNum },
		"hrPwr" => { :name => "hrPwr", :val => :d_hrPwr, :background => :d_hrPwrBG, :isNum => :d_hrPwrIsNum },
		"heartRate" => { :name => "heartRate", :val => :d_heartRate, :background  => :d_heartRateBG, :isNum => :defaultIsNum },
		"power" => { :name => "power", :val => :d_power, :background => :d_powerBG, :isNum => :defaultIsNum },
		"currentPace" => { :name => "currentPace", :val => :d_currentPace, :background => :defaultBG, :isNum => :defaultIsNum },


		"altitude" => { :name => "altitude", :val => :d_altitude, :background => :defaultBG, :isNum => :defaultIsNum },
		"deltaElevation" => { :name => "deltaElevation", :val => :d_deltaElevation, :background  => :defaultBG, :isNum => :defaultIsNum },

		"elapsedTime" => { :name => "elapsedTime", :val => :d_elapsedTime, :background  => :defaultBG, :isNum => :defaultIsNum },
		"clockTime" => { :name => "clockTime", :val => :d_clockTime, :background  => :defaultBG, :isNum => :defaultIsNum },
		"times" => { :name => "times", :val => :d_times, :background  => :d_timesBG, :isNum => :defaultIsNum },

		"gradeAdjustedPace" => { :name => "gradeAdjustedPace", :val => :d_gradeAdjustedPace, :background  => :defaultBG, :isNum => :defaultIsNum },
		"grade" => { :name => "grade", :val => :d_grade, :background  => :defaultBG, :isNum => :defaultIsNum },
		"totalAscent" => { :name => "totalAscent", :val => :d_totalAscent, :background => :defaultBG, :isNum => :defaultIsNum },
		"totalDescent" => { :name => "totalDescent", :val => :d_totalDescent, :background => :defaultBG, :isNum => :defaultIsNum },
		"totalAscentDescent" => { :name => "totalAscentDescent", :val => :d_totalAscentDescent, :background => :d_totalAscentDescentBG, :isNum => :defaultIsNum },
		"distanceDisplay" => { :name => "distanceDisplay", :val => :d_distanceDisplay, :background => :defaultBG, :isNum => :defaultIsNum },
		"averagePace" => { :name => "averagePace", :val => :d_averagePace, :background => :defaultBG, :isNum => :defaultIsNum },
		"distanceRemaining" => { :name => "distanceRemaining", :val => :d_distanceRemaining, :background => :defaultBG, :isNum => :defaultIsNum },
		"strideLength" => { :name => "strideLength", :val => :d_strideLength, :background => :defaultBG, :isNum => :defaultIsNum },
		"smoothPace" => { :name => "smoothPace", :val => :d_smoothPace, :background => :defaultBG, :isNum => :defaultIsNum },
		"cadiacCost" => { :name => "cadiacCost", :val => :d_cadiacCost, :background => :defaultBG, :isNum => :d_cardiacCostIsNum },
		"dutyFactor" => { :name => "dutyFactor", :val => :d_dutyFactor, :background => :defaultBG, :isNum => :defaultIsNum },
		"stanceOccelation" => { :name => "stanceOccelation", :val => :d_stanceOccelation, :background => :defaultBG, :isNum => :defaultIsNum },
		"verticalOscillationMM" => { :name => "verticalOscillationMM", :val => :d_verticalOscillationMM, :background => :defaultBG, :isNum => :defaultIsNum },
		"groundContactTimeMs" => { :name => "groundContactTimeMs", :val => :d_groundContactTimeMs, :background => :defaultBG, :isNum => :defaultIsNum },

	};

	var badFieldWarning = "Not Found";
	var badField as FieldDatum = {:name => "Bad Field", :val => :badFieldWarning, :background  => :defaultBG, :isNum => :defaultIsNum };
	var screenConfig = [
            "cadence",			                //Head	1
            "hrPwr",			                //TL 	2
            "heartRate",			            //TR 	3
            "power",			                //SML 	4
            "currentPace",			            //SMM 	5
            "distanceDisplay",			        //SMR 	6
            "totalAscentDescent",   			//IML 	7
            "gradeAdjustedPace",			    //IMM 	8
            "dutyFactor",			            //IMR 	9 (was cardiac cost, then offset hr pwr)
            "strideLength",			            //LML 	10
            "averagePace",			            //LMM 	11
            "grade",			                //LMR 	12
            "altitude",			                //BL 	13
            "deltaElevation",			        //BR 	14
            "times",                			//Tail 	15

	];

    var screenConfigString = "cadence,hrPwr,heartRate,power,currentPace,distanceDisplay,totalAscentDescent,gradeAdjustedPace,dutyFactor,strideLength,averagePace,grade,altitude,deltaElevation,times";

	var screenFields = null as Lang.Array<FieldDatum>;

	//need alternating and fall back (e.g. distance remaining goes to grade)
	function mapDisplayFields() {

        if(screenConfigString == null || screenConfigString.length() == 0) {
            return;
        }


        var fields = [] as Lang.Array<Lang.String>;
        while (screenConfigString.length() > 0) {
            var splitPoint = screenConfigString.find(",") as Lang.Number or Null;
            var nibble = splitPoint == null ? screenConfigString : screenConfigString.substring(0, splitPoint);
            fields.add(nibble);
            screenConfigString = splitPoint == null ? "" : screenConfigString.substring(splitPoint + 1, screenConfigString.length());
            System.println("found nibble [" + nibble + "] remainder " + screenConfigString);
        }


		var total = fields.size() < ScreenLayoutCommon.ENTRIES ? fields.size() : ScreenLayoutCommon.ENTRIES;
		screenFields = new[total];
		for (var i = 0; i < total; i++) {

			var name = fields[i];
			if(fieldData.hasKey(name)) {
				screenFields[i] = fieldData[name];
				System.println("map display[" + i + "] is " + name);
			} else {
                System.println("map display[" + i + "] could not find " + name);
                screenFields[i] = badField;
			}

        }
    }

	function mapDisplayFieldsX() {
		var total = screenConfig.size() < ScreenLayoutCommon.ENTRIES ? screenConfig.size() : ScreenLayoutCommon.ENTRIES;
		screenFields = new[total];
		for (var i = 0; i < total; i++) {

			var name = screenConfig[i];
			if(fieldData.hasKey(name)) {
				screenFields[i] = fieldData[name];
				//System.println("map display[" + i + "] is " + name);
			} else {
                System.println("map display[" + i + "] could not find " + name);
                screenFields[i] = badField;
			}

		}
	}
}
