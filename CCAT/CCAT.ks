////////////////////////////////////////////////////////
// CONSTANTLY COMPUTED ATMOSPHERIC TRAJECTORY (CCAT)  //
// By Ren0k                                           //
////////////////////////////////////////////////////////
@lazyGlobal off.

clearscreen. clearvecdraws(). clearguis().                                          // Clear the KOS Console, vecdraws and guis

set config:ipu to 2000.                                                             // Set a CPU value

// LIBRARY
runpath("Library/atmoData/getAtmoData.ks").                                         // Atmospheric Data and Telemetry
runpath("Library/ODE.ks").                                                          // Ordinary Differential Equation Solvers
runpath("Library/Interpolation.ks").                                                // Interpolation Functions
runpath("Library/Orbit.ks").                                                        // Orbital Functions
runpath("CCAT/DragProfile/LIB/Profile.ks").                                         // Drag Profile function required for reynolds correction

//////////////////////////////////////////
// MAIN FUNCTION                       	//
//////////////////////////////////////////

function CCAT {
    // CLASS CCAT 
    parameter       solver is "RKDP54",
                    targetDT is 1,
                    runOnce is False,
                    useError is False,
                    targetError is 1,
                    endInObt is False,
                    exactAtmo is False,
                    useGUI is False,
                    vectorVis is False,
                    heightError is 3,
                    interpolateMethod is "linear",
                    profileName is ship:name,
                    bodyName is ship:body.

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////// This section calculates the future position
    // TRAJECTORIES   // For orbital trajectories, the future position is resolved analytically
    //////////////////// For atmospheric trajectories, the future position is calculated by integration using the ODE solver

    function getGravity {
        // PRIVATE getGravity :: float -> float
        // Returns gravitational acceleration in m/s^2 in relation to altitude above MSL
        // NOTE -> Parameter s0 is ALTITUDE, not radius
        parameter       s0.

        set gravAccel to bodyMu/(s0+bodyRadius)^2.  
        return gravAccel.
    }

    function getFutureSrfPosVec {
        // PRIVATE getFutureSrfPosVec :: nothing -> nothing
        // Updates geoposition, terrainheight and heightAGL as a function of time
        parameter       timeParam is elapsedTime.     

        set lngShift to (bodyAngVel*constant:radtodeg):mag*timeParam.                               // Calculating the longitude shift used to create a geoposition of the position vector
        set posGeo to bodyName:geopositionof(posVec+bodyName:position).                             // Creating an initial uncorrected geoposition of the position vector
        set posGeo to LatLng(posGeo:lat, posGeo:lng-lngShift).                                      // Correcting the geoposition for longitude shift due to rotation of the body
        set terrainHeight to max(posGeo:terrainheight,0).                                           // From the correct geoposition, terrainheight can be determined
        set heightAGL to heightMSL-terrainHeight-vesselHeight.                                      // With terrainheight, height above terrain can be determined
    }

    function getAcceleration {
        // PRIVATE getAcceleration :: list : float -> list
        // Returns the acceleration vector with magnitude in m/s^2 - used as the derivative function in the ODE solver
        parameter       values,
                        iterDT.

        local ovv is values[0].
        local pv is values[1].
        local s0 is max(pv:mag-bodyRadius,0).  
        local gv is -pv:normalized * getGravity(s0).
        local dv is V(0,0,0).
        if s0 < atmHeight {
            set tanVelVec to vcrs(bodyAngVel, pv).                                                  // Tangent velocity vector use for orb-srf vec translation
            set srfVelVec to ovv - tanVelVec.                                                       // Surface velocity vector calculated from orbit velocity vector
            set srfVel to srfVelVec:mag.                                                            // TAS or surface velocity
            updateAtmosphere(elapsedTime+iterDT, s0, srfVel, updateInterval).                       // Update atmospheric conditions
            set reynoldsNumber to posRHO*srfVel.                                                    // Pseudo-Reynolds number as used by a mach number float curve
            if (reynoldsNumber < 1) or (reynoldsNumber > 100) {
                set reynoldsCorrection to correctReynoldsCd(reynoldsNumber).                        // The actual reynolds correction to be applied as calculated by the function
            } else set reynoldsCorrection to 1.                                                     // Reynolds Numbers between 1 and 100 will return a value of 1 as per the curve
            local dragProfileMN is min(max(posMN, dragProfileStart), dragProfileStop-dragProfileDT).// Making sure that the used mach number fits the drag profile by limiting it to the size of the profile
            local index is floor(dragProfileMN/dragProfileDT).                                      // To get the correct index, divide machNumber by dT and round down to the nearest whole number
            local key0 is dragProfile[index].                                                       // This will be the 1st key value list
            local key1 is dragProfile[index+1].                                                     // The 2nd key value list, or index+1 (machNumber+(1/dT))
            set dragCubeCdA to interpolatorFunction(key0[0], key1[0], dragProfileMN).               // Interpolation of dragcube CdA
            set otherCdA to interpolatorFunction(key0[1], key1[1], dragProfileMN).                  // Interpolation of other CdA's
            set totalDrag to (((dragCubeCdA*reynoldsCorrection)+otherCdA)*posQ)/vesselMass.         // Acceleration in m/s^2 from drag

            set dv to -srfVelVec:normalized * totalDrag.                                            // Drag vector
        }
        local av is gv+dv.
        return list(av, ovv, pv).
    }

    function reverseIterate {
        // PRIVATE reverseIterate :: float : float -> nothing
        parameter       oldAlt,
                        newAlt.

        set loopCounter to loopCounter + 1.
        set ODEuseError to False.
        set elapsedTime to elapsedTime - dt.
        set dt to dt * (abs(oldAlt) / (abs(oldAlt) + abs(newAlt))).
        set posVec to oldPosVec:vec.
        set heightAGL to oldHeightAGL.
        set heightMSL to oldHeightMSL.
        set posGeo to oldPosGeo.

        if loopCounter > 50 {
            set sectionComplete to True.
        }
    }

    function nextIteration {
        // PRIVATE nextIteration :: float : float -> nothing
        // Old Values
        set oldPosVec to posVec:vec.
        set oldPosGeo to posGeo.
        set oldHeightAGL to heightAGL.
        set oldHeightMSL to heightMSL.

        // Time
        set curTime to kscUniversalTime + elapsedTime.

        // Vectors and Geoposition
        set obtVelVec to ODEresults[0]:vec.
        set tanVelVec to vcrs(bodyAngVel, posVec). 
        set srfVelVec to obtVelVec-tanVelVec.
        set srfVel to srfVelVec:mag.
        set srfPosVec to posGeo:altitudeposition(heightMSL)-bodyPosition. 
        if (ODEresults:haskey("Error")) {
            set ODEerror to ODEresults["Error"].
            if ODEuseError set dt to ODEerrorFX(dt, ODEerror, targetError).
        }
        if inATM updateAtmosphere(elapsedTime, heightMSL, srfVel, 0). 
    }


    function iterationTrajectory {
        // PRIVATE iterationTrajectory :: nothing -> nothing
        // This function uses the ODE solver to predict the future position
        parameter       measureHeight is {return heightMSL.},
                        oldMeasureHeight is {return oldHeightMSL.}.

        // Time
        set elapsedTime to elapsedTime + dt.
        // ODE Results
        set ODEresults to ODEsolverFX(getAcceleration@, list(obtVelVec, posVec), dt).
        // New Position and Height
        set posVec to ODEresults[1]:vec.
        set heightMSL to (posVec):mag-bodyRadius.  
        getFutureSrfPosVec(elapsedTime).

        if measureHeight() < (altTarget + heightError) {
            if measureHeight() > (altTarget - heightError) {
                set sectionComplete to True.
            } else {
                reverseIterate(oldMeasureHeight()-altTarget, measureHeight()-altTarget).
            }
        } else {
            if (heightMSL > atmHeight) and (inATM) {
                set sectionComplete to True.
            } else {
                nextIteration().
            }
        }

        if sectionComplete {
            nextIteration().
            set ODEuseError to masterManager["useError"].
            checkState().
        }
    }

    function orbitalTrajectory {
        // PRIVATE orbitalTrajectory :: nothing -> nothing
        // This function uses the orbit struct to determine the future position

        function setAltTarget {
            // PRIVATE setAltTarget :: float : float -> float
            parameter       currentAlt,
                            targetAlt.

            return altTarget + (targetAlt-currentAlt).
        }

        // Time
        set sectionLoopTime to timestamp():seconds - sectionStartTime.
        set loopCounter to loopCounter + 1.  
        // Results
        local nextOrbit is altitudeToOrbit(altTarget, curObt:position-body:position, curObt:velocity:orbit, bodyName, timestamp():seconds).
        // New Position
        set heightMSL to nextOrbit["Height MSL"].

        if hasATM {
            if (heightMSL < atmHeight) and (heightMSL > (atmHeight - heightError)) {
                set posVec to nextOrbit["Position"]-bodyName:position.
                getFutureSrfPosVec(elapsedTime + nextOrbit["Time"] - sectionLoopTime).
                set sectionComplete to True.
            } else {
                set altTarget to setAltTarget(heightMSL, atmHeight - (heightError/2)).
            }
        }
        else {
            set posVec to nextOrbit["Position"]-bodyName:position.
            getFutureSrfPosVec(elapsedTime + nextOrbit["Time"] - sectionLoopTime).
            if (heightAGL < heightError) and (heightAGL > - heightError) {
                set sectionComplete to True.
            } else {
                set altTarget to setAltTarget(heightAGL, 0).
            }
        }

        if loopCounter > 100 set sectionComplete to True.               // Prevents the function from getting stuck

        if sectionComplete {
            set posVec to nextOrbit["Position"]-bodyName:position.
            set obtVelVec to nextOrbit["Orbital Velocity Vector"].
            set srfVelVec to nextOrbit["Surface Velocity Vector"].
            set elapsedTime to elapsedTime + nextOrbit["Time"] - sectionLoopTime.
            set curTime to timestamp():seconds + elapsedTime.
            set curObt to nextOrbit["Next Orbit"].
            set dt to masterManager["targetDT"].
            set srfVel to srfVelVec:mag.
            set sectionComplete to False.
            checkState().
        }
    }


    // Body and Constants
    local bodyRadius is bodyName:radius.                                                            // The radius of the current celestial body in meters
    local bodyMu is bodyName:mu.                                                                    // Standard gravitational parameter of the current body μ (GM)
    local hasATM is bodyName:atm:exists.                                                            // Bool that indicates whether the body has an atmosphere
    local bodyAngVel is bodyName:angularvel.                                                        // The angular rotational velocity vector of the current body
    local atmHeight is bodyName:atm:height.                                                         // The height of the atmosphere of the current body in meters
    local molarmass is bodyName:atm:molarmass.                                                      // The molecular mass of 1 mol of the atmosphere's gas in kg/mol
    local adiabaticIndex is bodyName:atm:adiabaticindex.                                            // Adiabatic index γ equals the heat capacity ratio of atmospheric air
    local sgc is (constant:idealgas/molarmass).                                                     // Specific gas constant 
    local vesselHeight is ship:bounds:extents:mag*0.9.                                              // Distance from the vessel COM to the furthest corner used to determine an accurate Height above terrain
    local vesselMass is ship:mass*1000.                                                             // Weight of the vessel in kg

    // Vectors and Geoposition
    local bodyPosition is bodyName:position.                                                        // Recorded body position at the start of the simulation
    local startPosVec is (ship:position-bodyPosition).                                              // The starting position vector in the SOI reference frame
    local posVec is startPosVec.                                                                    // The current position vector in the SOI reference frame
    local oldPosVec is posVec.                                                                      // The position vector of last iteration
    local srfPosVec is startPosVec.                                                                 // The current position vector over the surface of the body
    local posGeo is ship:geoposition.                                                               // The geoposition of the current position vector
    local oldPosGeo is posGeo.                                                                      // Geoposition of the last iteration
    local upVector is (posGeo:position - bodyPosition):normalized.                                  // The local up vector at the current geoposition
    local srfVelVec is ship:velocity:surface.                                                       // The current surface velocity vector or TAS (True Airspeed) vector
    local obtVelVec is ship:velocity:orbit.                                                         // The current orbital velocity vector
    local tanVelVec is vcrs(bodyAngVel, ship:position-body:position).                               // Tangent velocity vector with body rotation  
    local curObt is orbitFromVector().                                                              // The current orbit in an Orbit Struct format

    // Scalars
    local lngShift is 0.                                                                            // Longitude shift in degrees per second
    local heightMSL is (posVec:mag-bodyRadius).                                                     // Current altitude or height above mean sea level in meters
    local oldHeightMSL is heightMSL.                                                                // Height above MSL for previous iteration
    local terrainHeight is max(posGeo:terrainheight,0).                                             // Current height of the terrain above mean sea level in meters
    local heightAGL is max(heightMSL-terrainHeight-vesselHeight,0).                                 // Current height above terrain in meters
    local oldHeightAGL is heightAGL.                                                                // Height above terrain for previous iteration
    local srfVel is srfVelVec:mag.                                                                  // Current surface velocity or TAS (True Airspeed) in m/s
    local gravAccel is bodyMu/posVec:mag^2.                                                         // Current gravitational acceleration in m/s^2
    local altTarget is 0.                                                                           // Altitude target to approximate position predictions

    // State
    local inATM is False.                                                                           // Boolean indication whether the current position vector is in atmospheric conditions
    local inOBT is True.                                                                            // Defines whether the current position is outside the atmosphere
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////// This section manages the loop and simulation sequence
    // SIMULATION     // 
    ////////////////////

    function checkState {
        // PRIVATE checkState :: nothing -> nothing
        // This function is called whenever a trajectory function is complete to determine the current 'state'
        set altTarget to 0.
        set loopCounter to 0.
        set sectionComplete to False.
        // IMPACT
        if heightAGL < heightError {                                                          
            simulationComplete().
            resetParameters().
        } else if (heightMSL > atmHeight) and endInObt {
            simulationComplete().
            resetParameters().
        }
        // CONDITIONAL
        // If in atmosphere
        if (heightMSL < atmHeight) and (hasATM) {                                                   
            set inATM to True.                                                                      
            set inOBT to False.                                                                                                                                 
            set masterFunctionManager["Trajectory"] to {iterationTrajectory({return heightAGL.}, {return oldHeightAGL.}).}.
            set endInObt to masterManager["endInObt"].
        // If in orbit
        } else {
            set inATM to False.
            set inOBT to True.
            set masterFunctionManager["Trajectory"] to orbitalTrajectory@.
            set curObt to orbitFromVector(posVec, obtVelVec, bodyName, curTime).
            set sectionStartTime to timeStamp():seconds.
        }              
        // If body has atmosphere 
        if hasATM { 	                                                                          
            updateAtmosphere(elapsedTime, heightMSL, srfVel, 0).                                    // Updating Temp for Latitude and Time 
            if inOBT set altTarget to atmHeight - (heightError / 2).                                // New altitude target just below the atm top
        }
        // If orbit is hyperbolic
        if (curObt:apoapsis < 0) and (curObt:eccentricity >= 1) {                                
            set masterFunctionManager["Trajectory"] to {iterationTrajectory({return heightMSL.}, {return oldHeightMSL.}).}.
            set altTarget to atmHeight - heightError.
            set endInObt to False.
        }
        // Utility functions to loop over
        if masterManager["UseGUI"] set masterFunctionManager["GUI"] to manageGUIS@.
        else if masterFunctionManager:haskey("GUI") masterFunctionManager:remove("GUI").

        if masterManager["vectorVis"] set masterFunctionManager["Vecdraw"] to manageVecDraws@.
        else if masterFunctionManager:haskey("Vecdraw") masterFunctionManager:remove("Vecdraw").

    }

    function resetParameters {
        // PRIVATE resetParameters :: nothing -> nothing
        // When the simulation is finished, all parameters are reset to the current position and state
        parameter       runOnce is runOnce.

        // Simulation
        set dt to masterManager["targetDT"].
        set kscUniversalTime to timestamp():seconds.
        set sectionStartTime to kscUniversalTime.
        set sectionLoopTime to 0.
        set kscMissionTime to missionTime.
        set curTime to kscUniversalTime.
        set loopTimer to 0.
        set elapsedTime to 0.
        set sectionComplete to False.
        set latency to 0.
        set oldTime to kscUniversalTime.
        set exactAtmo to masterManager["exactAtmo"].
        set endInObt to masterManager["endInObt"].
        if exactAtmo set updateInterval to 0.
        else set updateInterval to 100.
        // Drag Profile
        set ODEsolverFX to lib_ODEsolver[masterManager["solver"]]().
        set ODEerrorFX to lib_ODEerror(masterManager["solver"]).
        set interpolatorFunction to lib_interpolationFunctions[masterManager["interpolateMethod"]].
        set ODEerror to 1.
        set ODEuseError to masterManager["useError"].
        set targetError to masterManager["targetError"].
        set totalDrag to 0.
        // New Constants
        set vesselMass to ship:mass*1000.
        // Vectors and Geoposition
        set bodyPosition to bodyName:position.
        set startPosVec to (ship:position-bodyName:position).
        set posVec to startPosVec:vec.
        set oldPosVec to posVec:vec.
        set srfPosVec to posVec:vec.
        set posGeo to ship:geoposition.
        set oldPosGeo to posGeo.
        set upVector to (posGeo:position - bodyName:position):normalized.
        set srfVelVec to ship:velocity:surface.
        set obtVelVec to ship:velocity:orbit.
        set tanVelVec to vcrs(bodyAngVel, ship:position-body:position). 
        set curObt to orbitFromVector().                                                                              
        // Scalars
        set lngShift to 0.
        set heightMSL to max(posVec:mag-bodyRadius,0).
        set oldHeightMSL to heightMSL.
        set terrainHeight to max(posGeo:terrainheight,0).
        set heightAGL to max(heightMSL-terrainHeight-vesselHeight, 0).
        set oldHeightAGL to heightAGL.
        set srfVel to srfVelVec:mag.
        set gravAccel to getGravity(heightMSL).
        set altTarget to 0.
        // Runtime
        if runOnce set masterManager["Masterswitch"] to True.       
        else set masterManager["Masterswitch"] to False.                     
    }

    // Simulation Variables
    local dt is targetDT.                                                                           // ΔT which can vary from the initial ΔT
    local kscUniversalTime is timestamp():seconds.                                                  // Universal KSC time at simulation start
    local sectionStartTime is kscUniversalTime.                                                     // UT Time a trajectory function starts iterating
    local sectionLoopTime is 0.                                                                     // Time in seconds since the start of the section
    local kscMissionTime is missionTime.                                                            // Mission time i.e. the time in the top left time window or time since the mission start
    local curTime is kscUniversalTime.                                                              // Current universal KSC time used for calculations
    local loopTimer is 0.                                                                           // Time in seconds it takes to complete a full calculation
    local elapsedTime is 0.                                                                         // Elapsed actual time since the beginning of the simulation or ∑ΔT
    local loopCounter is 0.                                                                         // Counts the amount of iterations and is used for some conditions
    local sectionComplete is False.                                                                 // Bool that determines if the simulation is finished
    local latency is 0.                                                                             // Time it takes per iteration
    local oldTime is kscUniversalTime.                                                              // Previous time used for latency calculation

    // Variable and Function manager
    local masterManager is lexicon(                                                                 // Lexicon used for control of the simulation from the outside (GUI)
        "profileName", profileName,
        "bodyName", bodyName,
        "targetDT", targetDT,
        "solver", solver,
        "useError", useError,
        "targetError", targetError,
        "heightError", heightError,
        "interpolateMethod", interpolateMethod,
        "endInObt", endInObt,
        "useGUI", useGUI,
        "vectorVis", vectorVis,
        "exactAtmo", exactAtmo,
        "Masterswitch", False,
        "updateVAR", False
    ). 
    local masterFunctionManager is lexicon().                                                       // All functions in this lexicon will be executed by the main loop
    set masterFunctionManager["Latency"] to {                                                       // Used to check the latency or calculation time of the loop
        set latency to timestamp():seconds - oldTime.
        set oldTime to timestamp():seconds.}.

    // Time
    local TTI is 0.                                                                                 // Time To Impact (TTI) equals the total elapsed time of the simulation minus the elapsed time of calculation
    local TTIU is kscUniversalTime.                                                                 // Time of impact in universal ksc time
    local TTIM is secondsToClock(0).                                                                // Time of impact in mission time as a String

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////// This section sets up the use of a created drag profile
    // DRAG PROFILE   //
    ////////////////////

    local dragProfile is lib_loadProfile(profileName).                                              // A 2D Array representing the dragProfile of the current vessel
    local dragProfileDT is dragProfile["dT"].                                                       // The ΔT used in the dragProfile
    local dragProfileStart is dragProfile["startMach"].                                             // Mach number from which the drag profile can be used
    local dragProfileStop is dragProfile["endMach"].                                                // Highest mach number where the drag profile can be used
    local correctReynoldsCd is lib_DragProfile["getReynolds"](0.5).                                 // A function used to calculate a reynolds number correction to drag cube drag
    local reynoldsNumber is 0.                                                                      // Pseudo-Reynolds number as used by a mach number float curve
    local reynoldsCorrection is 0.                                                                  // The actual reynolds correction to be applied as calculated by the function
    local interpolatorFunction is lib_interpolationFunctions[interpolateMethod].                    // Hermite Interpolator function
    local ODEsolverFX is lib_ODEsolver[solver]().                                                   // ODE Solver Function
    local ODEerrorFX is lib_ODEerror(solver).                                                       // ODE Error Function
    local ODEresults is lexicon().                                                                  // ODE Results
    local dragCubeCdA is 0.                                                                         // CdA value of drag cubes
    local otherCdA is 0.                                                                            // CdA value of non drag cubes
    local totalDrag is 0.                                                                           // Total drag force
    local ODEerror is 1.                                                                            // Error from the ODE                                                            
    local ODEuseError is useError.                                                                  // Use a constant error?

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////// This section contains all functions and variables needed for atmospheric data
    // ATMOSPHERE     //
    ////////////////////

    function updateAtmosphere {
        // PRIVATE updateAtmosphere :: float : float : float : float -> nothing
        // Updates the atmospheric conditions at the current position
        parameter       updateATMTime is elapsedTime,
                        updateATMHeightMSL is heightMSL,
                        updateATMVel is srfVel,
                        updateATMInterval is updateInterval.

        if updateATMHeightMSL < atmHeight {
            if exactAtmo getFutureSrfPosVec(updateATMTime).
            set posSAT to getSAT(min(updateATMHeightMSL, atmHeight-1),                                  // Static Air Temperature obtained from interpolation #1
                posGeo, updateATMTime, updateATMInterval).                                              // #2 
            set posPRES to bodyName:atm:altitudepressure(min(updateATMHeightMSL,                        // Pressure in pa from the altitudepressure method #1
                atmHeight-1))*constant:atmtokpa*1000.                                                   // #2
            set posRHO to (posPRES/(sgc*posSAT)).                                                       // Density obtained by dividing pressure by the product of sgc and sat
            set posVM to (sqrt(adiabaticIndex * sgc * posSAT)).                                         // Local speed of sound in m/s obtained by multiplying the square root of γ, sgc and sat
            set posMN to updateATMVel/posVM.                                                            // Mach number obtained by dividing TAS by the local speed of sound
            set posQ to (0.5 * posRHO * updateATMVel^2).                                                // Dynamic pressure in pa obtained by multiplying TAS squared by density and 1/2
        } else {
            set posSAT to 4.
            set posPRES to 0.
            set posRHO to 0.
            set posVM to 0.
            set posMN to 0.
            set posQ to 0.
        }
    }

    local updateInterval is choose 0 if exactAtmo else 100.                                         // How often is time/geoposition updated?
    local getSAT is choose lib_atmosphericData["getSAT"](True) if hasATM else {return 4.}.          // Static Air Temperature Function
    local posSAT is 4.                                                                              // Static Air Temperature at the current position
    local posPRES is 1.                                                                             // Atmospheric pressure at the current position in pa
    local posRHO is 1.                                                                              // Density at the current position in kg/m^3
    local posVM is 1.                                                                               // Local speed of sound at the current position in m/s
    local posMN is 1.                                                                               // Mach number at the current position
    local posQ is 1.                                                                                // Dynamic pressure at the current position in pa

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////// This section contains variables and functions required to save the final state of the simulation
    // FINAL POSITION //
    ////////////////////

    function simulationComplete {
        // PRIVATE simulationComplete :: nothing -> nothing
        // When the simulation is finished the final state is recorded for output
     
        set loopTimer to timestamp():seconds - kscUniversalTime.
        set heightErrorTotal to (finalPosGeo:position-posGeo:position):mag.
        set heightErrorRate to round(heightErrorTotal/loopTimer,2).
        set finalPos to posVec.
        set finalPosGeo to posGeo.
        set finalSrfVelVec to srfVelVec.
        set finalObtVelVec to obtVelVec.
        set finalHeightAGL to heightAGL.
        set finalHeightMSL to heightMSL.
        set upVector to (posGeo:position - bodyName:position):normalized.

        set TTIU to kscUniversalTime + elapsedTime.
        set TTI to TTIU - timestamp():seconds.
        set TTIM to secondsToClock(missionTime + elapsedTime).

        updateVariables().
        updateImpactVariables().
    }      

    local finalPos is posVec.                                                                       // Last recorded position vector before simulation termination
    local finalPosGeo is posGeo.                                                                    // Last recorded geoposition before simulation termination
    local finalSrfVelVec is srfVelVec.                                                              // Last recorded surface velocity vector before simulation termination
    local finalObtVelVec is obtVelVec.                                                              // Last recorded orbit velocity vector before simulation termination
    local finalHeightMSL is heightMSL.                                                              // Last recorded Altitude
    local finalHeightAGL is heightAGL.                                                              // Last recorded Height
    local heightErrorTotal is 0.                                                                    // Distance between last recorded impact position and current
    local heightErrorRate is 0.                                                                     // Rate of the impact error change

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////// This section is used mainly for the GUI to display real time information
    // TELEMETRY      //
    ////////////////////

    function updateParameters {
        // PRIVATE updateParameters :: nothing -> nothing
        // Creates fixed values in the lexicon
        set parameterLexicon["Body Name"] to masterManager["bodyName"]:tostring.
        set parameterLexicon["Profile Name"] to masterManager["profileName"]:tostring.
        set parameterLexicon["ODE Solver"] to masterManager["solver"]:tostring.
        set parameterLexicon["Interpolation Method"] to masterManager["interpolateMethod"]:tostring.
        set parameterLexicon["ODE Constant Error"] to masterManager["useError"]:tostring.
        set parameterLexicon["Impact Height Error"] to masterManager["heightError"]:tostring.
        set parameterLexicon["Stop in Orbit"] to masterManager["endInObt"]:tostring.
        set parameterLexicon["UseGUI"] to masterManager["useGUI"]:tostring.
        set parameterLexicon["Vecdraws"] to masterManager["vectorVis"]:tostring.
    }

    function updateVariables {
        // PRIVATE updateVariables :: nothing -> nothing
        // Creates all variable values in the lexicon
        set variableLexicon["Loop Counter"] to loopCounter:tostring.
        set variableLexicon["Current Time"] to round(curTime,2):tostring.
        set variableLexicon["Mission Time"] to secondsToClock(kscMissionTime + elapsedTime).
        set variableLexicon["Elapsed Time"] to round(elapsedTime,2):tostring.
        set variableLexicon["Delta-T"] to round(dt,5):tostring.
        set variableLexicon["ODE Error"] to round(ODEerror,5):tostring.
        set variableLexicon["Latency"] to round(latency,5):tostring.
        set variableLexicon["Vessel Mass"] to round(vesselMass,2):tostring.
        set variableLexicon["Height MSL"] to round(heightMSL,2):tostring.
        set variableLexicon["Height AGL"] to round(heightAGL,2):tostring.
        set variableLexicon["Surface Velocity"] to round(srfVelVec:mag,2):tostring.
        set variableLexicon["Orbital Velocity"] to round(obtVelVec:mag,2):tostring.
        set variableLexicon["Temperature"] to round(posSAT,2):tostring.
        set variableLexicon["Pressure"] to round(posPRES,2):tostring.
        set variableLexicon["Density"] to round(posRHO,2):tostring.
        set variableLexicon["Speed of Sound"] to round(posVM,2):tostring.
        set variableLexicon["Mach Number"] to round(posMN,2):tostring.
        set variableLexicon["Dynamic Pressure"] to round(posQ,2):tostring.
        set variableLexicon["Reynolds Number"] to round(reynoldsNumber,2):tostring.
        set variableLexicon["Reynolds Correction"] to round(reynoldsCorrection,2):tostring.
        set variableLexicon["Drag Cube CdA"] to round(dragCubeCdA,2):tostring.
        set variableLexicon["Other CdA"] to round(otherCdA,2):tostring.
        set variableLexicon["Drag Force Acceleration"] to round(totalDrag,2):tostring.
        set variableLexicon["Longitude Shift"] to round(lngShift,5):tostring.
        set variableLexicon["Gravity"] to round(gravAccel,5):tostring.
    }

    function updateImpactVariables {
        // PRIVATE updateVariables :: nothing -> nothing
        // Creates all variables related to the final position in the info lexicon
        set finalPositionLexicon["Impact Altitude"] to round(finalHeightMSL,2):tostring.
        set finalPositionLexicon["Impact Height"] to round(finalHeightAGL,2):tostring.
        set finalPositionLexicon["Impact Velocity"] to round(finalSrfVelVec:mag,2):tostring.
        set finalPositionLexicon["Time to Impact"] to round(TTI,2):tostring.
        set finalPositionLexicon["Universal Time of Impact"] to round(TTIU,2):tostring.
        set finalPositionLexicon["Mission Time of Impact"] to TTIM.
        set finalPositionLexicon["Impact Error"] to heightErrorTotal:tostring.
        set finalPositionLexicon["Impact Error Rate"] to heightErrorRate:tostring.
    }

    local parameterLexicon is lexicon().                                                            // Lexicon that contains all parameters
    local variableLexicon is lexicon().                                                             // Lexicon that contains variables
    local finalPositionLexicon is lexicon().                                                        // Lexicon that contains impact information
    if useGUI updateParameters().

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////// This section manages vector draws
    // VECDRAWS       //
    ////////////////////

    function manageVecDraws {
        // PRIVATE manageVecDraws :: nothing -> nothing
        // Updates all vecdraws in the lexicon when called
        set vdrawLexicon[0]:start to finalPosGeo:position.
        set vdrawLexicon[0]:vec to upVector*250.
        set vdrawLexicon[1]:start to (srfPosVec + bodyPosition).
        set vdrawLexicon[1]:vec to srfVelVec*10.
        set vdrawLexicon[2]:start to (posVec + bodyPosition).
        set vdrawLexicon[2]:vec to obtVelVec.
    }

    local vdrawLexicon is lexicon().                                                                
    local vecdraw1 is vecdraw(V(0,0,0), up:vector*250, RGB(1,0,0), "Impact Position", 1, vectorVis, 0.2, true, true).
    set vdrawLexicon[0] to vecdraw1.
    local vecdraw2 is vecdraw(V(0,0,0), up:vector*100, RGB(0,1,0), "Surface Position Vector", 1, vectorVis, 0.2, true, true).
    set vdrawLexicon[1] to vecdraw2.
    local vecdraw3 is vecdraw(V(0,0,0), up:vector*100, RGB(0,0,1), "Orbit Position Vector", 1, vectorVis, 0.2, true, true).
    set vdrawLexicon[2] to vecdraw3.
    if vectorVis {                                                                                  
        for vd in range(vdrawLexicon:values:length) set vdrawLexicon[vd]:SHOW to True.
        set masterFunctionManager["Vecdraw"] to manageVecDraws@.
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////// This section will load and update the user interface
    // USER INTERFACE //
    ////////////////////

    function manageGUIS {
        // PRIVATE manageGUIS :: nothing -> nothing
        // Updates information for guis presented in the lexicon
        if masterManager["updateVAR"] {
            updateParameters().
            updateVariables().
        }
        updateCCATGUI(parameterLexicon, variableLexicon, finalPositionLexicon, masterManager["updateVAR"]).
    }

    if useGUI {                                                                                     
        runpath("CCAT/GUI/ccatmenu.ks").
        updateVariables().
        updateImpactVariables().
        CCATGUI(parameterLexicon, variableLexicon, finalPositionLexicon, vdrawLexicon, masterManager).
        manageGUIS().
        set masterFunctionManager["GUI"] to manageGUIS@.
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////// The main loop 
    // MAIN LOOP      //
    ////////////////////

    checkState().     

    function singleIteration {
        // PUBLIC Iterate :: nothing -> nothing
        // Call this function to perform one iteration
        for FX in masterFunctionManager:values FX().
    }

    function continuousIteration {
        // PUBLIC Iterate :: nothing -> nothing
        // Call this function to perform continuous iterations
        until masterManager["masterSwitch"] {
            for FX in masterFunctionManager:values FX().
        }
    }

    function restartSimulation {
        // PUBLIC restartSimulation :: nothing -> nothing
        // Call this function to start a new simulation
        resetParameters(False).
        checkState().
    }

    function getFinalPosition {
        // PUBLIC getFinalPosition :: nothing -> lexicon
        // Call this function to return a lexicon with final position information
        return lexicon(
            "Surface Velocity Vector", finalSrfVelVec,
            "Orbit Velocity Vector", finalObtVelVec,
            "Position", finalPos,
            "Geoposition", finalPosGeo,
            "Height MSL", finalHeightMSL,
            "Height AGL", finalHeightAGL,
            "Time to Impact", TTI,
            "Time of Impact", TTIU,
            "Mission Time of Impact", TTIM
        ).
    }

    return lexicon(
        "singleIteration", singleIteration@,
        "continuousIteration", continuousIteration@,
        "restartSimulation", restartSimulation@,
        "simulationFinished", {return masterManager["Masterswitch"].},
        "getFinalPosition", getFinalPosition@
    ).
}

// solver : targetDT : runOnce : useError : targetError : endInObt : exactAtmo : useGUI : vectorVis : heightError : interpolateMethod : profileName : bodyName

local CCATFX is CCAT( 
    "RKDP54",
    1,
    False,
    True,
    1,
    False,
    False,
    True,
    True,
    3,
    "Linear",
    ship:name,
    ship:body
).

CCATFX["continuousIteration"]().

