//////////////////////////////////////////
// Drag Profile                        //
// By Ren0k                             //
//////////////////////////////////////////
@lazyGlobal off.

clearscreen. clearvecdraws(). clearguis().                              // Clear the KOS Console, vecdraws and guis
//set config:ipu to 2000.                                                 // Set your IPU

// LIBRARY
runpath("dragProfile/LIB/GUItools.ks").                                 // GUI creation
runpath("dragProfile/GUI/profileMenu.ks").                              // Menu for drag profiles
runpath("dragProfile/GUI/analysisMenu.ks").                             // Menu for ship analysis
runpath("dragProfile/LIB/Analysis.ks").                                 // Ship Analysis Function
runpath("dragProfile/LIB/Profile.ks").                                  // Drag Profile Calculations
runpath("dragProfile/LIB/Telemetry.ks").                                // Atmospheric Data and Telemetry
runpath("dragProfile/DATA/PartDatabase/ExtraDatabase.ks").              // Database for additional part information

//////////////////////////////////////////
// FUNCTIONS                        	//
//////////////////////////////////////////

///// WITH USER INTERFACE /////
function runUserInterface {
    // PUBLIC runUserInterface :: nothing -> 2D Array
    local vesselPartList is analysisMenu().
    local dragProfile is profileMenu(vesselPartList).
    return dragProfile.
}

///// WITHOUT USER INTERFACE /////
function example_CreateProfile {
    // PUBLIC example_CreateProfile :: bool : float : float : float : string : string : string : string: float : float : string -> 2D Array
    // EXAMPLE -> example_CreateProfile(True, 0, 1, 0.01).
    parameter       Scan is True,
                    machStart is 0,
                    machEnd is 10,
                    dT is 0.01,
                    Gears is "Up",
                    Airbrakes is "Retracted",
                    Aerosurfaces is "Retracted",
                    Parachutes is "Idle",
                    CustomAoA is 0,
                    CustomAoAYaw is 0,
                    Profile is "Retrograde".


    local parametersCollection is lexicon(
        "Scan", Scan,
        "Gears", Gears,
        "Airbrakes", Airbrakes,
        "AeroSurfaces", Aerosurfaces,
        "Parachutes", Parachutes,
        "Custom AoA", CustomAoA,
        "Custom AoA Yaw", CustomAoAYaw,
        "Profile", Profile,
        "Mach Start", machStart,
        "Mach End", machEnd,
        "dT", dT
    ).   

    local vesselPartList is lib_getVesselAnalysis["executeAnalysis"](parametersCollection).
    local dragProfile is lib_DragProfile["createProfile"](vesselPartList, parametersCollection)["getDragProfile"](machStart, machEnd, dT).

    return dragProfile.
}

//////////////////////////////////////////
// Execution                        	//
//////////////////////////////////////////

runUserInterface().
