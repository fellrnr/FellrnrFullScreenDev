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


//			cadence
//		HrPwr		HR
//	Pwr		pace		Dist
//		Delta		Elevation
//			Time



class FellrnrFullScreenView extends WatchUi.DataField {


    hidden var pwr;
    hidden var hr;
    hidden var hrpwr;

	var weight;
	var rhr;
	var MaxHR;
	
	var hrpwrlabel;
	var display;
    var mBgColorFG;

	var ZeroPowerHR;
	var TargetPower;
	var TargetPace;
	var HrPwrSmoothing;
	var PaceSmoothing;
	var HrPwrDelay;
	var PowerFactor;
	var PowerOffset;
	var DisplayLoop;
	var NormalHrPwr;
	var LapDistance;
	var PredictionTime;
	var PredictionDistance;
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

	hidden var pwrField;
	hidden var spwrField;
	hidden var shrField;
	hidden var shrpwrField;
	hidden var spaceField;
	var cardiacCostField;
	var strideLengthField;

	var RemaininDistanceInUnits="";
	var FinishTimeOfDay = "";
	var TimeRemainingString = "";
	var EstimatedFinishTimeSmoothed = "";
	var EstimatedFinishTimeAverage = "";
	var EstimatedDistanceSmoothed = "";
	var EstimatedDistanceAverage = "";

	var elevationarray;

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
		var info = Activity.getActivityInfo();

		//  _____  _     _                          _____                         _   _             
		// |  __ \(_)   | |                        / ____|                       | | (_)            
		// | |  | |_ ___| |_ __ _ _ __   ___ ___  | |     ___  _ __ _ __ ___  ___| |_ _  ___  _ __  
		// | |  | | / __| __/ _` | '_ \ / __/ _ \ | |    / _ \| '__| '__/ _ \/ __| __| |/ _ \| '_ \ 
		// | |__| | \__ \ || (_| | | | | (_|  __/ | |___| (_) | |  | | |  __/ (__| |_| | (_) | | | |
		// |_____/|_|___/\__\__,_|_| |_|\___\___|  \_____\___/|_|  |_|  \___|\___|\__|_|\___/|_| |_|
		//                                                                                          
		//  
		if(info.elapsedDistance != null) {

/*
			var cormsg = null;
			var thislapdistance = info.elapsedDistance - distanceatlastlap;
//			System.println("distanceatlastlap " + distanceatlastlap);
//			System.println("thislapdistance " + thislapdistance);
//			System.println("info.elapsedDistance " + info.elapsedDistance);
			if(thislapdistance < LapDistance * 0.25) {
//				System.println("short lap, ignore");
				distancecorrection += thislapdistance;
//				System.println("distancecorrection " + distancecorrection);
				cormsg = "Ignore. Cor " + distancecorrection.format("%.1f");
			} else if (thislapdistance > LapDistance * 0.85 &&  thislapdistance < LapDistance * 1.15) {
//				System.println("close, modify distance");
				var thiscorrection = thislapdistance - LapDistance;
				distancecorrection += thiscorrection;   
//				System.println("distancecorrection " + distancecorrection);
				cormsg = "New cor " + distancecorrection.format("%.1f");
				var LapNormalized = LapDistance / thislapdistance;
				TotalLapNormalized += LapNormalized;
				TotalLapCount++;
				LapList.add(LapNormalized);
				if(TotalLapCount > 3) {
					AverageLap = TotalLapNormalized / TotalLapCount;
					var sum=0.0;
					for( var i = 0; i < LapList.size(); i += 1 ) {
						var diff = LapList[i] - AverageLap;
						var diffsq = diff * diff;
						sum += diffsq;
					}
            		var variance = sum / (TotalLapCount - 1);
            		LapStandardDeviation = Math.sqrt(variance) * 100.0; //percent 
				} 
			} else {
//				System.println("odd lap, let it ride");
				cormsg = "no new " + distancecorrection.format("%.1f");
			}
			*/
			distanceatlastlap = info.elapsedDistance;

//			  ____                              
//			 |  _ \                             
//			 | |_) | __ _ _ __  _ __   ___ _ __ 
//			 |  _ < / _` | '_ \| '_ \ / _ \ '__|
//			 | |_) | (_| | | | | | | |  __/ |   
//			 |____/ \__,_|_| |_|_| |_|\___|_|   
//			                                    
          
			display.banner = "";
			if(EstimatedFinishTimeSmoothed.length() != 0) {
				display.banner += "ETA-S: " + EstimatedFinishTimeSmoothed + "\n";
			}
			if(EstimatedFinishTimeAverage.length() != 0) {
				display.banner += "ETA-A: " + EstimatedFinishTimeAverage + "\n";
			}
			if(EstimatedDistanceSmoothed.length() != 0 && EstimatedDistanceAverage.length() != 0) {
				display.banner += "ED: " + EstimatedDistanceSmoothed + ", A: " + EstimatedDistanceAverage + "\n";
			}

//			if(cormsg != null) {
//				display.banner += cormsg + "\n";
//			}
			if(info.averageSpeed != null) {
				display.banner += "PaceS: " + fmtPace(smoothpace*AverageLap) + "A: " + fmtPace(info.averageSpeed) + "\n";
			}
			display.banner += "Calib: " +  AverageLap.format("%.4f") + "\n";
			display.banner += "SD: " +  LapStandardDeviation.format("%.4f");
			//Fenix 5x lap display is 9 seconds, so display for 11 as a reminder and can dismis lap display to get summary
			lapmsgtime=11;
		}
	}
	

    function initialize() {
//        try {
			//System.println(">FellrnrFullScreenView:initialize");
	        DataField.initialize();
	        
	        hrpwr = -10;
	        
	        var profile = UserProfile.getProfile();
	        weight = profile.weight / 1000.0; //grams to Kg
	        var hrZones = profile.getHeartRateZones(profile.getCurrentSport());
	        MaxHR = hrZones[5];
	        //weight = weight.toLong(); 
	        rhr = profile.restingHeartRate;


	        if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
	            unitP = 1609.344;
	            unitE = 3.2808;
	        }
	        
	        
			var mApp = Application.getApp();
	        ZeroPowerHR = mApp.getProperty("ZeroPowerHR");
	        TargetPower = mApp.getProperty("TargetPower");
	        TargetPace = mApp.getProperty("TargetPace");
			HrPwrSmoothing = mApp.getProperty("HrPwrSmoothing").toFloat();
			PaceSmoothing = mApp.getProperty("PaceSmoothing").toFloat();
			HrPwrDelay = mApp.getProperty("HrPwrDelay");
			PowerFactor = mApp.getProperty("PowerFactor");
			PowerOffset = mApp.getProperty("PowerOffset");
			DisplayLoop = mApp.getProperty("DisplayLoop");
			NormalHrPwr = mApp.getProperty("NormalHrPwr");
			LapDistance = mApp.getProperty("LapDistance");
//			DoElevation = mApp.getProperty("DoElevation");
			PredictionTime = mApp.getProperty("PredictionTime");
			PredictionDistance = mApp.getProperty("PredictionDistance");
			MinPower = mApp.getProperty("MinPower");

//	System.println("ZeroPowerHR:        " + ZeroPowerHR);
//	System.println("TargetPower:        " + TargetPower);
//	System.println("TargetPace:         " + TargetPace);
//	System.println("HrPwrSmoothing:     " + HrPwrSmoothing);
//	System.println("PaceSmoothing:      " + PaceSmoothing);
//	System.println("HrPwrDelay:         " + HrPwrDelay);
//	System.println("PowerFactor:        " + PowerFactor);
//	System.println("PowerOffset:        " + PowerOffset);
//	System.println("DisplayLoop:        " + DisplayLoop);
//	System.println("NormalHrPwr:        " + NormalHrPwr);
//	System.println("LapDistance:        " + LapDistance);
//	System.println("DoElevation:        " + DoElevation);
//	System.println("PredictionTime:     " + PredictionTime);
//	System.println("PredictionDistance: " + PredictionDistance);
//	System.println("MinPower:           " + MinPower);

	
	        hrpwrlabel = "" + ZeroPowerHR.format("%d") + ":" + weight.format("%d") + "";
	        
	        display = new ScreenLayout(); //governed by monkey.jungle
	        
//	        pwrField = createField("pwr", 0, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"N" });

	        pwrField = createField("Fellrnr_FS_power", 0, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
			spwrField  = createField("Fellrnr_FS_smooth_power", 1, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
			shrField = createField("Fellrnr_FS_smooth_hr", 2, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
			shrpwrField = createField("Fellrnr_FS_hrpwr", 3, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
			spaceField = createField("fellrnr_FS_smooth_pace", 4, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
			cardiacCostField = createField("Fellrnr_FS_cardic_cost", 5, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
			strideLengthField = createField("Fellrnr_FS_stride_length", 6, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
	        
	        pwrField.setData(0.0);
			spwrField.setData(0.0);
			shrField.setData(0.0);
			shrpwrField.setData(0.0);
			spaceField.setData(0.0);
			cardiacCostField.setData(0.0); 
			strideLengthField.setData(0.0); 
	        
	        
//		} catch (e instanceof Lang.Exception) {
//    		System.println(e.getErrorMessage());
//		}	        
		//System.println("<FellrnrFullScreenView:initialize");
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
        // See Activity.Info in the documentation for available information.
//        if(info has :currentHeartRate){
//            if(info.currentHeartRate != null){
//                mValue = info.currentHeartRate;
//            } else {
//                mValue = 0.0f;
//            }
//        }

//  ____                                  
// |  _ \                                 
// | |_) | __ _ _ __  _ __   ___ _ __ ___ 
// |  _ < / _` | '_ \| '_ \ / _ \ '__/ __|
// | |_) | (_| | | | | | | |  __/ |  \__ \
// |____/ \__,_|_| |_|_| |_|\___|_|  |___/
//                                        
  
		/*
		if(info.timerState == Activity.TIMER_STATE_OFF) {
			var wpkg = TargetPower / weight;
			
			var timeofday = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
	
			var TimeOfDay = timeofday.hour + ":" + timeofday.min.format("%02d") + ":" + timeofday.sec.format("%02d");
			
			display.banner = 
						"@Pace: " + fmtPace(TargetPace) + "\n" + 
						TargetPower.format("%d") + "w/" + wpkg.format("%.1f") + "w/Kg\n" +
						"Kg: " + weight.format("%.1f") + ", mHR: " + MaxHR + "\n" + 
						"HR@0W: " + ZeroPowerHR + "\n" + 
						"Lap: " + LapDistance.format("%.2f") + "\n" +
						TimeOfDay;
// 						
//			if(info.currentHeartRate == 0 || info.currentHeartRate == null) {
//				display.banner += "\nNo HR";
//			} else  {
//				display.banner += "\n" + info.currentHeartRate;
//			}			
			return;
		}
		*/
		//Pause = auto pause
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

		sequence++;
		loop = ((sequence / DisplayLoop) % 2) == 0;

//  ____             _____              _ _      _   _                            ______ _                 _   _             
// |  _ \           |  __ \            | (_)    | | (_)                          |  ____| |               | | (_)            
// | |_) |  ______  | |__) | __ ___  __| |_  ___| |_ _  ___  _ __     ___  _ __  | |__  | | _____   ____ _| |_ _  ___  _ __  
// |  _ <  |______| |  ___/ '__/ _ \/ _` | |/ __| __| |/ _ \| '_ \   / _ \| '__| |  __| | |/ _ \ \ / / _` | __| |/ _ \| '_ \ 
// | |_) |          | |   | | |  __/ (_| | | (__| |_| | (_) | | | | | (_) | |    | |____| |  __/\ V / (_| | |_| | (_) | | | |
// |____/           |_|   |_|  \___|\__,_|_|\___|\__|_|\___/|_| |_|  \___/|_|    |______|_|\___| \_/ \__,_|\__|_|\___/|_| |_|
//           
                                         

	 	display.varB = null; 
	 	display.isNumB = true;

		racePrediction(info);
//System.println("RemaininDistanceInUnits: " + RemaininDistanceInUnits);
//System.println("FinishTimeOfDay: " + FinishTimeOfDay);
//System.println("TimeRemainingString: " + TimeRemainingString);
//System.println("EstimatedFinishTimeSmoothed: " + EstimatedFinishTimeSmoothed);
//System.println("EstimatedFinishTimeAverage: " + EstimatedFinishTimeAverage);
//System.println("EstimatedDistanceSmoothed: " + EstimatedDistanceSmoothed);
//System.println("EstimatedDistanceAverage: " + EstimatedDistanceAverage);
		
//	var FinishTimeOfDay = "";
//	var TimeRemaining = "";
	 	

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
			display.ColorHeadFG = Graphics.COLOR_WHITE;
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
			
			alertinterval--;
			if (alert != null && alertcount < 30 && alertinterval==0 && Attention has :playTone) {
 				  //Attention.playTone(alert);
 				  alertcount++;
 				  alertinterval=ALERT_FREQUENCY;
			}
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
//			if(loop) {
//				display.varTR = smoothhr.format("%.1f");
//	            display.ColorFGVarTR = Graphics.COLOR_WHITE;
//	            display.ColorBGVarTR = Graphics.COLOR_BLACK;
//			} else {
				display.varTR = hr;
	            display.ColorFGVarTR = Graphics.COLOR_BLACK;
	            display.ColorBGVarTR = Graphics.COLOR_WHITE;
//			} 
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

		//Just Power
		if(info.currentPower != 0 && info.currentPower != null) {
			pwr = info.currentPower;
			//var wpkg = pwr / weight;
			pwrField.setData(pwr.toFloat());
			
//			if(loop) {
//				display.varML = wpkg.format("%.1f");
//			} else {
				display.varSML = pwr.format("%d");
//			}
/*
            var powerDeviation = (info.currentPower - TargetPower);
            if (powerDeviation < -10 ) {
                display.ColorFGVarSML = Graphics.COLOR_DK_RED;
            } else if (powerDeviation < 10) {
                display.ColorFGVarSML = Graphics.COLOR_DK_GREEN;
            } else {  
                display.ColorFGVarSML = Graphics.COLOR_PURPLE;
            }
            */
            display.isNumSML = true;
        } else {
            display.ColorFGVarSML = Graphics.COLOR_BLACK;
			display.varSML = "No Pwr";
            display.isNumSML = false;
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
//					for(var i=0; i < HrPwrDelay; i++) {
//						pwrdelay[i] = pwr.toFloat();
//					}
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

//Garmin keeps reseting max hr, making this useless
//					var heartRateRange = MaxHR - ZeroPowerHR;
//					var heartRateReserve = deltahr / heartRateRange * 100.0;
//			        var hrpwPC = pwkg / heartRateReserve;
//			        var hrpwPC1dp = Math.round(hrpwPC*10)/10.0;
					//System.println("heartRateRange " + heartRateRange + " heartRateReserve " + heartRateReserve + " hrpwPC " + hrpwPC + " delayQ " + pwrdelay.size()); 

//		    	    if(loop) {
		    	    	display.varTL = hrpwr.format("%.1f");
//	    	    	} else {
//		    	    	display.varTL = hrpwPC1dp.format("%.1f") + "%";
//	    	    	}

//		    	    if(loop || NormalHrPwr == 0) {
//		    	    	display.varTL = hrpwr.format("%.1f");
//	    	    	} else {
//	    	    		var pc = hrpwr / NormalHrPwr * 100.0;
//						//System.println("hrpwr " + hrpwr + " NormalHrPwr " + NormalHrPwr + " pc " + pc); 
//		    	    	display.varTL = pc.format("%.0f") + "%";
//	    	    	}
		    	    
		    	    
					spwrField.setData(smoothpwr.toFloat());
					shrField.setData(smoothhr.toFloat());
					shrpwrField.setData(hrpwr.toFloat());
				} else {
		            display.isNumTL = false;
					display.varTL = "Wait";
				}	    	    
			}
	    }



//		var myTime = System.getClockTime(); // ClockTime object
//		var stamp = myTime.hour.format("%02d") + ":" + myTime.min.format("%02d") + ":" + myTime.sec.format("%02d") + "> ";



//  ____  _____             _____       _ _                   _ _   _ _             _      
// |  _ \|  __ \           |  __ \     | | |            /\   | | | (_) |           | |     
// | |_) | |__) |  ______  | |  | | ___| | |_ __ _     /  \  | | |_ _| |_ _   _  __| | ___ 
// |  _ <|  _  /  |______| | |  | |/ _ \ | __/ _` |   / /\ \ | | __| | __| | | |/ _` |/ _ \
// | |_) | | \ \           | |__| |  __/ | || (_| |  / ____ \| | |_| | |_| |_| | (_| |  __/
// |____/|_|  \_\          |_____/ \___|_|\__\__,_| /_/    \_\_|\__|_|\__|\__,_|\__,_|\___|
//                                                                                         

		var changeinelevation = 0; 


	//	if(info.currentLocation != null && info.altitude != null) {
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
			System.println("cost " + cost + ", incline " + incline + ", incline^2 " + Math.pow(incline, 2) );

			var mspeed = hspeed * cost;

			  
			display.varIMM = fmtPace(mspeed);
        	//display.ColorFGVarIMM = Graphics.COLOR_DK_RED;
        	display.ColorFGVarIMM = Graphics.COLOR_BLACK;

		} else {
			display.varIMM = "no hspeed";
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
                                                                                                                                                   
		if(info.totalAscent != null) {
			display.varIML = "+" +  info.totalAscent.format("%.0f");
		} else {
			display.varIML = "zero";
		}
		
		if(info.totalDescent != null) {
			display.varIMR = "-" + info.totalDescent.format("%.0f");
		} else {
			display.varIMR = "zero";
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


/*
//  ____  _                 _______ _                  _____       _ _        
// |  _ \| |               |__   __(_)                |  __ \     | | |       
// | |_) | |       ______     | |   _ _ __ ___   ___  | |  | | ___| | |_ __ _ 
// |  _ <| |      |______|    | |  | | '_ ` _ \ / _ \ | |  | |/ _ \ | __/ _` |
// | |_) | |____              | |  | | | | | | |  __/ | |__| |  __/ | || (_| |
// |____/|______|             |_|  |_|_| |_| |_|\___| |_____/ \___|_|\__\__,_|
//                                                                            



		if(info.elapsedDistance != null && info.timerTime != null) {
			//var ActualPace = info.elapsedDistance / info.elapsedTime;
			var TimeWeShouldHaveGotHere = info.elapsedDistance / TargetPace;
			var ElapsedSeconds = info.timerTime / 1000.0;
			var SecondsDelta = TimeWeShouldHaveGotHere - ElapsedSeconds ;
			var AbsDelta = SecondsDelta.abs();

   			//System.println("TimeShouldGotHere " + TimeWeShouldHaveGotHere + " ElapsedSeconds " + ElapsedSeconds + " SecondsDelta " + SecondsDelta + ", AbsDelta " + AbsDelta + ", dist:" + info.elapsedDistance + ", speed: " + info.averageSpeed);
			
			//if elapsed > actual, we're slow
			//caution - on the simulator you can end up behind because distance is from file, time from start/stop
			if(SecondsDelta > 0 && SecondsDelta < 5) {
				display.varBL  = "-" + fmtSecs(SecondsDelta);
                display.ColorFGVarBL = Graphics.COLOR_DK_GREEN;
			} else if(SecondsDelta < 0) {
				display.varBL  = "+" + fmtSecs(AbsDelta);
                display.ColorFGVarBL = Graphics.COLOR_DK_RED;
			} else {
				display.varBL = "-" + fmtSecs(AbsDelta);
                display.ColorFGVarBL = Graphics.COLOR_PURPLE;
			}
			
            display.isNumBL = (AbsDelta <= 599);
		} else {
            display.ColorFGVarBL = Graphics.COLOR_BLACK;
			display.varBL = "No Data";
            display.isNumBL = false;
		}

*/

//  __  __ __  __            _____               
// |  \/  |  \/  |          |  __ \              
// | \  / | \  / |  ______  | |__) |_ _  ___ ___ 
// | |\/| | |\/| | |______| |  ___/ _` |/ __/ _ \
// | |  | | |  | |          | |  | (_| | (_|  __/
// |_|  |_|_|  |_|          |_|   \__,_|\___\___|
                                               
                                               


	    if(info.currentSpeed != null && info.currentSpeed > 0) {
//			var realPace = info.currentSpeed*AverageLap;
//			var realPace = info.currentSpeed;


			display.varSMM = fmtPace(info.currentSpeed*AverageLap);
            display.ColorBGVarSMM = Graphics.COLOR_WHITE;
            display.ColorFGVarSMM = Graphics.COLOR_BLACK;

/*
            var paceDeviation = (info.currentSpeed / TargetPace).abs();
            if (paceDeviation < 0.95) {    //! More than 5% slower
                display.ColorFGVarSMM = Graphics.COLOR_DK_RED;
            } else if (paceDeviation <= 1.05) {    //! Within +/-5% of target pace
                display.ColorFGVarSMM = Graphics.COLOR_DK_GREEN;
            } else {  //! More than 5% faster
                display.ColorFGVarSMM = Graphics.COLOR_PURPLE;
            }
*/
		} else {
            display.ColorFGVarSMM = Graphics.COLOR_BLACK;
            display.ColorBGVarSMM = Graphics.COLOR_WHITE;
			display.varSMM = "-:--";
		}
		
		

//  _                              __  __ _     _     _ _                                                _____               
// | |                            |  \/  (_)   | |   | | |          /\                                  |  __ \              
// | |     _____      _____ _ __  | \  / |_  __| | __| | | ___     /  \__   _____ _ __ __ _  __ _  ___  | |__) |_ _  ___ ___ 
// | |    / _ \ \ /\ / / _ \ '__| | |\/| | |/ _` |/ _` | |/ _ \   / /\ \ \ / / _ \ '__/ _` |/ _` |/ _ \ |  ___/ _` |/ __/ _ \
// | |___| (_) \ V  V /  __/ |    | |  | | | (_| | (_| | |  __/  / ____ \ V /  __/ | | (_| | (_| |  __/ | |  | (_| | (_|  __/
// |______\___/ \_/\_/ \___|_|    |_|  |_|_|\__,_|\__,_|_|\___| /_/    \_\_/ \___|_|  \__,_|\__, |\___| |_|   \__,_|\___\___|
//                                                                                           __/ |                           
                		
	    if(info.averageSpeed != null && info.averageSpeed > 0) {
				display.varLMM = fmtPace(info.averageSpeed);
		} else {
			display.varLMM = "-:--";
		}
        display.ColorFGVarLMM = Graphics.COLOR_BLACK;
        display.ColorBGVarLMM = Graphics.COLOR_WHITE;

//
//  _      _____    _____  _     _                         _____                      _                  ____        _   _                  
// | |    |  __ \  |  __ \(_)   | |                       |  __ \                    (_)         ___    |  _ \      | | | |                 
// | |    | |__) | | |  | |_ ___| |_ __ _ _ __   ___ ___  | |__) |___ _ __ ___   __ _ _ _ __    ( _ )   | |_) | __ _| |_| |_ ___ _ __ _   _ 
// | |    |  _  /  | |  | | / __| __/ _` | '_ \ / __/ _ \ |  _  // _ \ '_ ` _ \ / _` | | '_ \   / _ \/\ |  _ < / _` | __| __/ _ \ '__| | | |
// | |____| | \ \  | |__| | \__ \ || (_| | | | | (_|  __/ | | \ \  __/ | | | | | (_| | | | | | | (_>  < | |_) | (_| | |_| ||  __/ |  | |_| |
// |______|_|  \_\ |_____/|_|___/\__\__,_|_| |_|\___\___| |_|  \_\___|_| |_| |_|\__,_|_|_| |_|  \___/\/ |____/ \__,_|\__|\__\___|_|   \__, |
//                                                                                                                                     __/ |
//  

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
/*
            display.ColorFGVarLMR = Graphics.COLOR_BLACK;
            display.ColorBGVarLMR = Graphics.COLOR_WHITE;
            display.isNumLMR = true;
			var myStats = System.getSystemStats();
			var battery = myStats.battery;            
			display.varLMR = battery.format("%.1f") + "%";
			*/
			display.varLMR = grade.format("%.1f") + "%";
			
		}
		

//currentLocationAccuracy
//  _      _                  _____                       _   _              _   _____               
// | |    | |                / ____|                     | | | |            | | |  __ \              
// | |    | |       ______  | (___  _ __ ___   ___   ___ | |_| |__   ___  __| | | |__) |_ _  ___ ___ 
// | |    | |      |______|  \___ \| '_ ` _ \ / _ \ / _ \| __| '_ \ / _ \/ _` | |  ___/ _` |/ __/ _ \
// | |____| |____            ____) | | | | | | (_) | (_) | |_| | | |  __/ (_| | | |  | (_| | (_|  __/
// |______|______|          |_____/|_| |_| |_|\___/ \___/ \__|_| |_|\___|\__,_| |_|   \__,_|\___\___|
//                                                                                                   
//                                                                                                   

		//do the calculation
	    if(info.currentSpeed != null && info.currentSpeed > 0) {
			var realPace = info.currentSpeed*AverageLap;

			if(smoothpace == 0) {
				smoothpace = info.currentSpeed;
			}
			if(SmoothPaceCounter < PaceSmoothing) {
				SmoothPaceCounter++;
			}
			smoothpace = (smoothpace*(SmoothPaceCounter-1)/SmoothPaceCounter) + realPace/SmoothPaceCounter;
			spaceField.setData(smoothpace.toFloat());
			//System.println("smoothpace " +  smoothpace.format("%.2f") +", currentSpeed " +  info.currentSpeed.format("%.2f") +", SmoothPaceCounter " +  SmoothPaceCounter);  

//			display.varLML = fmtPace(smoothpace);
//            display.ColorFGVarLML = Graphics.COLOR_WHITE;
//            display.ColorBGVarLML = Graphics.COLOR_BLACK;

		} else {
            //display.ColorFGVarSMM = Graphics.COLOR_BLACK;
            //display.ColorBGVarSMM = Graphics.COLOR_WHITE;
//			display.varLML = "-:--";
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
/*
	if(info.currentLocationAccuracy  != null) {
        display.isNumLML = true;
		if(info.currentLocationAccuracy == 0) {
			display.varLML = "!";
            display.ColorFGVarLML = Graphics.COLOR_WHITE;
            display.ColorBGVarLML = Graphics.COLOR_RED;
		} else 	if(info.currentLocationAccuracy == 1) {
			display.varLML = "*";
            display.ColorFGVarLML = Graphics.COLOR_ORANGE;
            display.ColorBGVarLML = Graphics.COLOR_WHITE;
		} else 	if(info.currentLocationAccuracy == 2) {
			display.varLML = "**";
            display.ColorFGVarLML = Graphics.COLOR_RED;
            display.ColorBGVarLML = Graphics.COLOR_WHITE;
		} else 	if(info.currentLocationAccuracy == 3) {
			display.varLML = "***";
            display.ColorFGVarLML = Graphics.COLOR_GREEN;
            display.ColorBGVarLML = Graphics.COLOR_WHITE;
		} else 	if(info.currentLocationAccuracy == 4) {
			display.varLML = "****";
            display.ColorFGVarLML = Graphics.COLOR_PURPLE;
            display.ColorBGVarLML = Graphics.COLOR_WHITE;
		} else {
			display.varLML = "WTF";
            display.ColorFGVarLML = Graphics.COLOR_WHITE;
            display.ColorBGVarLML = Graphics.COLOR_BLACK;
		}		
    }
*/
//		display.varTL = 123;
//		display.varTR = "123";
//		display.varML = "123'";
//		display.varMM = "123abc";

//  _____        _          ______ _      _     _             _____              _ _               _____          _   
// |  __ \      | |        |  ____(_)    | |   | |           / ____|            | (_)             / ____|        | |  
// | |  | | __ _| |_ __ _  | |__   _  ___| | __| |  ______  | |     __ _ _ __ __| |_  __ _  ___  | |     ___  ___| |_ 
// | |  | |/ _` | __/ _` | |  __| | |/ _ \ |/ _` | |______| | |    / _` | '__/ _` | |/ _` |/ __| | |    / _ \/ __| __|
// | |__| | (_| | || (_| | | |    | |  __/ | (_| |          | |___| (_| | | | (_| | | (_| | (__  | |___| (_) \__ \ |_ 
// |_____/ \__,_|\__\__,_| |_|    |_|\___|_|\__,_|           \_____\__,_|_|  \__,_|_|\__,_|\___|  \_____\___/|___/\__|
//                                                                                                                    
     
		//cardiac cost
		var cc=0;
		if(hr != 0 && info.currentSpeed != null && info.currentSpeed != 0) {
			cc = info.currentHeartRate / info.currentSpeed * 6000.0; //from Pacing Strategy Affects the Sub-Elite Marathoner�s Cardiac Drift and Performance|doi=10.3389/fpsyg.2019.03026
		}
		cardiacCostField.setData(cc.toFloat());
		
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




		

	
	function racePrediction(info) {
		//  _____                  _____              _ _      _   _             
		// |  __ \                |  __ \            | (_)    | | (_)            
		// | |__) |__ _  ___ ___  | |__) | __ ___  __| |_  ___| |_ _  ___  _ __  
		// |  _  // _` |/ __/ _ \ |  ___/ '__/ _ \/ _` | |/ __| __| |/ _ \| '_ \ 
		// | | \ \ (_| | (_|  __/ | |   | | |  __/ (_| | | (__| |_| | (_) | | | |
		// |_|  \_\__,_|\___\___| |_|   |_|  \___|\__,_|_|\___|\__|_|\___/|_| |_|
		//                                                                       
		EstimatedFinishTimeSmoothed = "";
		EstimatedFinishTimeAverage = "";
		EstimatedDistanceSmoothed = "";
		EstimatedDistanceAverage = "";

		if(info.timerTime != null && info.timerTime != 0 && info.elapsedDistance != null && info.elapsedDistance != 0) {
			//smoothpace = 2.9803;
			//System.println("\nPredictionDistance\n");
			if(PredictionDistance != 0) {
//					var TrueDistance = info.elapsedDistance - distancecorrection;					
//					var DistanceRemaining =  PredictionDistance - TrueDistance;
//					var ElapsedSeconds = info.timerTime / 1000.0;
//					var ExtraSeconds = DistanceRemaining / smoothpace;
//					var TotalSeconds = ElapsedSeconds + ExtraSeconds;
//					System.println("TrueDistance " + TrueDistance);
//					System.println("DistanceRemaining " + DistanceRemaining);
//					System.println("ElapsedSeconds " + ElapsedSeconds);
//					System.println("ExtraSeconds " + ExtraSeconds);
//					System.println("TotalSeconds " + TotalSeconds + ", " + fmtTimeHMS(TotalSeconds));
				var TotalSeconds;
				TotalSeconds = PredictForDistance(info, smoothpace*AverageLap);
				if(TotalSeconds != null && TotalSeconds > 0) {
					EstimatedFinishTimeSmoothed = fmtTimeHMS(TotalSeconds);
				}
				TotalSeconds = PredictForDistance(info, info.averageSpeed);
				if(TotalSeconds != null && TotalSeconds > 0) {
					EstimatedFinishTimeAverage = fmtTimeHMS(TotalSeconds);
				}
			}
			if(PredictionTime != 0) {
//					var ElapsedSeconds = info.timerTime / 1000.0;
//					var RemainingSeconds = (PredictionTime * 60) - ElapsedSeconds;
//					var ExtraDistance = RemainingSeconds * smoothpace; //pace is in m/s
//					var TrueDistance = info.elapsedDistance - distancecorrection;					
//					var TotalDistance =  TrueDistance + ExtraDistance;
//					var TotalDistanceUnits = TotalDistance / unitP;
				
//					System.println("\nPredictionTime\n");
//					System.println("ElapsedSeconds " + ElapsedSeconds);
//					System.println("RemainingSeconds " + RemainingSeconds);
//					System.println("smoothpace " + smoothpace);
//					System.println("ExtraDistance " + ExtraDistance);
//					System.println("TrueDistance " + TrueDistance);
//					System.println("TotalDistance " + TotalDistance);
//					System.println("TotalDistanceUnits " + TotalDistanceUnits);
				EstimatedDistanceSmoothed = PredictForTime(info, smoothpace*AverageLap);
				EstimatedDistanceAverage = PredictForTime(info, info.averageSpeed);
			}
		}
		
		if(loop) {
			//RemaininDistanceInUnits
			if(EstimatedFinishTimeSmoothed.length() != 0) { // time left to reach distance
				display.varB = EstimatedFinishTimeSmoothed;
			} else {
				if(EstimatedDistanceSmoothed.length() != 0) {
					display.varB = EstimatedDistanceSmoothed;
				}
			}
		 	display.isNumB = false;
			if(display.varB != null && display.varB.length() != 0) {
				display.varB += "@" + FinishTimeOfDay;
			} else {
				display.varB = null;
			 	display.isNumB = false;
			}
			display.ColorBGVarB = Graphics.COLOR_TRANSPARENT;
			display.ColorFGVarB = Graphics.COLOR_BLACK;
		} else {
			if(TimeRemainingString.length() != 0) {
				display.varB = 	TimeRemainingString + "/" + RemaininDistanceInUnits;
			} else {
				display.varB = null;
			 	display.isNumB = false;
			}
			display.ColorBGVarB = Graphics.COLOR_BLACK;
			display.ColorFGVarB = Graphics.COLOR_WHITE;
		} 
		
	}
	
	function PredictForDistance(info, pace) {
		if(pace == null || pace < 1.0) { //slower than 1 m/s, 28:50 min/mile
			return null;
		}
		var TrueDistance = info.elapsedDistance - distancecorrection;					
		var DistanceRemaining =  PredictionDistance - TrueDistance;
		if(DistanceRemaining < 0) {
			RemaininDistanceInUnits = "";
			FinishTimeOfDay = "";
			TimeRemainingString = "";
			return null;
		}
		var ElapsedSeconds = info.timerTime / 1000.0;
		var ExtraSeconds = DistanceRemaining / pace;
		var TotalSeconds = ElapsedSeconds + ExtraSeconds;
		
		var duration = new Time.Duration(ExtraSeconds);
		var finish = Time.now().add(duration);
		var finishtime = Gregorian.info(finish, Time.FORMAT_MEDIUM);

		RemaininDistanceInUnits = DistanceRemaining / unitP;
		if(RemaininDistanceInUnits < 10.0) {
			RemaininDistanceInUnits = RemaininDistanceInUnits.format("%.2f");
		} else {
			RemaininDistanceInUnits = RemaininDistanceInUnits.format("%.1f");
		}
		FinishTimeOfDay = finishtime.hour + ":" + finishtime.min.format("%02d");
		TimeRemainingString = fmtTime(ExtraSeconds);
		
		return TotalSeconds;
	}	
	function PredictForTime(info, pace) {
		if(pace == null || pace < 1.0) { //more than 1 m/s, 28:50 min/mile
			return null;
		}
		var ElapsedSeconds = info.timerTime / 1000.0;
		var RemainingSeconds = (PredictionTime * 60) - ElapsedSeconds;
		if(RemainingSeconds < 0) {
			RemaininDistanceInUnits = "";
			FinishTimeOfDay = "";
			TimeRemainingString = "";
			return null;
		}
		var ExtraDistance = RemainingSeconds * pace; //pace is in m/s
		var TrueDistance = info.elapsedDistance - distancecorrection;					
		var TotalDistance =  TrueDistance + ExtraDistance;
		var TotalDistanceUnits = TotalDistance / unitP;
		
		var duration = new Time.Duration(RemainingSeconds);
		var finish = Time.now().add(duration);
		var finishtime = Gregorian.info(finish, Time.FORMAT_MEDIUM);

		RemaininDistanceInUnits = ExtraDistance / unitP;
		FinishTimeOfDay = finishtime.hour + ":" + finishtime.min.format("%02d");
		TimeRemainingString = fmtTime(RemainingSeconds);
		
		return TotalDistanceUnits.format("%.1f");
	}
}
