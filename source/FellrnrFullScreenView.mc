using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Attention;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;


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

//logging via println
//Logs stored in /Garmin/APPS/LOGS, but customer needs to create an empty text file and put proper name that corresponds to the application name, like for 88833555.PRG is 88833555.txt should be created.

class FellrnrFullScreenView extends WatchUi.DataField {

//var hack=0;

    var pwr;
	var calcpwr=0;
    var hr;
    var hrpwr;

	var weight;
	var rhr;
	var MaxHR;
	
	var hrpwrlabel;
	var display as ScreenLayout;
    var mBgColorFG;

	var ZeroPowerHR;
	var HrPwrSmoothing;
	var PaceSmoothing;
	var DisplayLoop;
	var CriticalPower;
	var FieldsDefaultProperty;
	var FieldsRunProperty;
	var FieldsTrailProperty;
	var FieldsProperty;
	var StoreNativePower;
	var TargetCadence;
	var CadenceColorStep;
	var WalkingCadence;
	var UseCore;

	
	var coreField = null;

	var StartingElevation = 0;
	var ElevationDelta;
	var simple;
    var unitP                        = 1000.0;
    var unitE                        = 1609.344;
    
    var smoothhr=0;
    var smoothpwr=0;
	var smoothSpeed = 0;
    var smoothSpeedCounter=0;
    var SmoothHrPwrCounter=0;
    var alertcount=0;
    const ALERT_FREQUENCY=15;
    var alertinterval=ALERT_FREQUENCY;
    var sequence=0;
    var loop=0;
    var loop3=0; //0,1,2

	var cardiacCost=0;
	var gradeAdjustedSpeed=0;
	var gradeAdjustedCardiacCost=0;

	hidden var pwrField = null;
	hidden var shrpwrField;
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

	var runningDynamics as Toybox.AntPlus.RunningDynamics or Null = null;
	var isRun = false;
	var isTrail = false;

	function onNextMultisportLeg() {
		onTimerReset();
	}	// end func onNextMultisportLeg


    function onTimerReset() {
		StartingElevation = 0;
    	smoothSpeedCounter=0;
    	SmoothHrPwrCounter=0;
		coreField.mFitContributor.onTimerReset();
		coreField.mFitContributor.onTimerLap();
	}	
	
    function onTimerStart() {
		display.countdown = 0;
		StartingElevation = 0;
    	smoothSpeedCounter=0;
    	SmoothHrPwrCounter=0;
	    smoothhr=0;
	    smoothpwr=0;
		coreField.mFitContributor.setTimerRunning( true, coreField.mSensor );
    }

    function onTimerPause () {
    	smoothSpeedCounter=0;
    	SmoothHrPwrCounter=0;
	    smoothhr=0;
	    smoothpwr=0;
		coreField.mFitContributor.setTimerRunning( false, coreField.mSensor );
	}	

    function onTimerResume() {
    	smoothSpeedCounter=0;
    	SmoothHrPwrCounter=0;
	    smoothhr=0;
	    smoothpwr=0;
		coreField.mFitContributor.setTimerRunning( true, coreField.mSensor );
	}	

    function onTimerStop() {
    	smoothSpeedCounter=0;
    	SmoothHrPwrCounter=0;
	    smoothhr=0;
	    smoothpwr=0;
		coreField.mFitContributor.setTimerRunning( false, coreField.mSensor );
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
	        

			//Fenix 5X is 3.1.0
			//Fenix 6X is 3.4.0
			if(Toybox.Activity has :ProfileInfo) {
				if(Activity.getProfileInfo() != null) { 			//API Level 3.2.0

					if(Activity.getProfileInfo().sport != null) { //API Level 3.2.0
						if(Activity.getProfileInfo().sport == Activity.SPORT_RUNNING) {
							isRun = true;
						}
					}
					if(Activity.getProfileInfo().subSport != null) { //API Level 3.2.0
						if(Activity.getProfileInfo().subSport == Activity.SUB_SPORT_TRAIL) {
							isTrail = true;
						}
					}
				}
			}

	        var profile = UserProfile.getProfile();
	        weight = profile.weight / 1000.0; //grams to Kg
	        hrZones = profile.getHeartRateZones(profile.getCurrentSport());
	        MaxHR = hrZones[5];
	        //weight = weight.toLong(); 
	        rhr = profile.restingHeartRate;


	        if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
	            unitP = 1609.344;
	            unitE = 1000.0;
	        }
	        
	        
			var mApp = Application.getApp();
	        ZeroPowerHR = mApp.getProperty("ZeroPowerHR");
			HrPwrSmoothing = mApp.getProperty("HrPwrSmoothing").toFloat();
			PaceSmoothing = mApp.getProperty("PaceSmoothing").toFloat();
			DisplayLoop = mApp.getProperty("DisplayLoop");
			CriticalPower = mApp.getProperty("CriticalPower");
			FieldsDefaultProperty = mApp.getProperty("FieldsDefault");
			FieldsRunProperty = mApp.getProperty("FieldsRun");
			FieldsTrailProperty = mApp.getProperty("FieldsTrail");
			if(isTrail) {
				FieldsProperty = FieldsTrailProperty;
			} else if(isRun) {
				FieldsProperty = FieldsRunProperty;
			} else {
				FieldsProperty = FieldsDefaultProperty;
			}
				
			StoreNativePower = mApp.getProperty("StoreNativePower");
			TargetCadence = mApp.getProperty("TargetCadence");
			CadenceColorStep = mApp.getProperty("CadenceColorStep");
			WalkingCadence = mApp.getProperty("WalkingCadence");
			UseCore = mApp.getProperty("UseCore");

			System.println("ZeroPowerHR:        	" + ZeroPowerHR);
			System.println("HrPwrSmoothing:     	" + HrPwrSmoothing);
			System.println("PaceSmoothing:      	" + PaceSmoothing);
			System.println("DisplayLoop:        	" + DisplayLoop);
			System.println("CriticalPower:      	" + CriticalPower);
			System.println("StoreNativePower:   	" + StoreNativePower);
			System.println("UseCore:	   			" + UseCore);
			System.println("FieldsDefaultProperty:	" + FieldsDefaultProperty);
			System.println("FieldsRunProperty:     	" + FieldsRunProperty);
			System.println("FieldsTrailProperty:    " + FieldsTrailProperty);
			System.println("FieldsProperty:     	" + FieldsProperty);

	
	        hrpwrlabel = "" + ZeroPowerHR.format("%d") + ":" + weight.format("%d") + "";
	        
	        display = new ScreenLayout(); //governed by monkey.jungle
			display.screenData.screenConfig = FieldsProperty;
	        
			//pwrField = createField("pwr", 0, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"N" });

	        //pwrField = createField("Fellrnr_FS_power", 0, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );

			if(StoreNativePower) {
				pwrField = createField("Power", 30, FitContributor.DATA_TYPE_UINT16, {:mesgType => FitContributor.MESG_TYPE_RECORD, :units => "W", :nativeNum => 7});
			}

			shrpwrField = createField("Fellrnr_FS_hrpwr", 31, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
			//strideLengthField = createField("Fellrnr_FS_stride_length", 2, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
			//gacardiacCostField = createField("Fellrnr_FS_cardic_distance", 3, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>FitContributor.MESG_TYPE_RECORD } );
	        
			if(pwrField != null) {
	        	pwrField.setData(0);
			}
			shrpwrField.setData(0.0);
			//strideLengthField.setData(0.0); 
			//gacardiacCostField.setData(0.0); 

			if(Toybox.AntPlus has :RunningDynamics) {
				runningDynamics = new Toybox.AntPlus.RunningDynamics(null);
			}

        if(UseCore) {
			coreField = new CoreField(self);
        }



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


		display.screenData.mapDisplayFields();

        if(UseCore) {
			coreField.computeCore();
        }


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

//    _____                   _               _____                              _          
//   |  __ \                 (_)             |  __ \                            (_)         
//   | |__) |   _ _ __  _ __  _ _ __   __ _  | |  | |_   _ _ __   __ _ _ __ ___  _  ___ ___ 
//   |  _  / | | | '_ \| '_ \| | '_ \ / _` | | |  | | | | | '_ \ / _` | '_ ` _ \| |/ __/ __|
//   | | \ \ |_| | | | | | | | | | | | (_| | | |__| | |_| | | | | (_| | | | | | | | (__\__ \
//   |_|  \_\__,_|_| |_|_| |_|_|_| |_|\__, | |_____/ \__, |_| |_|\__,_|_| |_| |_|_|\___|___/
//                                     __/ |          __/ |                                 
//                                    |___/          |___/                                  


		var stepPerMinutes = null;
		var grndConTime = null;
        if (runningDynamics != null) {
		     var rd = runningDynamics.getRunningDynamics();
		     if (rd != null) {
		         stepPerMinutes = rd.cadence; //like strides per minute is one leg
		         display.screenData.d_verticalOscillationMM = rd.verticalOscillation;
		         grndConTime = rd.groundContactTime.toFloat();
				 display.screenData.d_groundContactTimeMs = rd.groundContactTime;
		         //var stepLength = rd.stepLength;
			 }
		}


		 //stepPerMinutes = 90;
		 //grndConTime = 250;

		//System.println("Running Dynamics at " + timeString);
		display.screenData.d_dutyFactor = null;
		display.screenData.d_stanceOccelation = null;
		if(stepPerMinutes != null && stepPerMinutes > 0 && grndConTime != null) {
			stepPerMinutes = stepPerMinutes.toFloat();


			var stepTimeMs = 60.0 / stepPerMinutes * 1000.0;
			var dutyFactor = grndConTime / stepTimeMs * 100.0;
			display.screenData.d_dutyFactor = dutyFactor.format("%.0f") + "%";
			display.screenData.d_dutyFactorBG = GetDutyFactorColor(dutyFactor);
			if(display.screenData.d_verticalOscillationMM != null) {
				var flightTimeMs = stepTimeMs - display.screenData.d_groundContactTimeMs;
				var gravity = 9.8;
				var timeGoingUpMs = flightTimeMs/2.0;
				var timeGoingUpSec = timeGoingUpMs / 1000.0;
				var stanceVelocityMpS = timeGoingUpSec * gravity;
				var stanceHeightM = stanceVelocityMpS * timeGoingUpSec;
				var stanceHeightCm = stanceHeightM * 100;
				var verticalOscillationCm = display.screenData.d_verticalOscillationMM.toFloat() / 10.0;

				display.screenData.d_stanceOccelation = verticalOscillationCm - stanceHeightCm;
			}
		}



		sequence++;
		loop = ((sequence / DisplayLoop) % 2) == 0;

		loop3 = ((sequence / DisplayLoop) % 3);

	 	display.varB = null; 




//     _____ ____  _____  ______    _____                           
//    / ____/ __ \|  __ \|  ____|  / ____|                          
//   | |   | |  | | |__) | |__    | (___   ___ _ __  ___  ___  _ __ 
//   | |   | |  | |  _  /|  __|    \___ \ / _ \ '_ \/ __|/ _ \| '__|
//   | |___| |__| | | \ \| |____   ____) |  __/ | | \__ \ (_) | |   
//    \_____\____/|_|  \_\______| |_____/ \___|_| |_|___/\___/|_|   
//                                                                  
//                                                                  

//if(hack > 9.5) { hack=0; } else { hack += 0.5; }
//coreField.heatStrainIndex = hack;


		display.screenData.d_coreTemperature = coreField.coreTemperature.format("%.2f");
		display.screenData.d_skinTemperature = coreField.skinTemperature.format("%.2f");
		display.screenData.d_heatStrainIndex = coreField.heatStrainIndex.format("%.1f");
		display.screenData.d_heatStrainIndexBG = GetHsiColor(coreField.heatStrainIndex);

		if(coreField.heatStrainIndex < 1.0) {
			display.screenData.d_heat = display.screenData.d_coreTemperature;
			display.screenData.d_heatBG = Graphics.COLOR_WHITE;
		} else {
			display.screenData.d_heat = display.screenData.d_heatStrainIndex;
			display.screenData.d_heatBG = display.screenData.d_heatStrainIndexBG;
		}


		if(loop3 == 0) {
			display.screenData.d_allTemperature = display.screenData.d_coreTemperature;
			display.screenData.d_allTemperatureBG = Graphics.COLOR_WHITE;
		} else if(loop3 == 1) {
			display.screenData.d_allTemperature = display.screenData.d_skinTemperature;
			display.screenData.d_allTemperatureBG = Graphics.COLOR_BLACK;
		} else {
			display.screenData.d_allTemperature = display.screenData.d_heatStrainIndex;
			display.screenData.d_allTemperatureBG = display.screenData.d_heatStrainIndexBG;
		} 


//    _______ _                     
//   |__   __(_)                    
//      | |   _ _ __ ___   ___  ___ 
//      | |  | | '_ ` _ \ / _ \/ __|
//      | |  | | | | | | |  __/\__ \
//      |_|  |_|_| |_| |_|\___||___/
//                                  
//                                  

		//tail
		var myTime = System.getClockTime(); // ClockTime object
		display.screenData.d_clockTime = "T" + myTime.hour.format("%02d") + ":" + myTime.min.format("%02d"); // + ":" + myTime.sec.format("%02d");

		var ElapsedSeconds = info.timerTime / 1000.0;
		display.screenData.d_elapsedTime = "E" + fmtTime(ElapsedSeconds);

		if(loop) {
			display.screenData.d_times = display.screenData.d_clockTime;
			display.screenData.d_timesBG = Graphics.COLOR_WHITE;
		} else {
			display.screenData.d_times = display.screenData.d_elapsedTime;
			display.screenData.d_timesBG = Graphics.COLOR_BLACK;
		} 
		

		pwr = 0;
		hr = 0;




//     _____          _                     
//    / ____|        | |                    
//   | |     __ _  __| | ___ _ __   ___ ___ 
//   | |    / _` |/ _` |/ _ \ '_ \ / __/ _ \
//   | |___| (_| | (_| |  __/ | | | (_|  __/
//    \_____\__,_|\__,_|\___|_| |_|\___\___|
//                                          
//                                          

		if(info.currentCadence  == 0 || info.currentCadence == null) {
			display.screenData.d_cadence = null;
			display.screenData.d_cadenceBG = Graphics.COLOR_WHITE;
		} else  {

			display.screenData.d_cadence = info.currentCadence;
			//if(hack > 220) { hack=145; } else { hack += 2; }
			//display.screenData.d_cadence = hack;

			display.screenData.d_cadenceBG = GetCadenceColor(display.screenData.d_cadence);
		}




//    _____       _ _          ______ _                 _   _             
//   |  __ \     | | |        |  ____| |               | | (_)            
//   | |  | | ___| | |_ __ _  | |__  | | _____   ____ _| |_ _  ___  _ __  
//   | |  | |/ _ \ | __/ _` | |  __| | |/ _ \ \ / / _` | __| |/ _ \| '_ \ 
//   | |__| |  __/ | || (_| | | |____| |  __/\ V / (_| | |_| | (_) | | | |
//   |_____/ \___|_|\__\__,_| |______|_|\___| \_/ \__,_|\__|_|\___/|_| |_|
//                                                                        
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
			display.screenData.d_deltaElevation = "Δ" + changeinelevation.format("%.1f");

			//fifo
			elevationarray = elevationarray.slice(1, null);
			elevationarray.add(info.altitude);
		} 


//		if(isTrailRun) {



//     _____          _____     _____               _                    _ _           _           _   _____               
//    / ____|   /\   |  __ \   / ____|             | |          /\      | (_)         | |         | | |  __ \              
//   | |  __   /  \  | |__) | | |  __ _ __ __ _  __| | ___     /  \   __| |_ _   _ ___| |_ ___  __| | | |__) |_ _  ___ ___ 
//   | | |_ | / /\ \ |  ___/  | | |_ | '__/ _` |/ _` |/ _ \   / /\ \ / _` | | | | / __| __/ _ \/ _` | |  ___/ _` |/ __/ _ \
//   | |__| |/ ____ \| |      | |__| | | | (_| | (_| |  __/  / ____ \ (_| | | |_| \__ \ ||  __/ (_| | | |  | (_| | (_|  __/
//    \_____/_/    \_\_|       \_____|_|  \__,_|\__,_|\___| /_/    \_\__,_| |\__,_|___/\__\___|\__,_| |_|   \__,_|\___\___|
//                                                                       _/ |                                              
//                                                                      |__/                                               

//https://journals.physiology.org/doi/full/10.1152/japplphysiol.01177.2001
//NOTE: other fields rely on the GAP
		var grade = null;
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

			  
			display.screenData.d_gradeAdjustedPace = fmtPace(gradeAdjustedSpeed);

		} else {
			display.screenData.d_gradeAdjustedPace = null;
			gradeAdjustedSpeed = 0;
		}

		display.screenData.d_grade = null;
		if(grade != null) {
			display.screenData.d_grade = grade.format("%.1f") + "%";
		}

//    _    _                 _     _____       _       
//   | |  | |               | |   |  __ \     | |      
//   | |__| | ___  __ _ _ __| |_  | |__) |__ _| |_ ___ 
//   |  __  |/ _ \/ _` | '__| __| |  _  // _` | __/ _ \
//   | |  | |  __/ (_| | |  | |_  | | \ \ (_| | ||  __/
//   |_|  |_|\___|\__,_|_|   \__| |_|  \_\__,_|\__\___|
//                                                     
//                                                     

		//Just HR
		if(info.currentHeartRate == 0 || info.currentHeartRate == null) {
			display.screenData.d_heartRate = null;
			hr=0;
		} else  {
			hr =  info.currentHeartRate;
			display.screenData.d_heartRate = info.currentHeartRate;
			display.screenData.d_heartRateBG = GetHrColor(hr);
			display.screenData.d_heartRateIsNum = true;
		}



//    _____                       
//   |  __ \                      
//   | |__) |____      _____ _ __ 
//   |  ___/ _ \ \ /\ / / _ \ '__|
//   | |  | (_) \ V  V /  __/ |   
//   |_|   \___/ \_/\_/ \___|_|   
//                                
//                                

		//Calcualted Power 
		calcpwr=0;
		if(info.currentSpeed != null && info.currentSpeed > 0) {
			//power is about speed (m/s) * weight (kg) * 1.04;
			calcpwr = gradeAdjustedSpeed * weight * 1.04;
		}

		if(info.currentPower != 0 && info.currentPower != null) {
			pwr = info.currentPower;
			//var wpkg = pwr / weight;
			display.screenData.d_powerBG = GetPwrColor(pwr);
			
        } else {
			//confirm we're calculating power with inverted colours
			display.screenData.d_powerBG = Graphics.COLOR_WHITE;
			pwr = calcpwr; //default to calc as the best we can do
		}

		if(pwrField != null) {
			pwrField.setData(pwr.toNumber());
		}
		display.screenData.d_power = pwr.format("%d");



//    _    _      _____                
//   | |  | |    |  __ \               
//   | |__| |_ __| |__) |_      ___ __ 
//   |  __  | '__|  ___/\ \ /\ / / '__|
//   | |  | | |  | |     \ V  V /| |   
//   |_|  |_|_|  |_|      \_/\_/ |_|   
//                                     
//                                     


		//HR-PWR
	    if(hr != 0 && pwr != 0) {
			if(info.currentHeartRate <= ZeroPowerHR) {
				display.screenData.d_hrPwr = "HR < 0pHR";
	            display.screenData.d_hrPwrIsNum = false;
				display.screenData.d_hrPwrBG = Graphics.COLOR_WHITE;
			} else {
	            display.screenData.d_hrPwrIsNum = true;
				
				if(SmoothHrPwrCounter < HrPwrSmoothing) {
					SmoothHrPwrCounter++;
				}
				
				smoothhr = (smoothhr*(SmoothHrPwrCounter-1.0)/SmoothHrPwrCounter) + hr.toFloat()/SmoothHrPwrCounter;
				smoothpwr = (smoothpwr*(SmoothHrPwrCounter-1.0)/SmoothHrPwrCounter) + pwr/SmoothHrPwrCounter;
					
				
				var pwrMw = smoothpwr * 1000.0;
				var pwkg = (pwrMw / weight);
				var deltahr = (smoothhr - ZeroPowerHR);
				var hrpw = pwkg / deltahr;
				var hrpw1dp = Math.round(hrpw*10)/10.0;
				
//if(hack > 55) { hack=15; } else { hack += 2; }
//hrpw1dp = hack;


				display.screenData.d_hrPwr = hrpw1dp.format("%.1f");

				//Garmin keeps reseting max hr, making percent HRR useless

				display.screenData.d_hrPwrBG = GetHrPwrColor(hrpw1dp);
				
				shrpwrField.setData(hrpw1dp.toFloat());
			}
	    } else {
				display.screenData.d_hrPwr = null;
				display.screenData.d_hrPwrBG = Graphics.COLOR_WHITE;

		}






//             _ _   _ _             _      
//       /\   | | | (_) |           | |     
//      /  \  | | |_ _| |_ _   _  __| | ___ 
//     / /\ \ | | __| | __| | | |/ _` |/ _ \
//    / ____ \| | |_| | |_| |_| | (_| |  __/
//   /_/    \_\_|\__|_|\__|\__,_|\__,_|\___|
//                                          
//                                          

		if(info.altitude != null) {
			display.screenData.d_altitude = "@" +  info.altitude.format("%.0f");
		}

		


//                                _              _____                           _   
//       /\                      | |     ___    |  __ \                         | |  
//      /  \   ___  ___ ___ _ __ | |_   ( _ )   | |  | | ___  ___  ___ ___ _ __ | |_ 
//     / /\ \ / __|/ __/ _ \ '_ \| __|  / _ \/\ | |  | |/ _ \/ __|/ __/ _ \ '_ \| __|
//    / ____ \\__ \ (_|  __/ | | | |_  | (_>  < | |__| |  __/\__ \ (_|  __/ | | | |_ 
//   /_/    \_\___/\___\___|_| |_|\__|  \___/\/ |_____/ \___||___/\___\___|_| |_|\__|
//                                                                                   
//                                                                                   

		if(info.totalAscent != null) {
			display.screenData.d_totalAscent = "+" +  info.totalAscent.format("%.0f");
		}

		if(info.totalDescent != null) {
			display.screenData.d_totalDescent = "-" + info.totalDescent.format("%.0f");
		}
		
		if(loop) {
			display.screenData.d_totalAscentDescent = display.screenData.d_totalAscent;
			display.screenData.d_totalAscentDescentBG = Graphics.COLOR_WHITE;
		} else {
			display.screenData.d_totalAscentDescent = display.screenData.d_totalDescent;
			display.screenData.d_totalAscentDescentBG = Graphics.COLOR_BLACK;
		} 


//    _____  _     _                       
//   |  __ \(_)   | |                      
//   | |  | |_ ___| |_ __ _ _ __   ___ ___ 
//   | |  | | / __| __/ _` | '_ \ / __/ _ \
//   | |__| | \__ \ || (_| | | | | (_|  __/
//   |_____/|_|___/\__\__,_|_| |_|\___\___|
//                                         
//                                         

		if(info.elapsedDistance != null) {
			var distance;
			if(!loop && distancecorrection.abs() > 50) {
				distance = info.elapsedDistance - distancecorrection;
			} else {
				distance = info.elapsedDistance;
			}
			distance = distance / unitP;
			
			if(distance < 100.0) {
				display.screenData.d_distanceDisplay = distance.format("%.2f");
			} else {
				display.screenData.d_distanceDisplay = distance.format("%.1f");
			}
		}
		

//Used to calcualte time delta for race pacing - see version history



//     _____                          _     _____               
//    / ____|                        | |   |  __ \              
//   | |    _   _ _ __ _ __ ___ _ __ | |_  | |__) |_ _  ___ ___ 
//   | |   | | | | '__| '__/ _ \ '_ \| __| |  ___/ _` |/ __/ _ \
//   | |___| |_| | |  | | |  __/ | | | |_  | |  | (_| | (_|  __/
//    \_____\__,_|_|  |_|  \___|_| |_|\__| |_|   \__,_|\___\___|
//                                                              
//                                                              


	    if(info.currentSpeed != null && info.currentSpeed > 0) {
			display.screenData.d_currentPace = fmtPace(info.currentSpeed*AverageLap);
			display.screenData.d_oppositePace = fmtoppositePace(info.currentSpeed*AverageLap);
		} else {
			display.screenData.d_currentPace = null;
		}
		
		


//                                            _____               
//       /\                                  |  __ \              
//      /  \__   _____ _ __ __ _  __ _  ___  | |__) |_ _  ___ ___ 
//     / /\ \ \ / / _ \ '__/ _` |/ _` |/ _ \ |  ___/ _` |/ __/ _ \
//    / ____ \ V /  __/ | | (_| | (_| |  __/ | |  | (_| | (_|  __/
//   /_/    \_\_/ \___|_|  \__,_|\__, |\___| |_|   \__,_|\___\___|
//                                __/ |                           
//                               |___/                            

                		
	    if(info.averageSpeed != null && info.averageSpeed > 0) {
			display.screenData.d_averagePace = fmtPace(info.averageSpeed);
		} else {
			display.screenData.d_averagePace = null;
		}



//    _____  _     _                         _____                      _       _             
//   |  __ \(_)   | |                       |  __ \                    (_)     (_)            
//   | |  | |_ ___| |_ __ _ _ __   ___ ___  | |__) |___ _ __ ___   __ _ _ _ __  _ _ __   __ _ 
//   | |  | | / __| __/ _` | '_ \ / __/ _ \ |  _  // _ \ '_ ` _ \ / _` | | '_ \| | '_ \ / _` |
//   | |__| | \__ \ || (_| | | | | (_|  __/ | | \ \  __/ | | | | | (_| | | | | | | | | | (_| |
//   |_____/|_|___/\__\__,_|_| |_|\___\___| |_|  \_\___|_| |_| |_|\__,_|_|_| |_|_|_| |_|\__, |
//                                                                                       __/ |
//                                                                                      |___/ 


	    if(!(info has :distanceToDestination)) {
			display.screenData.d_distanceRemaining = "N/S";
		} else if(info.distanceToDestination != null && info.distanceToDestination  > 0) {

			var distance; 
			distance = info.distanceToDestination / unitP;

			if(distance < 100.0) {
				display.screenData.d_distanceRemaining = distance.format("%.2f");
			} else {
				display.screenData.d_distanceRemaining = distance.format("%.1f");
			}

		} else {
			display.screenData.d_distanceRemaining = null;
		}
		



//     _____ _        _     _        _                      _   _     
//    / ____| |      (_)   | |      | |                    | | | |    
//   | (___ | |_ _ __ _  __| | ___  | |     ___ _ __   __ _| |_| |__  
//    \___ \| __| '__| |/ _` |/ _ \ | |    / _ \ '_ \ / _` | __| '_ \ 
//    ____) | |_| |  | | (_| |  __/ | |___|  __/ | | | (_| | |_| | | |
//   |_____/ \__|_|  |_|\__,_|\___| |______\___|_| |_|\__, |\__|_| |_|
//                                                     __/ |          
//                                                    |___/           

		if(info.currentCadence == null || info.currentCadence  == 0 || info.currentSpeed == null || info.currentSpeed == 0) {
			display.screenData.d_strideLength = null;
			//strideLengthField.setData(0.0); 
		} else {
			var sl = (info.currentSpeed * 60) / info.currentCadence;
			display.screenData.d_strideLength = sl.format("%.2f");
			//strideLengthField.setData(sl); 
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

			if(smoothSpeed == 0) {
				smoothSpeed = info.currentSpeed;
			}
			if(smoothSpeedCounter < PaceSmoothing) {
				smoothSpeedCounter++;
			}
			smoothSpeed = (smoothSpeed*(smoothSpeedCounter-1)/smoothSpeedCounter) + realPace/smoothSpeedCounter;
			//System.println("smoothpace " +  smoothpace.format("%.2f") +", currentSpeed " +  info.currentSpeed.format("%.2f") +", smoothSpeedCounter " +  smoothSpeedCounter);  
			display.screenData.d_smoothPace = fmtPace(smoothSpeed);

		}



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

    function fmtoppositePace(secs) {
        var s = (unitE/secs).toLong();
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




	function GetPwrColor(currentPwr) {
		if(currentPwr == 0) {
			return Graphics.COLOR_WHITE;
		}

        if( currentPwr <= (CriticalPower * 0.65)) { 
			return Graphics.COLOR_DK_GRAY; //zone 1
        } else if( currentPwr <= (CriticalPower * 0.8)) { 
        	return Graphics.COLOR_BLUE; //zone 2
        } else if( currentPwr <= (CriticalPower * 0.9)) { 
			return Graphics.COLOR_GREEN; //zone 3
        } else if( currentPwr <= (CriticalPower * 1.03)) { 
        	return Graphics.COLOR_ORANGE; //zone 4
        } else if( currentPwr <= (CriticalPower * 1.15)) { 
        	return Graphics.COLOR_RED; //zone 5
        } else if( currentPwr <= (CriticalPower * 1.3)) { 
        	return Graphics.COLOR_PURPLE; //zone 6
		} else {
			return Graphics.COLOR_PINK; //zone 7
		}
	}
		


	function GetHrColor(currentHeartRate) {
		if(hrZones == null) {
			return Graphics.COLOR_WHITE;
		}

        if( currentHeartRate >= hrZones[4]) { 
        	return Graphics.COLOR_RED;
		} else if( currentHeartRate >= hrZones[3]) {
			return Graphics.COLOR_ORANGE;
        } else if( currentHeartRate >= hrZones[2]) {
        	return Graphics.COLOR_GREEN;
        } else if( currentHeartRate >= hrZones[1]) {
        	return Graphics.COLOR_BLUE;
        } else if( currentHeartRate >= hrZones[0]) {
        	return Graphics.COLOR_DK_GRAY;
		}
		return Graphics.COLOR_WHITE;
	}


	var colorArray = [0xAA0000, 0xFF0000, 0xFF5500, 0xFFAA00, 0xFFFF00, 0xAAFF00, 0x00FF00, 0x00FF55, 0x00FFAA, 0x00FFFF, 0x00AAFF, 0x0055FF,0x00AAFF, 0x5500FF, 0xAA00FF, 0xFF00FF] as Lang.Array<Number>;
	var colorCount = colorArray.size();
	function GetColor(value, white, red, green, pink) {
		if(value <= white) {
			return Graphics.COLOR_WHITE;
		}

        if( value >= pink) { 
			return Graphics.COLOR_PINK;
        } else if(value > green) {
        	return Graphics.COLOR_GREEN;
		} else {
			return Graphics.COLOR_DK_RED;
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
			return Graphics.COLOR_YELLOW;
        } else if( currentHrPwr >= 30) {
        	return Graphics.COLOR_ORANGE;
        } else if( currentHrPwr >= 25) {
        	return Graphics.COLOR_RED;
		} else {
			return Graphics.COLOR_DK_RED;
		}
	}

	function GetCadenceColor(currentCadence) {

		//assume 180, step 5
		if(currentCadence  < WalkingCadence){ //walking
			return Graphics.COLOR_BLUE;
		} else if(currentCadence  < (TargetCadence - CadenceColorStep * 2)){ //170
			return Graphics.COLOR_RED;
		} else if(currentCadence  < (TargetCadence - CadenceColorStep)) { //175
			return Graphics.COLOR_ORANGE;
		} else if(currentCadence  < TargetCadence){ //<180
			return Graphics.COLOR_YELLOW;
		} else if(currentCadence  < (TargetCadence + CadenceColorStep)){  //<185
			return Graphics.COLOR_GREEN;
		} else { //>= 185
			return Graphics.COLOR_PURPLE;
		}
	}

	function GetDutyFactorColor(dutyFactor) {
		if(dutyFactor == 0) {
			return Graphics.COLOR_WHITE;
		}

        if( dutyFactor >= 45) { //walking
			return Graphics.COLOR_BLUE;
        } else if( dutyFactor >= 40) {
        	return Graphics.COLOR_DK_RED;
        } else if( dutyFactor >= 38) {
			return Graphics.COLOR_RED;
        } else if( dutyFactor >= 36) {
        	return Graphics.COLOR_ORANGE;
        } else if( dutyFactor >= 34) {
        	return Graphics.COLOR_YELLOW;
        } else if( dutyFactor >= 32) {
        	return Graphics.COLOR_GREEN;
		} else {
			return Graphics.COLOR_PURPLE;
		}
	}

	function GetHsiColor(hsi) {

		if(hsi  < 1.0){ 
			return Graphics.COLOR_BLUE;
		} else if(hsi < 3.0) {
			return Graphics.COLOR_YELLOW;
		} else if(hsi < 7.0) {
			return Graphics.COLOR_ORANGE;
		} else {
			return Graphics.COLOR_RED;
		} 
	}

}
