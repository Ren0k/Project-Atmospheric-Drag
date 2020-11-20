//////////////////////////////////////////
// Use Drag Profile                     //
// By Ren0k                             //
//////////////////////////////////////////
@lazyGlobal off.

clearscreen. clearvecdraws(). clearguis().                  // Clear the KOS Console, vecdraws and guis

// LIBRARY
runpath("dragProfile/LIB/Telemetry.ks").                    // Atmospheric Data and Telemetry
runpath("dragProfile/LIB/Profile.ks").                      // Drag Profile Calculations

// IPU SETTINGS
//set config:ipu to 2000.                                     // Set your IPU

//////////////////////////////////////////
// HELPER FUNCTIONS                     //
//////////////////////////////////////////

function loadProfile {
    // PUBLIC loadProfile :: string -> 2D Array
    // Loads profile if found; returns nothing if not found
    parameter       profileName is ship:name.

    if (exists("dragProfile/DATA/Profiles/"+profileName)) {
        return readjson("dragProfile/DATA/Profiles/"+profileName).
    } else print("Profile not found!").
}

function interpolateDrag {
    // PRIVATE interpolateDrag :: list : list : float -> float
    // Most accurate way to determine drag, but slowest
    parameter       keyValues1, keyValues2, value.

    local x0 is keyValues1[0].
    local x1 is keyValues2[0].
    local y0 is keyValues1[1].
    local y1 is keyValues2[1].
    local m0 is keyValues1[3].
    local m1 is keyValues2[2].

    return hermiteInterpolator(x0, x1, y0, y1, m0, m1, value).
}

function linearDrag {
    // PRIVATE linearDrag :: list : list : float -> float
    // Faster way to determine drag, less accurate
    parameter       keyValues1, keyValues2, value.

    local x0 is keyValues1[0].
    local x1 is keyValues2[0].
    local y0 is keyValues1[1].
    local y1 is keyValues2[1].

    return ((value*(x1-x0))*(y1-y0))+y0.
}

function roundingMethod {
    ///// EXAMPLE ROUNDING METHOD /////
    // The fastest method, least accurate
    local index is round((machNumber/dT),0).
    local dragCubeCdA is craftDragProfile[index][0][1].
    local otherCdA is craftDragProfile[index][1][1].
    local totalDrag is ((dragCubeCdA*reynoldsCorrection)+otherCdA)*dynamicPressure. 
    return totalDrag.
}

//////////////////////////////////////////
// EXECUTION                        	//
//////////////////////////////////////////

///// INIT /////
// PROFILE
local craftDragProfile is loadProfile(ship:name).                                   // Loading the profile; input the name of the profile
local startMach is craftDragProfile["startMach"].                                   // Mach Number at which the profile starts
local endMach is craftDragProfile["endMach"].                                       // Mach Number at which the profile ends
local dT is craftDragProfile["dT"].                                                 // dT or Mach-Stepsize of the profile

// DATA
local correctReynoldsCd is lib_DragProfile["getReynolds"](0.5).                     // Reynolds Corrector function
local hermiteInterpolator is lib_DragProfile["hermiteInterpolator"].                // Hermite Interpolator function
local TAS is ship:velocity:surface:mag.                                             // True Airspeed
local AMSL is ship:altitude.                                                        // Altitude Mean Sea Level
local SGP is ship:geoposition.                                                      // Ship Geoposition
local getSAT is lib_AtmosphericFlightData["getTemperatureX"]().                     // Static Air Temperature function with a selectable update rate  
local SAT is getSAT(SGP, AMSL, 0, 10).                                              // Static Air Temperature
local getFlightData is lib_AtmosphericFlightData["getData"].                        // Flight Data function
local flightData is getFlightData(TAS, AMSL, SGP, 0, SAT).                          // Flight Data
local machNumber is flightData["MN"].                                               // Mach Number
local density is flightdata["RHO"].                                                 // Density in kg/m^3
local dynamicPressure is flightdata["Q"].                                           // Dynamic Pressure

// VARS
local currentTime is time:seconds.                                                  // Recording current time
local elapsedTime is 0.                                                             // Recording elapsed time
local counter is 0.                                                                 // Counts number of updates

///// LOOP /////
function showDrag {
    // FLIGHTDATA
    set TAS to ship:velocity:surface:mag.
    set AMSL to ship:altitude.
    set SGP to ship:geoposition.
    set SAT to getSAT(SGP, AMSL, 0, 10).  
    set flightData to getFlightData(TAS, AMSL, SGP, 0, SAT).
    set machNumber to flightData["MN"].
    set density to flightdata["RHO"].
    set dynamicPressure to flightdata["Q"].   

    // LOOP RESTRICTIONS
    // IMPORTANT -> If the mach number goes outside the mach range an exception occurs
    if (machNumber < startMach) set machNumber to startMach.
    else if (machNumber > (endMach-dT)) set machNumber to (endMach-dT).

    // REYNOLDS
    local reynoldsNumber is density*TAS.
    local reynoldsCorrection is correctReynoldsCd(reynoldsNumber).

    // PROFILE
    local index is floor(machNumber/dT).                                                // To get the correct index, divide machNumber by dT and round down to the nearest whole number
    local key0 is craftDragProfile[index].                                              // This will be the 1st key value list
    local key1 is craftDragProfile[index+1].                                            // The 2nd key value list, or index+1 (machNumber+(1/dT))

    ///// INTERPOLATION METHOD /////
    local dragCubeCdA is interpolateDrag(key0[0], key1[0], machNumber).                 // Interpolation  of dragcube CdA
    local otherCdA is interpolateDrag(key0[1], key1[1], machNumber).                    // Interpolation of other CdA's
    local totalDrag is ((dragCubeCdA*reynoldsCorrection)+otherCdA)*dynamicPressure.     // Note how reynolds correction is only applied to dragcube drag  

    // VARS
    set counter to counter+1.
    if counter > 100 {
        set elapsedTime to time:seconds-currentTime.
        set currentTime to time:seconds.
        set counter to 0.
    }

    // INFORMATION
    clearScreen.
    print("===DRAG DATA===").
    print("Reynolds Correction = " + reynoldsCorrection).
    print("key0 = " + key0).
    print("key1 = " + key1).
    print("dragCubeCdA = " + dragCubeCdA).
    print("otherCdA = " + otherCdA).
    print("totalDrag= " + totalDrag).
    print("Latency = " + elapsedTime).
    print("===FLIGHT DATA===").
    print("TAS = " + TAS).
    print("Mach = " + machNumber).
    print("Density = " + density).
    print("Reynolds = " + reynoldsNumber).
    print("SAT = " + SAT).
}

until false {
    showDrag().
}