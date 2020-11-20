//////////////////////////////////////////
// Get Atmospheric Data                 //
// By Ren0k                             //
//////////////////////////////////////////
@LAZYGLOBAL off.

runpath("atmoData/getTime.ks").         // For time calculations

function getAtmosphericData {
    // PUBLIC getAtmosphericData :: body -> lexicon
    parameter       curBody is ship:body.

    local bodyParameters is lexicon().
    local molarmass is curBody:atm:molarmass.
    local gasConstant is constant:idealgas.
    local adiabaticIndex is curBody:atm:adiabaticindex.
    local SGC is (gasConstant/molarmass).

    function hermiteInterpolator {
        // PRIVATE hermiteInterpolator :: float x7 -> float
        parameter       x0 is 0,
                        x1 is 1,
                        y0 is 0,
                        y1 is 1,
                        m0 is 0,
                        m1 is 0,
                        dataPoint is 1.

        // H(t)=(2t^3-3t^2+1)y0+(t^3-2t^2+t)m0+(-2t^3+3t^2)y1+(t^3-t^2)m1
        // This function returns the y value resulting from position t on the curve

        // x0 = start point
        // x1 = end point
        // y0 = start value
        // y1 = end value
        // m0 = start tangent
        // m1 = end tangent
        // dataPoint = float to get the y value

        local normFactor is (x1-x0).
        local t is (dataPoint-x0)/normFactor.
        set m0 to m0 * (normFactor).
        set m1 to m1 * (normFactor).
        return (2*t^3-3*t^2+1)*y0+(t^3-2*t^2+t)*m0+(-2*t^3+3*t^2)*y1+(t^3-t^2)*m1.
    }

    function getKeyValues {
        // PRIVATE getIndex :: float : 2D Array -> 2D Array
        parameter       inputNumber,
                        keyValues.
        local index is 0.
        for key in keyValues {
            if inputNumber <= key[0] {
                return list(keyValues[index-1], keyValues[index]).
            }
            set index to index+1.
        }
    }

    function getFloatCurves {   
        // PRIVATE getFloatCurves :: nothing -> nothing
        if curBody = BODY("Kerbin") {
            runpath("atmoData/Kerbin/getCurves.ks"). 
            set bodyParameters to getKerbinAtmosphere().
        }
        else if curBody = BODY("Eve") {
            runpath("atmoData/Eve/getCurves.ks"). 
            set bodyParameters to getEveAtmosphere().
        }
        else if curBody = BODY("Jool") {
            runpath("atmoData/Jool/getCurves.ks"). 
            set bodyParameters to getJoolAtmosphere().
        }
        else if curBody = BODY("Duna") {
            runpath("atmoData/Duna/getCurves.ks"). 
            set bodyParameters to getDunaAtmosphere().
        }
        else if curBody = BODY("Laythe") {
            runpath("atmoData/Laythe/getCurves.ks"). 
            set bodyParameters to getLaytheAtmosphere().
        }
        else set bodyParameters["Atmosphere"] to false.
    }

    function getTemperatureAltitude {
        // PRIVATE getTemperatureAltitude :: nothing -> kosDelegate
        // NOT IN USE -> Same results as body:atm:alttemp(altitude)
        local temperatureAltitudeCurve is bodyParameters["TC"]().
        local startX is temperatureAltitudeCurve[0][0].
        local endX is temperatureAltitudeCurve[temperatureAltitudeCurve:length-1][0].
        local startY is temperatureAltitudeCurve[0][1].
        local endY is temperatureAltitudeCurve[temperatureAltitudeCurve:length-1][1].
        local keyValues is getKeyValues(ship:altitude, temperatureAltitudeCurve).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].


        return {// kosDelegate :: float -> float
            parameter       shipAltitude is ship:altitude.
            if (shipAltitude > endKey[0]) or (shipAltitude < beginKey[0]) {
                if shipAltitude <= startX return startY.
                else if shipAltitude >= endX return endY.
                set keyValues to getKeyValues(shipAltitude, temperatureAltitudeCurve).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(shipAltitude)). }.
    }

    function getTemperatureLatitudeBias {
        // PRIVATE getTemperatureLatitudeBias :: nothing -> kosDelegate
        // The amount by which temperature deviates per latitude
        local latitudeBiasCurve is bodyParameters["TLBC"]().
        local startX is latitudeBiasCurve[0][0].
        local endX is latitudeBiasCurve[latitudeBiasCurve:length-1][0].
        local startY is latitudeBiasCurve[0][1].
        local endY is latitudeBiasCurve[latitudeBiasCurve:length-1][1].
        local keyValues is getKeyValues(abs(ship:geoposition:lat), latitudeBiasCurve).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {// kosDelegate :: float -> float
            parameter       shipLatitude is abs(ship:geoposition:lat).
            if (shipLatitude > endKey[0]) or (shipLatitude < beginKey[0]) {
                if shipLatitude <= startX return startY.
                else if shipLatitude >= endX return endY.
                set keyValues to getKeyValues(shipLatitude, latitudeBiasCurve).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(shipLatitude)). }.
    }

    function getTemperatureLatitudeSunMult {
        // PRIVATE getTemperatureLatitudeSunMult :: nothing -> kosDelegate
        // The amount of diurnal variation
        local temperatureLatitudeSunMultCurve is bodyParameters["TLSMC"]().
        local startX is temperatureLatitudeSunMultCurve[0][0].
        local endX is temperatureLatitudeSunMultCurve[temperatureLatitudeSunMultCurve:length-1][0].
        local startY is temperatureLatitudeSunMultCurve[0][1].
        local endY is temperatureLatitudeSunMultCurve[temperatureLatitudeSunMultCurve:length-1][1].
        local keyValues is getKeyValues(abs(ship:geoposition:lat), temperatureLatitudeSunMultCurve).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {// kosDelegate :: float -> float
            parameter       shipLatitude is abs(ship:geoposition:lat).
            if (shipLatitude > endKey[0]) or (shipLatitude < beginKey[0]) {
                if shipLatitude <= startX return startY.
                else if shipLatitude >= endX return endY.
                set keyValues to getKeyValues(shipLatitude, temperatureLatitudeSunMultCurve).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(shipLatitude)). }.
    }

    function getTemperatureSunMult {
        // PRIVATE getTemperatureSunMult :: nothing -> kosDelegate
        // Defines how atmosphereTemperatureOffset varies with altitude
        local temperatureSunMultCurve is bodyParameters["TSMC"]().
        local startX is temperatureSunMultCurve[0][0].
        local endX is temperatureSunMultCurve[temperatureSunMultCurve:length-1][0].
        local startY is temperatureSunMultCurve[0][1].
        local endY is temperatureSunMultCurve[temperatureSunMultCurve:length-1][1].
        local keyValues is getKeyValues(ship:altitude, temperatureSunMultCurve).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {// kosDelegate :: float -> float
            parameter       shipAltitude is ship:altitude.
            if (shipAltitude > endKey[0]) or (shipAltitude < beginKey[0]) {
                if shipAltitude <= startX return startY.
                else if shipAltitude >= endX return endY.
                set keyValues to getKeyValues(shipAltitude, temperatureSunMultCurve).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(shipAltitude)). }.
    }

    function getStaticAmbientTemperature {
        // PUBLIC getStaticAmbientTemperature :: bool -> kosDelegate
        // Returns static ambient temperature at selected altitude, geoposition and future time
        // fastMethod determines if the lighter version is used
        parameter       fastMethod is false.

        local getLatTemp is getTemperatureLatitudeBias().
        local getLatVarTemp is getTemperatureLatitudeSunMult().
        local getAltVarTemp is getTemperatureSunMult().
        local localTime is 0.
        local shipLatitude is 0.
        local altTemp is 0.
        local latTemp is 0.
        local latVarTemp is 0.
        local altVarTemp is 0.
        local atmosphereTemperatureOffset is 0.
        local counter is 1E10.
        
        if fastMethod return {// kosDelegate :: float : geoposition : float : float -> float
            // This method has an updateInterval parameter which determines how often latitude information is updated
            // This significantly decreases computation time
            parameter       shipAltitude is ship:altitude,
                            shipLocation is ship:geoposition,
                            timeToCalc is 0,
                            updateInterval is 10.

            if counter > updateInterval {
                set localTime to getTemperatureTime(shipLocation, timeToCalc, curBody).
                set shipLatitude to abs(shipLocation:lat).
                set latTemp to getLatTemp(shipLatitude).
                set latVarTemp to getLatVarTemp(shipLatitude).
                set atmosphereTemperatureOffset to latTemp + (latVarTemp*localTime).
                set counter to 0.
            }
            set altTemp to curBody:atm:alttemp(shipAltitude).
            set altVarTemp to getAltVarTemp(shipAltitude).

            set counter to counter + 1.
            return altTemp + (atmosphereTemperatureOffset*altVarTemp).
        }. 

        else return {// kosDelegate :: float : geoposition : float -> float
            // Checks all curves every update for the most accurate data, but slowest
            parameter       shipAltitude is ship:altitude,
                            shipLocation is ship:geoposition,
                            timeToCalc is 0,
                            updateInterval is 0. //not used here

            set localTime to getTemperatureTime(shipLocation, timeToCalc, curBody).
            set shipLatitude to abs(shipLocation:lat).
            set altTemp to curBody:atm:alttemp(shipAltitude).
            set latTemp to getLatTemp(shipLatitude).
            set latVarTemp to getLatVarTemp(shipLatitude).
            set atmosphereTemperatureOffset to latTemp + (latVarTemp*localTime).
            set altVarTemp to getAltVarTemp(shipAltitude).

            return altTemp + (atmosphereTemperatureOffset*altVarTemp).
        }.
    }

    function getFullAtmosphericData {
        // PUBLIC getFullAtmosphericData :: bool -> kosDelegate
        // Returns all atmospheric data
        parameter           fastMethod is false.

        local PRES is 0.
        local RHO is 0.
        local VM is 0.
        local MN is 0.
        local EAS is 0.
        local dynamicPressure is 0.
        local getSAT is getStaticAmbientTemperature(fastMethod).
        local SAT is 0.
        local OAT is 0.

        return {// kosDelegate :: float : float : geoposition : float : float -> lexicon
            parameter       TAS is ship:velocity:surface:mag,
                            shipAltitude is ship:altitude,
                            shipLocation is ship:geoposition,
                            timeToCalc is 0,
                            updateInterval is 10.

            set SAT to getSAT(shipAltitude, shipLocation, timeToCalc, updateInterval).
            set OAT to SAT-273.15.
            set PRES to max(curBody:atm:altitudepressure(shipAltitude)*constant:atmtokpa*1000, 1E-10).
            set RHO to (PRES/(SGC*SAT)).
            set VM to (sqrt(adiabaticIndex * SGC * SAT)).
            set MN to TAS/VM.  
            set EAS to (TAS / sqrt(1.225/RHO)).
            set dynamicPressure to 0.5 * RHO * TAS^2.

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
        }.
    }

    // Gets the float curves for the parameter body
    getFloatCurves().

    // Returns 2 delegates
    return lexicon(
        "getSAT", getStaticAmbientTemperature@,
        "getDATA", getFullAtmosphericData@
    ).
}

global lib_atmosphericData is getAtmosphericData().