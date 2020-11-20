//////////////////////////////////////////
// Time Functions                       //
// By Ren0k                             //
//////////////////////////////////////////
@LAZYGLOBAL off.

function getTemperatureTime {
    // PUBLIC getTemperatureTime :: geoposition : float : body -> float
    parameter       location is ship:geoposition,
                    timeToCalc is 0,
                    curBody is ship:body.

    // Returns a float between 0-1 where Tmin is 0 and Tmax is 1.
    // Optionally a moment in the future, corrected for kerbins rotation and orbit

    if timeToCalc = 0 {
        local locationUpVector is (LatLng(0, location:lng-45):position-curBody:position):normalized.
        local locationSunVector is (body("sun"):position - LatLng(0, location:lng):position):normalized.
        return (vdot(locationSunVector, locationUpVector)+1)/2.
    } else {
        local rotLngShift is (timeToCalc/curBody:rotationperiod)*360.
        local obtLngShift is (timeToCalc/curBody:orbit:period)*360.
        local totLngShift is rotLngShift+obtLngShift.
        local futureLocation is LatLng(0, location:lng+totLngShift).
        local locationUpVector is (LatLng(0, futureLocation:lng-45):position-body:position):normalized.
        local locationSunVector is (body("sun"):position-futureLocation:position):normalized.
        return (vdot(locationSunVector,locationUpVector)+1)/2.
    }
}

function getClockTime {
    // PUBLIC getClockTime :: geoposition : float : body -> string
    parameter       location is ship:geoposition,
                    timeToCalc is 0,
                    curBody is ship:body.

    // Returns the local time in a string as a clock value
    // Optionally a moment in the future, corrected for kerbins rotation and orbit

    if timeToCalc = 0 {
        local locationUpVector is (LatLng(0, location:lng):position-curBody:position):normalized.
        local locationSideVector is (LatLng(0, location:lng-90):position-curBody:position):normalized.
        local locationSunVector is (body("sun"):position - LatLng(0, location:lng):position):normalized.
        local arcVal1 is vdot(locationSunVector, locationSideVector).
        local arcVal2 is vdot(locationSunVector, locationUpVector).
        local hourTime is ((arctan2(arcVal1, arcVal2)+180)/360)*24.
        local minuteTime is (hourTime-floor(hourTime,0))*60.
        local secondTime is (minuteTime-floor(minuteTime,0))*60.
        return(round(hourTime,0)+":"+round(minuteTime,0)+":"+round(secondTime,0)).
    } else {
        local rotLngShift is (timeToCalc/curBody:rotationperiod)*360.
        local obtLngShift is (timeToCalc/curBody:orbit:period)*360.
        local totLngShift is rotLngShift+obtLngShift.
        local futureLocation is LatLng(0, location:lng+totLngShift).
        local locationUpVector is (LatLng(0, futureLocation:lng):position-body:position):normalized.
        local locationSideVector is (LatLng(0, futureLocation:lng-90):position-body:position):normalized.
        local locationSunVector is (body("sun"):position - LatLng(0, futureLocation:lng):position):normalized.
        local arcVal1 is vdot(locationSunVector, locationSideVector).
        local arcVal2 is vdot(locationSunVector, locationUpVector).
        local hourTime is ((arctan2(arcVal1, arcVal2)+180)/360)*24.
        local minuteTime is (hourTime-floor(hourTime,0))*60.
        local secondTime is (minuteTime-floor(minuteTime,0))*60.
        return(round(hourTime,0)+":"+round(minuteTime,0)+":"+round(secondTime,0)).
    }
}

