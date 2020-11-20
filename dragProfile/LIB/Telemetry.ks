//////////////////////////////////////////
// Telemetry                            //
// By Ren0k                             //
//////////////////////////////////////////
@lazyGlobal off.

// Requirements
runpath("atmoData/getAtmoData.ks").                             // This will import the temperature model
local getSAT is lib_atmosphericData["getSAT"](False).           // Importing the correct function

function get_AtmosphericFlightData {
    // PUBLIC get_AtmosphericFlightData :: nothing -> lexicon

    function getTemperature {
        // PUBLIC getTemperature :: geoposition : float : float -> float
        // Returns temperature, checks every update for geoposition and time
        parameter       location is ship:geoposition,
                        shipAltitude is ship:altitude,
                        futureTime is 0.

        return getSAT(shipAltitude, location, futureTime).
    }

    function getTemperatureX {
        // PUBLIC getTemperatureX :: nothing -> kosDelegate
        // Returns temperature
        // It reduces the 'update rate' of latitude dependant curves by a set amount, without any noticable precision reduction
        set getSAT to lib_atmosphericData["getSAT"](True).

        return {// kosDelegate :: geoposition : float : float : float -> float
            parameter       location is ship:geoposition,
                            shipAltitude is ship:altitude,
                            futureTime is 0,
                            updateInterval is 10.

            return getSAT(shipAltitude, location, futureTime, updateInterval).
            }.
    }

    function getPressure {
        // PUBLIC getPressure :: float -> float
        parameter       shipAltitude is ship:altitude,
                        shipBody is ship:body.

        return shipBody:atm:altitudepressure(shipAltitude)*constant:atmtokpa*1000.
    }

    function getDensity {
        // PUBLIC getDensity :: nothing -> float
        parameter       Pres is getPressure(),
                        Temp is getTemperature(),
                        shipBody is ship:body.

        local sgc is (constant:idealgas/shipBody:atm:molarmass).
        return ((max(Pres, 0.01))/(sgc*Temp)).
    }

    function getOAT {
        // PUBLIC getOAT :: nothing -> float
        parameter       Temp is getTemperature().
        return Temp-273.15.
    }

    function getVM {
        // PUBLIC getVM :: nothing -> float
        parameter       Temp is getTemperature(),
                        shipBody is ship:body.

        return (sqrt(shipBody:atm:adiabaticindex * (constant:idealgas/shipBody:atm:molarmass) * Temp)).
    }

    function getMachNumber {
        // PUBLIC getMachNumber :: float -> float
        parameter       TAS is ship:velocity:surface:mag,
                        Temp is getTemperature().

        return TAS/getVM(Temp).
    }

    function getEAS {
        // PUBLIC getEAS :: float -> float
        parameter       TAS is ship:velocity:surface:mag,
                        Rho is getDensity().

        return (TAS / sqrt(1.225/Rho)).
    }

    function getAllData {
        // PUBLIC getAllData :: float : float : geoposition : float -> lexicon
        // Returns all of the above plus some additional items

        parameter       TAS is ship:velocity:surface:mag,
                        shipAltitude is ship:altitude,
                        location is ship:geoposition,
                        futureTime is 0,
                        SAT is getTemperature(location, shipAltitude, futureTime),
                        shipBody is ship:body.

        local sgc is (constant:idealgas/shipBody:atm:molarmass).
        local OAT is SAT-273.15.
        local PRES is max(getPressure(shipAltitude), 0.01).
        local RHO is (PRES/(sgc*SAT)).
        local VM is (sqrt(shipBody:atm:adiabaticindex * (constant:idealgas/shipBody:atm:molarmass) * SAT)).
        local MN is TAS/VM.  
        local EAS is (TAS / sqrt(1.225/RHO)).
        local dynamicPressure is 0.5 * RHO * TAS^2.

        return lexicon(
            "SAT", SAT,
            "OAT", OAT,
            "PRES", PRES,
            "RHO", RHO,
            "VM", VM,
            "MN", MN,
            "EAS", EAS,
            "TAS", TAS,
            "Q", dynamicPressure
        ).
    }

    return lexicon (
        "getTemperature", getTemperature@,
        "getTemperatureX", getTemperatureX@,
        "getPressure", getPressure@,
        "getDensity", getDensity@,
        "getOAT", getOAT@,
        "getVM", getVM@,
        "getMach", getMachNumber@,
        "getEAS", getEAS@,
        "getData", getAllData@
    ).
}

global lib_AtmosphericFlightData is get_AtmosphericFlightData().

function get_VesselOrientation {
    // PUBLIC get_AtmosphericFlightData :: nothing -> lexicon

    function getRoll {
        // PUBLIC getRoll :: nothing -> float
        local sideDirection is vcrs(up:vector, facing:forevector).
        local arcVal1 is vdot(facing:topvector, sideDirection).
        local arcVal2 is vdot(facing:starvector, sideDirection).
        return arctan2(arcVal1, arcVal2).
    }

    function getPitch {
        // PUBLIC getPitch :: nothing -> float
        return 90-vang(up:forevector, facing:forevector).
    }

    function getHeading {
        // PUBLIC getHeading :: nothing -> float
        return mod(360-ship:bearing,360).
    }

    function relBearing {
        // PUBLIC relBearing :: float : float -> float
        parameter   targetHeading,
                    curHeading is getHeading().
        
        return mod((targetHeading - curHeading + 540), 360)-180.
    }

    function rotateQuaternion {
        // PUBLIC rotateQuaternion :: vector : float : float : float -> vector
        parameter       inputVec,
                        pitch,
                        yaw,
                        roll.

        local cr is cos(yaw/2).
        local cp is cos(pitch/2).
        local cy is cos(-roll/2).
        local sr is sin(yaw/2).
        local sp is sin(pitch/2).
        local sy is sin(-roll/2).
        local cpcy is cp * cy.
        local spsy is sp * sy.
        local w is (cr * cpcy + sr * spsy).
        local x is (sr * cpcy - cr * spsy).
        local y is (cr * sp * cy + sr * cp * sy).
        local z is (cr * cp * sy - sr * sp * cy).

        return (inputVec:direction + Q(x,y,z,w)):vector.
    }

    return lexicon (
        "getRoll", getRoll@,
        "getPitch", getPitch@,
        "getHeading", getHeading@,
        "getRelBearing", relBearing@,
        "rotateQuaternion", rotateQuaternion@
    ).
}

global lib_VesselOrientation is get_VesselOrientation().