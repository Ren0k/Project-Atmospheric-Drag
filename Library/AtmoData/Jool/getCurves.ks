//////////////////////////////////////////
// Jool Atmospheric Curves            //
// By Ren0k                             //
//////////////////////////////////////////
@LAZYGLOBAL off.

function getJoolAtmosphere {
    // PUBLIC getJoolAtmosphere :: nothing -> lexicon

    function getTemperatureCurve {
        // PRIVATE getTemperatureCurve :: nothing -> 2D Array
        // Assigns a temperature value to a height value
        //                   ALT        T           TAN-A             TAN-B
        local key0 is list  (0          ,200        ,0              ,-0.001182922).
        local key1 is list  (29000      ,165        ,-0.001207278   ,-0.001207278).
        local key2 is list  (123450     ,120        ,0              ,0).
        local key3 is list  (168000     ,160        ,0.0009967944   ,0.0009967944).  
        local key4 is list  (187500     ,175        ,0              ,0).
        local key5 is list  (194000     ,167        ,0              ,0).
        local key6 is list  (200000     ,350        ,0.08717471     ,0).

        return list(
            key0,key1,key2,key3,key4,key5,key6).
    }

    function getTemperatureSunMultCurve {
        // PRIVATE getTemperatureSunMultCurve :: nothing -> 2D Array
        // Defines how atmosphereTemperatureOffset varies with altitude
        //                   ALT        T           TAN-A             TAN-B
        local key0 is list  (0          ,0          ,0              ,0).
        local key1 is list  (29000      ,0.5        ,0              ,0).
        local key2 is list  (123450     ,0.8        ,0              ,0).
        local key3 is list  (200000     ,1.5        ,0              ,0).  

        return list(
            key0,key1,key2,key3).
    }

    function getTemperatureLatitudeBiasCurve {
        // PRIVATE getTemperatureLatitudeBiasCurve :: nothing -> 2D Array
        // The amount by which temperature deviates per latitude
        //                   LAT        T           TAN-A             TAN-B
        local key0 is list  (0          ,30         ,0              ,-0.0957164).
        local key1 is list  (50         ,10         ,-0.950278      ,-0.950278).
        local key2 is list  (70         ,-20        ,-1.955704      ,-1.955704).
        local key3 is list  (90         ,-40        ,-0.02418368    ,0).  

        return list(
            key0,key1,key2,key3).
    }

    function getTemperatureLatitudeSunMultCurve {
        // PRIVATE getTemperatureLatitudeSunMultCurve :: nothing -> 2D Array
        // The amount of diurnal variation
        //                   LAT        T           TAN-A             TAN-B
        local key0 is list  (0          ,9          ,0              ,0.02746098).
        local key1 is list  (40         ,12         ,0.2295445      ,0.2295445).
        local key2 is list  (65         ,18         ,0              ,0).
        local key3 is list  (90         ,5          ,0              ,0).  

        return list(
            key0,key1,key2,key3).
    }

    return lexicon(
        "TC", getTemperatureCurve@,
        "TSMC", getTemperatureSunMultCurve@,
        "TLBC", getTemperatureLatitudeBiasCurve@,
        "TLSMC", getTemperatureLatitudeSunMultCurve@,
        "Atmosphere", True,
        "Oxygen", False,    
        "Pressure", 1519.875,
        "Density", 6.70262205528434,
        "adiabaticIndex", 1.43,
        "atmosphereDepth", 200000,
        "gasMassLapseRate", 2.07657256052129,
        "atmosphereMolarMass", 0.0022,
        "temperatureLapseRate", 0.001,
        "temperatureSeaLevel", 200,
        "albedo", 0.52,
        "emissivity", 0.48
    ).
}