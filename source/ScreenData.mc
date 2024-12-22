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
	var d_oppositePace = null;
	var d_averagePace = null;
	var d_distanceRemaining = null;
	var d_strideLength = null;
    var d_smoothPace=0;
	var d_cadiacCost = null;
	var d_cardiacCostIsNum = false;
	var d_dutyFactor = null;
	var d_dutyFactorBG = Graphics.COLOR_WHITE;
	var d_stanceOccelation = null;
	var d_verticalOscillationMM = null;
	var d_groundContactTimeMs = null;
	var d_coreTemperature = null;
	var d_skinTemperature = null;
	var d_allTemperature = null;
	var d_allTemperatureBG = Graphics.COLOR_WHITE;
	var d_heatStrainIndex = null;
	var d_heatStrainIndexBG = Graphics.COLOR_WHITE;
	var d_heat = null;
	var d_heatBG = Graphics.COLOR_WHITE;

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
		"pace" => { :name => "pace", :val => :d_currentPace, :background => :defaultBG, :isNum => :defaultIsNum },
		"opPace" => { :name => "opPace", :val => :d_oppositePace, :background => :defaultBG, :isNum => :defaultIsNum },
		"altitude" => { :name => "altitude", :val => :d_altitude, :background => :defaultBG, :isNum => :defaultIsNum },
		"deltaElevation" => { :name => "deltaElevation", :val => :d_deltaElevation, :background  => :defaultBG, :isNum => :defaultIsNum },

		"elapsedTime" => { :name => "elapsedTime", :val => :d_elapsedTime, :background  => :defaultBG, :isNum => :defaultIsNum },
		"clockTime" => { :name => "clockTime", :val => :d_clockTime, :background  => :defaultBG, :isNum => :defaultIsNum },
		"times" => { :name => "times", :val => :d_times, :background  => :d_timesBG, :isNum => :defaultIsNum },

		"GAP" => { :name => "GAP", :val => :d_gradeAdjustedPace, :background  => :defaultBG, :isNum => :defaultIsNum },
		"grade" => { :name => "grade", :val => :d_grade, :background  => :defaultBG, :isNum => :defaultIsNum },
		"totalAscent" => { :name => "totalAscent", :val => :d_totalAscent, :background => :defaultBG, :isNum => :defaultIsNum },
		"totalDescent" => { :name => "totalDescent", :val => :d_totalDescent, :background => :defaultBG, :isNum => :defaultIsNum },
		"upDown" => { :name => "upDown", :val => :d_totalAscentDescent, :background => :d_totalAscentDescentBG, :isNum => :defaultIsNum },
		"dist" => { :name => "dist", :val => :d_distanceDisplay, :background => :defaultBG, :isNum => :defaultIsNum },
		"averagePace" => { :name => "averagePace", :val => :d_averagePace, :background => :defaultBG, :isNum => :defaultIsNum },
		"distLeft" => { :name => "distLeft", :val => :d_distanceRemaining, :background => :defaultBG, :isNum => :defaultIsNum },
		"strideLen" => { :name => "strideLen", :val => :d_strideLength, :background => :defaultBG, :isNum => :defaultIsNum },
		"smoothPace" => { :name => "smoothPace", :val => :d_smoothPace, :background => :defaultBG, :isNum => :defaultIsNum },
		"cadiacCost" => { :name => "cadiacCost", :val => :d_cadiacCost, :background => :defaultBG, :isNum => :d_cardiacCostIsNum },
		"dutyFactor" => { :name => "dutyFactor", :val => :d_dutyFactor, :background => :d_dutyFactorBG, :isNum => :defaultIsNum },
		"stanceOcc" => { :name => "stanceOcc", :val => :d_stanceOccelation, :background => :defaultBG, :isNum => :defaultIsNum },
		"vertOsc" => { :name => "vertOsc", :val => :d_verticalOscillationMM, :background => :defaultBG, :isNum => :defaultIsNum },
		"grndConTime" => { :name => "grndConTime", :val => :d_groundContactTimeMs, :background => :defaultBG, :isNum => :defaultIsNum },

		"coreTemp" => { :name => "coreTemp", :val => :d_coreTemperature, :background => :defaultBG, :isNum => :defaultIsNum },
		"skinTemp" => { :name => "skinTemp", :val => :d_skinTemperature, :background => :defaultBG, :isNum => :defaultIsNum },
		"allTemp" => { :name => "allTemp", :val => :d_allTemperature, :background => :d_allTemperatureBG, :isNum => :defaultIsNum },
		"heatStrainIndex" => { :name => "heatStrainIndex", :val => :d_heatStrainIndex, :background => :d_heatStrainIndexBG, :isNum => :defaultIsNum },
		"heat" => { :name => "heat", :val => :d_heat, :background => :d_heatBG, :isNum => :defaultIsNum },
		//"grndConTime" => { :name => "grndConTime", :val => :d_groundContactTimeMs, :background => :defaultBG, :isNum => :defaultIsNum },

	};

    const abbreviations = {
        "ca" => "cadence", 
		"hrP" => "hrPwr",			//See https://fellrnr.com/wiki/HrPwr
		"hr" => "heartRate",
		"pwr" => "power",
		"pac" => "pace",
		"oP" => "opPace",			//pace in min/km for imperial, min/mile for metric (see pace in the other unit's system)
		"alt" => "altitude",
		"dEl" => "deltaElevation", 	//Rate of change of elevation in meters per minute
		"eT" => "elapsedTime",
		"cT" => "clockTime",
		"ts" => "times",			//Alternate between elapsed and clock time
		"gAP" => "GAP",				//See https://fellrnr.com/wiki/Grade_Adjusted_Pace
		"g" => "grade",
		"tA" => "totalAscent",
		"tD" => "totalDescent",
		"uD" => "upDown",			//Alternating total ascent and descent
		"dis" => "dist",
		"aP" => "averagePace",
		"dR" => "distLeft",			//If you have a route or a segement, this will be the remaining distance
		"sL" => "strideLen",
		"sP" => "smoothPace",
		"cC" => "cadiacCost",
		"dF" => "dutyFactor",		//The percent of time your feet are in contact with the ground
		"sO" => "stanceOcc",		//The vertical occelation when your feet are in contact with the ground
		"vO" => "vertOsc",
		"gCT" => "grndConTime",
		"cTp" => "coreTemp",		//From CORE sensor
		"sTp" => "skinTemp",		//From CORE sensor
		"aTp" => "allTemp",			//From CORE sensor, alternating core, skin, Heat Strain Index
		"ht" => "heat",				//From CORE sensor, showing core temp until HSI is >= 1.0 when HSI is shown (Future mod is to make changeover HSI configurable, and maybe only show core temp when HSI is zero)
    };


	var fieldTitles = null;
	var badFieldWarning = "Not Found";
	var badField as FieldDatum = {:name => "Bad Field", :val => :badFieldWarning, :background  => :defaultBG, :isNum => :defaultIsNum };

    var screenConfig; // = "ca,hrP,hr,pwr,pac,dis,tAD,gAP,dF,sL,aP,g,alt,dEl,ts";
    //var screenConfig = "cadence,hrPwr,heartRate,power,currentPace,distanceDisplay,totalAscentDescent,gradeAdjustedPace,dutyFactor,strideLen,averagePace,grade,altitude,deltaElevation,times";

	var screenFields = null as Lang.Array<FieldDatum>;

	//need alternating and fall back (e.g. distance remaining goes to grade)
	function mapDisplayFields() {

        if(screenConfig == null || screenConfig.length() == 0) {
            return;
        }


        var fields = [] as Lang.Array<Lang.String>;
        while (screenConfig.length() > 0) {
            var splitPoint = screenConfig.find(",") as Lang.Number or Null;
            var nibble = splitPoint == null ? screenConfig : screenConfig.substring(0, splitPoint);
            fields.add(nibble);
            screenConfig = splitPoint == null ? "" : screenConfig.substring(splitPoint + 1, screenConfig.length());
            //System.println("found nibble [" + nibble + "] remainder " + screenConfig);
        }


		var total = fields.size() < ScreenLayoutCommon.ENTRIES ? fields.size() : ScreenLayoutCommon.ENTRIES;
		screenFields = new[total];
        fieldTitles = new[total];
		for (var i = 0; i < total; i++) {

			var name = fields[i];
            if(abbreviations.hasKey(name)) {
                name = abbreviations[name];
			}

			if(fieldData.hasKey(name)) {
				screenFields[i] = fieldData[name];
				fieldTitles[i] = name.substring(0, 5);
				System.println("map display[" + i + "] is " + name);
			} else {
                System.println("map display[" + i + "] could not find " + name);
				fieldTitles[i] = "BAD:" + name.substring(0, 5);
                screenFields[i] = badField;
			}

        }
    }

}
