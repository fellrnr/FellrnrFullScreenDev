# FellrnrFullScreen
Full Screen Connect IQ Data Field

This field can optionally  store power from Stryd as native power for use in Strava, but without the extra FIT data that the Stryd data field stores (and causes problems). There is also the option to store CORE fields from the CORE sensor. 

This is a high data density data field, leaving no room for titles on each field. You can configure which fields are shown using a comma seperated list. There is an excel spreadsheet in the github source code for building the list. 

The default is "ca,hrP,hr,pwr,pac,dis,tAD,gAP,dF,sL,aP,g,alt,dEl,ts". Most of the values should be obvious. 

-        "ca" => "cadence", 
-		"hrP" => "hrPwr",			//See https://fellrnr.com/wiki/HrPwr
-		"hr" => "heartRate",
-		"pwr" => "power",
-		"pac" => "pace",
-		"oP" => "opPace",			//pace in min/km for imperial, min/mile for metric (see pace in the other unit's system)
-		"alt" => "altitude",
-		"dEl" => "deltaElevation", 	//Rate of change of elevation in meters per minute
-		"eT" => "elapsedTime",
-		"cT" => "clockTime",
-		"ts" => "times",			//Alternate between elapsed and clock time
-		"gAP" => "GAP",				//See https://fellrnr.com/wiki/Grade_Adjusted_Pace
-		"g" => "grade",
-		"tA" => "totalAscent",
-		"tD" => "totalDescent",
-		"uD" => "upDown",			//Alternating total ascent and descent
-		"dis" => "dist",
-		"aP" => "averagePace",
-		"dR" => "distLeft",			//If you have a route or a segement, this will be the remaining distance
-		"sL" => "strideLen",
-		"sP" => "smoothPace",
-		"cC" => "cadiacCost",
-		"dF" => "dutyFactor",		//The percent of time your feet are in contact with the ground
-		"sO" => "stanceOcc",		//The vertical occelation when your feet are in contact with the ground
-		"vO" => "vertOsc",
-		"gCT" => "grndConTime",
-		"cTp" => "coreTemp",		//From CORE sensor
-		"sTp" => "skinTemp",		//From CORE sensor
-		"aTp" => "allTemp",			//From CORE sensor, alternating core, skin, Heat Strain Index
-		"ht" => "heat",				//From CORE sensor, showing core temp until HSI is >= 1.0 when HSI is shown (Future mod is to make changeover HSI configurable, and maybe only show core temp when HSI is zero)

The data fields is at https://apps.garmin.com/apps/913d78c5-9eb7-43e9-ad04-0e13bb6e9882
The source code is at https://github.com/fellrnr/FellrnrFullScreen
