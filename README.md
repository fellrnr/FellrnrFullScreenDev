# FellrnrFullScreen
Full Screen Connect IQ Data Field

This is a high data density data field, leaving no room for titles on each field. You can configure which fields are shown using a comma seperated list. 

The default is "ca,hrP,hr,pwr,pac,dis,tAD,gAP,dF,sL,aP,g,alt,dEl,ts". Most of the values should be obvious. 

- "ca" => "cadence"
- "hrP" => "hrPwr" See https://fellrnr.com/wiki/HrPwr
- "hr" => "heartRate"
- "pwr" => "power"
- "pac" => "currentPace"
- "alt" => "altitude"
- "dEl" => "deltaElevation" Rate of change of elevation in meters per minute
- "eT" => "elapsedTime"
- "cT" => "clockTime"
- "ts" => "times" Alternate between elapsed and clock time
- "gAP" => "gradeAdjustedPace" See https://fellrnr.com/wiki/Grade_Adjusted_Pace
- "g" => "grade"
- "tA" => "totalAscent"
- "tD" => "totalDescent"
- "tAD" => "totalAscentDescent"
- "dis" => "distanceDisplay"
- "aP" => "averagePace"
- "dR" => "distanceRemaining" If you have a route or a segement, this will be the remaining distance
- "sL" => "strideLength"
- "sP" => "smoothPace"
- "cC" => "cadiacCost" 
- "dF" => "dutyFactor" The percent of time your feet are in contact with the ground
- "sO" => "stanceOccelation" The vertical occelation when your feet are in contact with the ground
- "vO" => "verticalOscillationMM"
- "gCT" => "groundContactTimeMs"
