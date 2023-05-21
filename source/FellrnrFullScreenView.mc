using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Attention;
using Toybox.Time;
using Toybox.Time.Gregorian;


//http://patorjk.com/software/taag/#p=display&c=c%2B%2B&f=Big&t=Debug
//see google docs

//rolling averages
// https://stackoverflow.com/questions/10990618/calculate-rolling-moving-average-in-c/10990656#10990656
// https://stackoverflow.com/questions/12636613/how-to-calculate-moving-average-without-keeping-the-count-and-data-total


//altitude updates
//https://forums.garmin.com/developer/connect-iq/f/discussion/5868/gradient-algorithm

//The CIQ_LOG.txt will be in \garmin\apps\logs.


//note: removed all race pacing/prediction code, but it's in github

//note this is under the connect iq	 account

class FellrnrFullScreenView extends WatchUi.DataField {


    hidden var pwr;
	var calcpwr=0;
    hidden var hr;
    hidden var hrpwr;

	var weight;
	var rhr;
	var MaxHR;
	
	var hrpwrlabel;
	var display;
    var mBgColorFG;

	var ZeroPowerHR;
	var HrPwrSmoothing;
	var PaceSmoothing;
	var HrPwrDelay;
	var DisplayLoop;
	var MinPower;
	
	var StartingElevation = 0;
	var ElevationDelta;
	var simple;
    var unitP                        = 1000.0;
    var unitE                        = 1000.0;
    var elapsedTime = 0;
    
    var pwrdelay;
    var smoothhr=0;
    var smoothpwr=0;
    var smoothpace=0;
    var SmoothPaceCounter=0;
    var SmoothHrPwrCounter=0;
    var alertcount=0;
    const ALERT_FREQUENCY=15;
    var alertinterval=ALERT_FREQUENCY;
    var sequence=0;
    var loop=0;

	var cardiacCost=0;
	var gradeAdjustedSpeed=0;
	var gradeAdjustedCardiacCost=0;

	hidden var pwrField;
	hidden var shrpwrField;
	var strideLengthField;
	var gacardiacCostField;

	var RemaininDistanceInUnits="";
	var FinishTimeOfDay = "";
	var TimeRemainingString = "";
	var EstimatedFinishTimeSmoothed = "";
	var EstimatedFinishTimeAverage = "";
	var EstimatedDistanceSmoothed = "";
	var EstimatedDistanceAverage = "";

	var elevationarray;

	var hrZones = null;

    function onTimerReset() {
		StartingElevation = 0;
    	SmoothPaceCounter=0;
    	SmoothHrPwrCounter=0;
	}	
	
    function onTimerStart() {
		StartingElevation = 0;
    	SmoothPaceCounter=0;
    	SmoothHrPwrCounter=0;
	    pwrdelay = null;
	    smoothhr=0;
	    smoothpwr=0;
    }

    function onTimerPause () {
	    pwrdelay = null;
    	SmoothPaceCounter=0;
    	SmoothHrPwrCounter=0;
	    smoothhr=0;
	    smoothpwr=0;
	}	

    function onTimerResume() {
	    pwrdelay = null;
    	SmoothPaceCounter=0;
    	SmoothHrPwrCounter=0;
	    smoothhr=0;
	    smoothpwr=0;
	}	

    function onTimerStop() {
	    pwrdelay = null;
    	SmoothPaceCounter=0;
    	SmoothHrPwrCounter=0;
	    smoothhr=0;
	    smoothpwr=0;
	}	

	
//  _                 
// | |                
// | |     __ _ _ __  
// | |    / _` | '_ \ 
// | |___| (_| | |_) |
// |______\__,_| .__/ 
//             | |    
//             |_|    
	//calculate avg lap, std dev, corrected dist
	var distancecorrection=0;
	var distanceatlastlap=0;
	var lapmsgtime=0;
	var TotalLapNormalized=0;
	var TotalLapCount=0;
	var AverageLap=1.0;
	var LapStandardDeviation=0;
	var LapList = new [0];
	function onTimerLap() {
	}
	

    function initialize() {
	        DataField.initialize();
	        
	        hrpwr = -10;
	        
	        var profile = UserProfile.getProfile();
	        weight = profile.weight / 1000.0; //grams to Kg
	        hrZones = profile.getHeartRateZones(profile.getCurrentSport());
	        MaxHR = hrZones[5];
	        //weight = weight.toLong(); 
	        rhr = profile.restingHeartRate;


	        if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
	            unitP = 1609.344;
	            unitE = 3.2808;
	        }
	        
	        
			var mApp = Application.getApp();
	        ZeroPowerHR = mApp.getProperty("ZeroPowerHR");
			HrPwrSmoothing = mApp.getProperty("HrPwrSmoothing").toFloat();
			PaceSmoothing = mApp.getProperty("PaceSmoothing").toFloat();
			HrPwrDelay = mApp.getProperty("HrPwrDelay");
			DisplayLoop = mApp.getProperty("DisplayLoop");
			MinPower = mApp.getProperty("MinPower");

	System.println("ZeroPowerHR:        " + ZeroPowerHR);
	System.println("HrPwrSmoothing:     " + HrPwrSmoothing);
	System.println("PaceSmoothing:      " + PaceSmoothing);
	System.println("HrPwrDelay:         " + HrPwrDelay);
	System.println("DisplayLoop:        " + DisplayLoop);
	System.println("MinPower:           " + MinPower);

	
	        hrpwrlabel = "" + ZeroPowerHR.format("%d") + ":" + weight.format("%d") + "";
	        
	        display = new ScreenLayout(); //governed by monkey.jungle
	        
//	        pwrField = createField("pwr", 0, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"N" });

	        pwrField = createField("Fellrnr_FS_power", 0, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
			shrpwrField = createField("Fellrnr_FS_hrpwr", 1, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
			strideLengthField = createField("Fellrnr_FS_stride_length", 2, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
			gacardiacCostField = createField("Fellrnr_FS_cardic_distance", 3, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
	        
	        pwrField.setData(0.0);
			shrpwrField.setData(0.0);
			strideLengthField.setData(0.0); 
			gacardiacCostField.setData(0.0); 
	        
	}

	function setupField(session) {
	}

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
    	//System.println(">FellrnrFullScreenView:onLayout");
    
        var obscurityFlags = DataField.getObscurityFlags();
        simple = true;

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
        	simple = false;
            View.setLayout(Rez.Layouts.MainLayout(dc));
            //View.setLayout(Rez.Layouts.ComplexLayout(dc));
            
        }

		if(simple) {
	        View.findDrawableById("label").setText(Rez.Strings.label + label);
        }
    	//System.println("<FellrnrFullScreenView:onLayout");
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    // This method is called once per second
    function compute(info) {

//  ____                                  
// |  _ \                                 
// | |_) | __ _ _ __  _ __   ___ _ __ ___ 
// |  _ < / _` | '_ \| '_ \ / _ \ '__/ __|
// | |_) | (_| | | | | | | |  __/ |  \__ \
// |____/ \__,_|_| |_|_| |_|\___|_|  |___/
//                                        
  
		//Pause = auto pause
		/*
		if(info.timerState == Activity.TIMER_STATE_PAUSED || info.timerState == Activity.TIMER_STATE_STOPPED) {
			display.banner = 
				"m last l  " + distanceatlastlap.format("%.1f") + "\n" +
				"m " + info.elapsedDistance.format("%.1f") + "\n" +
				"Avg: " + AverageLap.format("%.4f") + "\n" +
				"correction " + distancecorrection.format("%.1f") + "\n" + 
				"sd " + LapStandardDeviation.format("%.4f");
			return;
		}
		if(lapmsgtime == 0) {
			display.banner = null;
		} else {
			lapmsgtime--;
		}
*/
		sequence++;
		loop = ((sequence / DisplayLoop) % 2) == 0;

                                         

	 	display.varB = null; 
	 	display.isNumB = true;


//  _______    _ _            _______ _                     
// |__   __|  (_) |          |__   __(_)                    
//    | | __ _ _| |  ______     | |   _ _ __ ___   ___  ___ 
//    | |/ _` | | | |______|    | |  | | '_ ` _ \ / _ \/ __|
//    | | (_| | | |             | |  | | | | | | |  __/\__ \
//    |_|\__,_|_|_|             |_|  |_|_| |_| |_|\___||___/
//                                                          
// 
		
		//tail
		if(loop) {
			var myTime = System.getClockTime(); // ClockTime object
			display.varTail = "T" + myTime.hour.format("%02d") + ":" + myTime.min.format("%02d"); // + ":" + myTime.sec.format("%02d");
			display.ColorFGTailBG = Graphics.COLOR_TRANSPARENT;
			display.ColorFGTailFG = Graphics.COLOR_BLACK;
		} else {
			var ElapsedSeconds = info.timerTime / 1000.0;
			display.varTail = "E" + fmtTime(ElapsedSeconds);
			display.ColorFGTailBG = Graphics.COLOR_BLACK;
			display.ColorFGTailFG = Graphics.COLOR_WHITE;
		} 
		
		
		pwr = 0;
		hr = 0;

		var alert = null;
		//cadence
		

//  _    _                _             _____          _                     
// | |  | |              | |           / ____|        | |                    
// | |__| | ___  __ _  __| |  ______  | |     __ _  __| | ___ _ __   ___ ___ 
// |  __  |/ _ \/ _` |/ _` | |______| | |    / _` |/ _` |/ _ \ '_ \ / __/ _ \
// | |  | |  __/ (_| | (_| |          | |___| (_| | (_| |  __/ | | | (_|  __/
// |_|  |_|\___|\__,_|\__,_|           \_____\__,_|\__,_|\___|_| |_|\___\___|
//                                                                           
		if(info.currentCadence  == 0 || info.currentCadence == null) {
			display.ColorHeadBG = Graphics.COLOR_TRANSPARENT;
			display.ColorHeadFG = Graphics.COLOR_BLACK;
			display.varHead = "-";
		} else  {
			display.varHead = info.currentCadence;
			if(info.currentCadence  < 150){ //walking
				display.ColorHeadBG = Graphics.COLOR_BLUE;
				alertcount=0;
			} else if(info.currentCadence  < 176){ 
				display.ColorHeadBG = Graphics.COLOR_DK_RED;
				alert = Attention.TONE_ALERT_LO;
			} else if(info.currentCadence  < 178) {
				display.ColorHeadBG = Graphics.COLOR_ORANGE;
				alert = Attention.TONE_KEY;
			} else if(info.currentCadence  < 180){ 
				display.ColorHeadBG = Graphics.COLOR_YELLOW;
				alert = Attention.TONE_MSG;
			} else if(info.currentCadence  < 182){ 
				display.ColorHeadBG = Graphics.COLOR_DK_GREEN;
				alertcount=0;
			} else { //> 184
				display.ColorHeadBG = Graphics.COLOR_PURPLE;
				alertcount=0;
			}

			display.ColorHeadFG = Graphics.COLOR_BLACK;

			alertinterval--;
			if (alert != null && alertcount < 30 && alertinterval==0 && Attention has :playTone) {
 				  //Attention.playTone(alert);
 				  alertcount++;
 				  alertinterval=ALERT_FREQUENCY;
			}
		}


//  ____  _____             _____       _ _                   _ _   _ _             _      
// |  _ \|  __ \           |  __ \     | | |            /\   | | | (_) |           | |     
// | |_) | |__) |  ______  | |  | | ___| | |_ __ _     /  \  | | |_ _| |_ _   _  __| | ___ 
// |  _ <|  _  /  |______| | |  | |/ _ \ | __/ _` |   / /\ \ | | __| | __| | | |/ _` |/ _ \
// | |_) | | \ \           | |__| |  __/ | || (_| |  / ____ \| | |_| | |_| |_| | (_| |  __/
// |____/|_|  \_\          |_____/ \___|_|\__\__,_| /_/    \_\_|\__|_|\__|\__,_|\__,_|\___|
//                                                                                         

//GAP relies on changeinelevation, so this first

		var changeinelevation = 0; 


		if(info.altitude != null && info.altitude != 0) {  //improbable we're actually exactly at sea level

			if(elevationarray == null) {
				elevationarray = new [60];
				for (var i = 0; i < elevationarray.size(); i++) {
					elevationarray[i] = info.altitude;
				}
			}
			changeinelevation = info.altitude - elevationarray[0]; 
			display.varBR = "Δ" + changeinelevation.format("%.1f");

			//fifo
			elevationarray = elevationarray.slice(1, null);
			elevationarray.add(info.altitude);
		} else {
			display.varBR = "!Alt";
		}



//  _____ __  __ __  __    _____               _                    _ _           _           _   _____               
// |_   _|  \/  |  \/  |  / ____|             | |          /\      | (_)         | |         | | |  __ \              
//   | | | \  / | \  / | | |  __ _ __ __ _  __| | ___     /  \   __| |_ _   _ ___| |_ ___  __| | | |__) |_ _  ___ ___ 
//   | | | |\/| | |\/| | | | |_ | '__/ _` |/ _` |/ _ \   / /\ \ / _` | | | | / __| __/ _ \/ _` | |  ___/ _` |/ __/ _ \
//  _| |_| |  | | |  | | | |__| | | | (_| | (_| |  __/  / ____ \ (_| | | |_| \__ \ ||  __/ (_| | | |  | (_| | (_|  __/
// |_____|_|  |_|_|  |_|  \_____|_|  \__,_|\__,_|\___| /_/    \_\__,_| |\__,_|___/\__\___|\__,_| |_|   \__,_|\___\___|
//                                                                  _/ |                                              
//                                                                 |__/                                               
//https://journals.physiology.org/doi/full/10.1152/japplphysiol.01177.2001
//NOTE: other fields rely on the GAP
		var grade = 0;
		if(info.currentSpeed != null && info.currentSpeed > 0) {
			var hspeed = info.currentSpeed;
			var vspeed = changeinelevation / 60.0; //mps
			var incline = vspeed / hspeed; 
			grade = incline * 100;


			//Update to use something closer to Strava's formula
			//Cri  155.4i^5 - 30.4i^4 - 43.3i^3 + 46.3i^2 + 19.5i + 3.6
			//var cost = (0 - Math.pow(incline, 5) * 155.4 - Math.pow(incline, 4) * 30.4 - Math.pow(incline, 3) * 43.3 + Math.pow(incline, 2) * 46.3 + incline * 19.5 + 3.6) / 3.6;
			////double cost = Math.Pow(slope, 2) * 15.14 + slope * 2.896 + 1.0098;
			if(incline > 0.5) {
				incline = 0.5;
			}
			if(incline < -0.5) {
				incline = -0.5;
			}
				
			var cost = Math.pow(incline, 2) * 15.14 + incline * 2.896 + 1;
			//System.println("cost " + cost + ", incline " + incline + ", incline^2 " + Math.pow(incline, 2) );

			gradeAdjustedSpeed = hspeed * cost;

			  
			display.varIMM = fmtPace(gradeAdjustedSpeed);
        	display.ColorFGVarIMM = Graphics.COLOR_BLACK;

		} else {
			display.varIMM = "!hspeed";
			gradeAdjustedSpeed = 0;
		}



//  _______ _____             _    _                 _     _____       _       
// |__   __|  __ \           | |  | |               | |   |  __ \     | |      
//    | |  | |__) |  ______  | |__| | ___  __ _ _ __| |_  | |__) |__ _| |_ ___ 
//    | |  |  _  /  |______| |  __  |/ _ \/ _` | '__| __| |  _  // _` | __/ _ \
//    | |  | | \ \           | |  | |  __/ (_| | |  | |_  | | \ \ (_| | ||  __/
//    |_|  |_|  \_\          |_|  |_|\___|\__,_|_|   \__| |_|  \_\__,_|\__\___|
//                                                                             
                                                                             
		
		//Just HR
		if(info.currentHeartRate == 0 || info.currentHeartRate == null) {
			display.varTR = "No HR";
			display.isNumTR = false;
			hr=0;
		} else  {
			hr = info.currentHeartRate;
			display.varTR = hr;
			display.ColorBGVarTR = GetPolHrColor(hr);
			display.ColorFGVarTR = Graphics.COLOR_BLACK;
			display.isNumTR = true;
		}


//  __  __ _                 _____                       
// |  \/  | |               |  __ \                      
// | \  / | |       ______  | |__) |____      _____ _ __ 
// | |\/| | |      |______| |  ___/ _ \ \ /\ / / _ \ '__|
// | |  | | |____           | |  | (_) \ V  V /  __/ |   
// |_|  |_|______|          |_|   \___/ \_/\_/ \___|_|   
//                                                       
//                                                       

		//Calcualted Power 
		calcpwr=0;
		if(info.currentSpeed != null && info.currentSpeed > 0) {
			//power is about speed (m/s) * weight (kg) * 1.04;
			calcpwr = gradeAdjustedSpeed * weight * 1.04;
			pwrField.setData(calcpwr.toFloat());
		}

		if(info.currentPower != 0 && info.currentPower != null) {
			pwr = info.currentPower;
			//var wpkg = pwr / weight;
			
			if(loop) {
				display.varSML = pwr.format("%d");
	            display.ColorBGVarSML = Graphics.COLOR_WHITE;
	            display.ColorFGVarSML = Graphics.COLOR_BLACK;
			} else {
				display.varSML = calcpwr.format("%.1f");
	            display.ColorBGVarSML = Graphics.COLOR_BLACK;
	            display.ColorFGVarSML = Graphics.COLOR_WHITE;
			}
            display.isNumSML = true;
        } else {

			display.varSML = calcpwr.format("%.1f");
			display.ColorFGVarSML = Graphics.COLOR_BLACK;
			display.ColorBGVarSML = Graphics.COLOR_WHITE;
            display.isNumSML = true;
			pwr = calcpwr; //default to calc as the best we can do
		}


//  _______ _                 _    _      _____                
// |__   __| |               | |  | |    |  __ \               
//    | |  | |       ______  | |__| |_ __| |__) |_      ___ __ 
//    | |  | |      |______| |  __  | '__|  ___/\ \ /\ / / '__|
//    | |  | |____           | |  | | |  | |     \ V  V /| |   
//    |_|  |______|          |_|  |_|_|  |_|      \_/\_/ |_|   
//                                                             
                                                             

		//HR-PWR
	    display.varTL = "-";
	    if(hr != 0 && pwr != 0) {
			if(info.currentHeartRate <= ZeroPowerHR) {
				display.varTL = "HR < 0pHR";
	            display.isNumTL = false;
			} else {
	            display.isNumTL = true;

				if(pwrdelay == null) {
					pwrdelay = new [0];
					smoothhr = hr.toFloat();
					smoothpwr = pwr.toFloat();
					SmoothHrPwrCounter=0;
				}

				pwrField.setData(pwr.toFloat());
				if(pwr > MinPower) {
					pwrdelay.add(pwr);
				}
				if(pwrdelay.size() > HrPwrDelay) {
				
					if(SmoothHrPwrCounter < HrPwrSmoothing) {
						SmoothHrPwrCounter++;
					}
					var delayedpwr = pwrdelay[0].toFloat();
					pwrdelay = pwrdelay.slice(1, null);
					
					smoothhr = (smoothhr*(SmoothHrPwrCounter-1.0)/SmoothHrPwrCounter) + hr.toFloat()/SmoothHrPwrCounter;
					smoothpwr = (smoothpwr*(SmoothHrPwrCounter-1.0)/SmoothHrPwrCounter) + delayedpwr/SmoothHrPwrCounter;
					
					//System.println("HR " + hr + " old HR " + delayedpwr + " smoothhr " + smoothhr); 
				
					var pwrMw = smoothpwr * 1000.0;
			        var pwkg = (pwrMw / weight);
			        var deltahr = (smoothhr - ZeroPowerHR);
			        var hrpw = pwkg / deltahr;
			        var hrpw1dp = Math.round(hrpw*10)/10.0;
		    	    hrpwr = hrpw1dp;

					//Calculate instantanious HrPwr
					// var pwrMwInst = pwr * 1000.0;
			        // var pwkgInst = (pwrMwInst / weight);
			        // var deltahrInst = (hr - ZeroPowerHR);
			        // var hrpwInst = pwkgInst / deltahrInst;
			        // var hrpw1dpInst = Math.round(hrpwInst*10)/10.0;
		    	    // var hrpwrInst = hrpw1dpInst;


					//Garmin keeps reseting max hr, making percent HRR useless

					display.varTL = hrpwr.format("%.1f");
					display.ColorFGVarTL = Graphics.COLOR_WHITE;
					display.ColorBGVarTL = GetHrPwrColor(hrpwr);
					display.ColorFGVarTL = Graphics.COLOR_BLACK;
		    	    
					shrpwrField.setData(hrpwr.toFloat());
				} else {
		            display.isNumTL = false;
					display.varTL = "Wait";
				}	    	    
			}
	    }






//  ____  _                          _                    _ _   _ _             _      
// |  _ \| |                   /\   | |             /\   | | | (_) |           | |     
// | |_) | |       ______     /  \  | |__  ___     /  \  | | |_ _| |_ _   _  __| | ___ 
// |  _ <| |      |______|   / /\ \ | '_ \/ __|   / /\ \ | | __| | __| | | |/ _` |/ _ \
// | |_) | |____            / ____ \| |_) \__ \  / ____ \| | |_| | |_| |_| | (_| |  __/
// |____/|______|          /_/    \_\_.__/|___/ /_/    \_\_|\__|_|\__|\__,_|\__,_|\___|
//                                                                                     
                                                                                     
		if(info.altitude != null) {
			display.varBL = "@" +  info.altitude.format("%.0f");
		} else {
			display.varBL = "!Alt";
		}

		

//  _____ __  __ _                 _____ __  __ _____     _____                      _       _   _                      _ _   _ _             _      
// |_   _|  \/  | |        ___    |_   _|  \/  |  __ \   / ____|                    | |     | | (_)               /\   | | | (_) |           | |     
//   | | | \  / | |       ( _ )     | | | \  / | |__) | | |    _   _ _ __ ___  _   _| | __ _| |_ ___   _____     /  \  | | |_ _| |_ _   _  __| | ___ 
//   | | | |\/| | |       / _ \/\   | | | |\/| |  _  /  | |   | | | | '_ ` _ \| | | | |/ _` | __| \ \ / / _ \   / /\ \ | | __| | __| | | |/ _` |/ _ \
//  _| |_| |  | | |____  | (_>  <  _| |_| |  | | | \ \  | |___| |_| | | | | | | |_| | | (_| | |_| |\ V /  __/  / ____ \| | |_| | |_| |_| | (_| |  __/
// |_____|_|  |_|______|  \___/\/ |_____|_|  |_|_|  \_\  \_____\__,_|_| |_| |_|\__,_|_|\__,_|\__|_| \_/ \___| /_/    \_\_|\__|_|\__|\__,_|\__,_|\___|
//                                                                                                                                                   

		if(loop) {
			if(info.totalAscent != null) {
				display.varIML = "+" +  info.totalAscent.format("%.0f");
			} else {
				display.varIML = "zero";
			}
		} else {
			if(info.totalDescent != null) {
				display.varIML = "-" + info.totalDescent.format("%.0f");
			} else {
				display.varIML = "zero";
			}
		}		
		


//  __  __ _____             _____  _     _                       
// |  \/  |  __ \           |  __ \(_)   | |                      
// | \  / | |__) |  ______  | |  | |_ ___| |_ __ _ _ __   ___ ___ 
// | |\/| |  _  /  |______| | |  | | / __| __/ _` | '_ \ / __/ _ \
// | |  | | | \ \           | |__| | \__ \ || (_| | | | | (_|  __/
// |_|  |_|_|  \_\          |_____/|_|___/\__\__,_|_| |_|\___\___|
//                                                                
      
		if(info.elapsedDistance != null) {
			var distance; 
			if(!loop && distancecorrection.abs() > 50) {
				distance = info.elapsedDistance - distancecorrection;
                display.ColorFGVarSMR = Graphics.COLOR_WHITE;
                display.ColorBGVarSMR = Graphics.COLOR_BLACK;
			} else {
				distance = info.elapsedDistance;
                display.ColorFGVarSMR = Graphics.COLOR_BLACK;
                display.ColorBGVarSMR = Graphics.COLOR_WHITE;
			}
			distance = distance / unitP;
			
			display.varSMR = distance.format("%.2f");
			if(distance < 100.0) {
				display.varSMR = distance.format("%.2f");
			} else {
				display.varSMR = distance.format("%.1f");
			}
            display.isNumSMR = true;
		} else {
			display.varSMR = "-";
            display.isNumSMR = false;
		}


//Used to calcualte time delta for race pacing - see version history


//  __  __ __  __            _____               
// |  \/  |  \/  |          |  __ \              
// | \  / | \  / |  ______  | |__) |_ _  ___ ___ 
// | |\/| | |\/| | |______| |  ___/ _` |/ __/ _ \
// | |  | | |  | |          | |  | (_| | (_|  __/
// |_|  |_|_|  |_|          |_|   \__,_|\___\___|
                                               
                                               


	    if(info.currentSpeed != null && info.currentSpeed > 0) {
			display.varSMM = fmtPace(info.currentSpeed*AverageLap);
            display.ColorBGVarSMM = Graphics.COLOR_WHITE;
            display.ColorFGVarSMM = Graphics.COLOR_BLACK;

		} else {
            display.ColorFGVarSMM = Graphics.COLOR_BLACK;
            display.ColorBGVarSMM = Graphics.COLOR_WHITE;
			display.varSMM = "-:--";
		}
		
		

//    _      __  __                                           _____               
//   | |    |  \/  |     /\                                  |  __ \              
//   | |    | \  / |    /  \__   _____ _ __ __ _  __ _  ___  | |__) |_ _  ___ ___ 
//   | |    | |\/| |   / /\ \ \ / / _ \ '__/ _` |/ _` |/ _ \ |  ___/ _` |/ __/ _ \
//   | |____| |  | |  / ____ \ V /  __/ | | (_| | (_| |  __/ | |  | (_| | (_|  __/
//   |______|_|  |_| /_/    \_\_/ \___|_|  \__,_|\__, |\___| |_|   \__,_|\___\___|
//                                                __/ |                           
//                                               |___/                            
                		
	    if(info.averageSpeed != null && info.averageSpeed > 0) {
				display.varLMM = fmtPace(info.averageSpeed);
		} else {
			display.varLMM = "-:--";
		}
        display.ColorFGVarLMM = Graphics.COLOR_BLACK;
        display.ColorBGVarLMM = Graphics.COLOR_WHITE;


//    _      _____    _____  _     _                         _____                      _       _                         _____               _      
//   | |    |  __ \  |  __ \(_)   | |                       |  __ \                    (_)     (_)               ___     / ____|             | |     
//   | |    | |__) | | |  | |_ ___| |_ __ _ _ __   ___ ___  | |__) |___ _ __ ___   __ _ _ _ __  _ _ __   __ _   ( _ )   | |  __ _ __ __ _  __| | ___ 
//   | |    |  _  /  | |  | | / __| __/ _` | '_ \ / __/ _ \ |  _  // _ \ '_ ` _ \ / _` | | '_ \| | '_ \ / _` |  / _ \/\ | | |_ | '__/ _` |/ _` |/ _ \
//   | |____| | \ \  | |__| | \__ \ || (_| | | | | (_|  __/ | | \ \  __/ | | | | | (_| | | | | | | | | | (_| | | (_>  < | |__| | | | (_| | (_| |  __/
//   |______|_|  \_\ |_____/|_|___/\__\__,_|_| |_|\___\___| |_|  \_\___|_| |_| |_|\__,_|_|_| |_|_|_| |_|\__, |  \___/\/  \_____|_|  \__,_|\__,_|\___|
//                                                                                                       __/ |                                       
//                                                                                                      |___/                                        

	    if(info.distanceToDestination  != null && info.distanceToDestination  > 0) {

			var distance; 
			distance = info.distanceToDestination / unitP;

			display.varLMR = distance.format("%.2f");
			if(distance < 100.0) {
				display.varLMR = distance.format("%.2f");
			} else {
				display.varLMR = distance.format("%.1f");
			}
            display.isNumLMR = true;

		} else {
			display.varLMR = grade.format("%.1f") + "%";
			
		}
		

		


//  _      _                  _____ _        _     _        _                      _   _     
// | |    | |                / ____| |      (_)   | |      | |                    | | | |    
// | |    | |       ______  | (___ | |_ _ __ _  __| | ___  | |     ___ _ __   __ _| |_| |__  
// | |    | |      |______|  \___ \| __| '__| |/ _` |/ _ \ | |    / _ \ '_ \ / _` | __| '_ \ 
// | |____| |____            ____) | |_| |  | | (_| |  __/ | |___|  __/ | | | (_| | |_| | | |
// |______|______|          |_____/ \__|_|  |_|\__,_|\___| |______\___|_| |_|\__, |\__|_| |_|
//                                                                            __/ |          
//                                                                           |___/           

		if(info.currentCadence == null || info.currentCadence  == 0 || info.currentSpeed == null || info.currentSpeed == 0) {
			display.varLML = "-.--";
			strideLengthField.setData(0.0); 
		} else {
			var stridelength = (info.currentSpeed * 60) / info.currentCadence;
			display.varLML = stridelength.format("%.2f");
			strideLengthField.setData(stridelength); 
		}


//    _____        _          ______ _      _     _    _____                       _   _              _   _____               
//   |  __ \      | |        |  ____(_)    | |   | |  / ____|                     | | | |            | | |  __ \              
//   | |  | | __ _| |_ __ _  | |__   _  ___| | __| | | (___  _ __ ___   ___   ___ | |_| |__   ___  __| | | |__) |_ _  ___ ___ 
//   | |  | |/ _` | __/ _` | |  __| | |/ _ \ |/ _` |  \___ \| '_ ` _ \ / _ \ / _ \| __| '_ \ / _ \/ _` | |  ___/ _` |/ __/ _ \
//   | |__| | (_| | || (_| | | |    | |  __/ | (_| |  ____) | | | | | | (_) | (_) | |_| | | |  __/ (_| | | |  | (_| | (_|  __/
//   |_____/ \__,_|\__\__,_| |_|    |_|\___|_|\__,_| |_____/|_| |_| |_|\___/ \___/ \__|_| |_|\___|\__,_| |_|   \__,_|\___\___|
//                                                                                                                            
//                                                                                                                            

	    if(info.currentSpeed != null && info.currentSpeed > 0) {
			var realPace = info.currentSpeed*AverageLap;

			if(smoothpace == 0) {
				smoothpace = info.currentSpeed;
			}
			if(SmoothPaceCounter < PaceSmoothing) {
				SmoothPaceCounter++;
			}
			smoothpace = (smoothpace*(SmoothPaceCounter-1)/SmoothPaceCounter) + realPace/SmoothPaceCounter;
			//System.println("smoothpace " +  smoothpace.format("%.2f") +", currentSpeed " +  info.currentSpeed.format("%.2f") +", SmoothPaceCounter " +  SmoothPaceCounter);  

		}

/*
//  _____        _          ______ _      _     _             _____              _ _               _____          _   
// |  __ \      | |        |  ____(_)    | |   | |           / ____|            | (_)             / ____|        | |  
// | |  | | __ _| |_ __ _  | |__   _  ___| | __| |  ______  | |     __ _ _ __ __| |_  __ _  ___  | |     ___  ___| |_ 
// | |  | |/ _` | __/ _` | |  __| | |/ _ \ |/ _` | |______| | |    / _` | '__/ _` | |/ _` |/ __| | |    / _ \/ __| __|
// | |__| | (_| | || (_| | | |    | |  __/ | (_| |          | |___| (_| | | | (_| | | (_| | (__  | |___| (_) \__ \ |_ 
// |_____/ \__,_|\__\__,_| |_|    |_|\___|_|\__,_|           \_____\__,_|_|  \__,_|_|\__,_|\___|  \_____\___/|___/\__|
//                                                                                                                    
     
		//cardiac cost
		if(hr != 0 && info.currentSpeed != null && info.currentSpeed != 0) {

			//from Pacing Strategy Affects the Sub-Elite Marathoner's Cardiac Drift and Performance|doi=10.3389/fpsyg.2019.03026
			//note the research paper is ambiguous about speed in meters/min or km/min, but corespondence with the author conformed meter/min
			//The current speed in meters per second (mps), so divide by 60 to get meters/min
			//"The cardiac cost (CC) (which has a unit corresponding to the amount of heartbeat by meter ran)"
			//Example: 140 @ 5:33 min/km, 140 @ 3.0 m/s, 140 @ 0.015 m/min, 140/0.015 = 9,333, 9,333/6,000 = 1.55
			var speedMetersPerMinute = info.currentSpeed / 60.0;
			cardiacCost = (info.currentHeartRate / speedMetersPerMinute) / 6000.0; 
		} else {
			cardiacCost = 0; //don't leave it as current value as this is misleading
		}
		if(hr != 0 && gradeAdjustedSpeed != 0) {
			var speedMetersPerMinute = gradeAdjustedSpeed / 60.0;
			gradeAdjustedCardiacCost = (info.currentHeartRate / speedMetersPerMinute) / 6000.0; 
		} else {
			gradeAdjustedCardiacCost = 0; //don't leave it as current value as this is misleading
		}
		cardiacCostField.setData(cardiacCost.toFloat());
		gacardiacCostField.setData(gradeAdjustedCardiacCost.toFloat());
		if(loop) {
			display.varIMR = cardiacCost.format("%.1f");
			display.ColorFGVarIMR = Graphics.COLOR_BLACK;
			display.ColorBGVarIMR = Graphics.COLOR_WHITE;
		} else {
			display.varIMR = "Δ" + gradeAdjustedCardiacCost.format("%.1f");
			display.ColorFGVarIMR = Graphics.COLOR_WHITE;
			display.ColorBGVarIMR = Graphics.COLOR_BLACK;
		}
*/
		if(hr != 0 && gradeAdjustedSpeed != 0) {
			//I'm not finding the original CC useful
			// power is about speed * weight, and HR pwr is per Kg, so simply use
			// use hr/speed (mps)
			//Example: 140 @ 5:33 min/km, 140 @ 3.0 m/s, if rest is 40 bpm, so (140-40)/3.0 is 33.3
			var deltahr = (hr - ZeroPowerHR);
			gradeAdjustedCardiacCost = (gradeAdjustedSpeed / deltahr) * 1000.0; 
		} else {
			gradeAdjustedCardiacCost = 0; //don't leave it as current value as this is misleading
		}
		gacardiacCostField.setData(gradeAdjustedCardiacCost.toFloat());
		display.varIMR = gradeAdjustedCardiacCost.format("%.1f") + "°"; //degree symbol to make it obvioius
//		display.ColorFGVarIMR = Graphics.COLOR_WHITE;
//		display.ColorBGVarIMR = Graphics.COLOR_BLACK;

    }
		


    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color (it can change)
        var BgColorFG = (getBackgroundColor() == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
    	//System.println(">FellrnrFullScreenView:onUpdate");
        
//        try {
	        if(simple) {
		        View.findDrawableById("Background").setColor(getBackgroundColor());
		
		        // Set the foreground color and value
		        var value = View.findDrawableById("value");
		        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
		            value.setColor(Graphics.COLOR_WHITE);
		        } else {
		            value.setColor(Graphics.COLOR_BLACK);
		        }
		        value.setText(hrpwr.format("%.1f"));
		        
		        //You update the view elements, then ask the view to do the update
		        View.onUpdate(dc);
				//then you can do 
		        // Call parent's onUpdate(dc) to redraw the layout
	        } else {
//	            var value;
	
				
				
				
				//Ask the view to do it's update, then we can apply our changes
		        //View.onUpdate(dc);
    			//System.println(">FellrnrFullScreenView:onUpdate->display.DisplayData");
				display.DisplayData(dc, BgColorFG);
				//System.println("display data done");
	        }
//		} catch (e instanceof Lang.Exception) {
//    		System.println("oops: " + e.getErrorMessage());
//		}
		return true;
    }



    function fmtSecs(secs) {
        if(secs > 3599) { // more than an hour
	        var hours = secs / 3600.0;
	        return hours.format("%.1f") + "h";
	        
        } else if(secs > 599) { //10 mins - an hour
	        var mins = secs / 60.0;
	        return mins.format("%.1f") + "m";
	        
        } else if(secs > 59) { //1-10 mins
	        var s = secs.toLong();
	        return (s / 60).format("%0d") + ":" + (s % 60).format("%02d");
	        
        } else { //< minute
	        return secs.format("%d");
        }
    }

    function fmtPace(secs) {
        var s = (unitP/secs).toLong();
        return (s / 60).format("%0d") + ":" + (s % 60).format("%02d");
    }

	//from flexiRunner
	function fmtTime(time) {
		var fTime = time.toLong();
        var fTimerSecs = (fTime % 60).format("%02d");
        var fTimer = (fTime / 60).format("%d") + ":" + fTimerSecs;  //! Format time as m:ss
        if (fTime > 3599) {
            //! (Re-)format time as h:mm(ss) if more than an hour
            fTimer = (fTime / 3600).format("%d") + ":" + (fTime / 60 % 60).format("%02d");
		}
		return fTimer;
	}

	function fmtTimeHMS(time) {
		var fTime = time.toLong();
        var fTimerSecs = (fTime % 60).format("%02d");
        var fTimer = (fTime / 60).format("%d") + ":" + fTimerSecs;  //! Format time as m:ss
        if (fTime > 3599) {
            //! (Re-)format time as h:mm(ss) if more than an hour
            fTimer = (fTime / 3600).format("%d") + ":" + ((fTime / 60) % 60).format("%02d") + ":" + fTimerSecs;
		}
		return fTimer;
	}




		

	

	function GetHrColor(currentHeartRate) {
		if(hrZones == null) {
			return Graphics.COLOR_WHITE;
		}

        if( currentHeartRate >= hrZones[4]) { 
        	return Graphics.COLOR_DK_RED;
		} else if( currentHeartRate >= hrZones[3]) {
			return Graphics.COLOR_ORANGE;
        } else if( currentHeartRate >= hrZones[2]) {
        	return Graphics.COLOR_DK_GREEN;
        } else if( currentHeartRate >= hrZones[1]) {
        	return Graphics.COLOR_BLUE;
        } else if( currentHeartRate >= hrZones[0]) {
        	return Graphics.COLOR_DK_GRAY;
		}
		return Graphics.COLOR_WHITE;
	}


	//polorized colors - mid HR is bad
	function GetPolHrColor(currentHeartRate) {

        if( currentHeartRate >= (MaxHR * 0.90)) { 
        	return Graphics.COLOR_PURPLE;
		} else if( currentHeartRate >= (MaxHR * 0.80)) { 
			return Graphics.COLOR_RED;
		} else if( currentHeartRate >= (MaxHR * 0.75)) { 
        	return Graphics.COLOR_YELLOW;
		} else if( currentHeartRate >= (MaxHR * 0.50)) { 
        	return Graphics.COLOR_GREEN;
		} else {
        	return Graphics.COLOR_LT_GRAY;
		}
	}

	function GetHrPwrColor(currentHrPwr) {
		if(currentHrPwr == 0) {
			return Graphics.COLOR_WHITE;
		}

        if( currentHrPwr >= 45) { 
			return Graphics.COLOR_PURPLE;
        } else if( currentHrPwr >= 40) {
        	return Graphics.COLOR_GREEN;
        } else if( currentHrPwr >= 35) {
			return Graphics.COLOR_ORANGE;
        } else if( currentHrPwr >= 30) {
        	return Graphics.COLOR_RED;
        } else if( currentHrPwr >= 25) {
        	return Graphics.COLOR_BLUE;
		} else {
			return Graphics.COLOR_LT_GRAY;
		}
	}


}
