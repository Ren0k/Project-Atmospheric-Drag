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
        set hourTime to round(hourTime,0).
        set minuteTime to round(minuteTime,0).
        set secondTime to round(secondTime, 0).
        if hourTime:tostring:length < 2 set hourTime to "0"+hourTime:tostring.
        if minuteTime:tostring:length < 2 set minuteTime to "0"+minuteTime:tostring.
        if secondTime:tostring:length < 2 set secondTime to "0"+secondTime:tostring.
        return(hourTime+":"+minuteTime+":"+secondTime).
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
        set hourTime to round(hourTime,0).
        set minuteTime to round(minuteTime,0).
        set secondTime to round(secondTime, 0).
        if hourTime:tostring:length < 2 set hourTime to "0"+hourTime:tostring.
        if minuteTime:tostring:length < 2 set minuteTime to "0"+minuteTime:tostring.
        if secondTime:tostring:length < 2 set secondTime to "0"+secondTime:tostring.
        return(hourTime+":"+minuteTime+":"+secondTime).
    }
}

function secondsToClock {
    // PUBLIC secondsToClock :: float -> string
    parameter       seconds.

    local secondsInDay is mod(seconds, 86400).
    local secondsInHour is mod(secondsInDay, 3600).
    local hourTime is round(floor(secondsInDay/3600,0),0):tostring.
    local minuteTime is round(floor(secondsInHour/60, 0),0):tostring.
    local secondTime is round(mod(secondsInHour, 60),0):tostring.
    if hourTime:length < 2 set hourTime to "0"+hourTime:tostring.
    if minuteTime:length < 2 set minuteTime to "0"+minuteTime:tostring.
    if secondTime:length < 2 set secondTime to "0"+secondTime:tostring.
    return(hourTime+":"+minuteTime+":"+secondTime).
}
