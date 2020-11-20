//////////////////////////////////////////
// Eve Atmospheric Curves               //
// By Ren0k                             //
//////////////////////////////////////////
@LAZYGLOBAL off.

function getEveAtmosphere {
    // PUBLIC getEveAtmosphere :: nothing -> lexicon

    function getTemperatureCurve {
        // PRIVATE getTemperatureCurve :: nothing -> 2D Array
        // Assigns a temperature value to a height value
        //                   ALT        T           TAN-A             TAN-B
        local key0 is list  (0          ,420        ,0              ,-0.01029338).
        local key1 is list  (15000      ,280        ,-0.004705439   ,-0.004705439).
        local key2 is list  (50000      ,180        ,0              ,0).
        local key3 is list  (60000      ,190        ,0              ,0).  
        local key4 is list  (70000      ,160        ,0              ,0).
        local key5 is list  (90000      ,250        ,0.005894589    ,0).

        return list(
            key0,key1,key2,key3,key4,key5).
    }

    function getTemperatureSunMultCurve {
        // PRIVATE getTemperatureSunMultCurve :: nothing -> 2D Array
        // Defines how atmosphereTemperatureOffset varies with altitude
        //                   ALT        T           TAN-A             TAN-B
        local key0 is list  (0          ,1          ,0              ,0).
        local key1 is list  (15000      ,0          ,0              ,0).
        local key2 is list  (50000      ,0.5        ,0              ,0).
        local key3 is list  (70000      ,1.5        ,3.82549E-05    ,3.82549E-05).  
        local key4 is list  (90000      ,2          ,0              ,0).

        return list(
            key0,key1,key2,key3,key4).
    }

    function getTemperatureLatitudeBiasCurve {
        // PRIVATE getTemperatureLatitudeBiasCurve :: nothing -> 2D Array
        // The amount by which temperature deviates per latitude
        //                   LAT        T           TAN-A             TAN-B
        local key0 is list  (0          ,0          ,0              ,-0.1152484).
        local key1 is list  (30         ,-15        ,-1.127599      ,-1.127599).
        local key2 is list  (55         ,-30        ,-0.6           ,-0.6).
        local key3 is list  (90         ,-60        ,-0.02418368    ,0).  

        return list(
            key0,key1,key2,key3).
    }

    function getTemperatureLatitudeSunMultCurve {
        // PRIVATE getTemperatureLatitudeSunMultCurve :: nothing -> 2D Array
        // The amount of diurnal variation
        //                   LAT        T           TAN-A             TAN-B
        local key0 is list  (0          ,9          ,0              ,0).
        local key1 is list  (40         ,11         ,0.0669307      ,0.0669307).
        local key2 is list  (65         ,12         ,0              ,0).
        local key3 is list  (90         ,8          ,0              ,0).  

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
        "Pressure", 506.625,
        "Density", 6.23837138885624,
        "adiabaticIndex", 1.20000004768372,
        "atmosphereDepth", 90000,
        "gasMassLapseRate", 19.0254171112692,
        "atmosphereMolarMass", 0.0430000014603138,
        "temperatureLapseRate", 0.00453333333333333,
        "temperatureSeaLevel", 408,
        "albedo", 0.449999988079071,
        "emissivity", 0.550000011920929
    ).
}