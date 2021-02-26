//////////////////////////////////////////
// Laythe Atmospheric Curves            //
// By Ren0k                             //
//////////////////////////////////////////
@LAZYGLOBAL off.

function getLaytheAtmosphere {
    // PUBLIC getLaytheAtmosphere :: nothing -> lexicon

    function getTemperatureCurve {
        // PRIVATE getTemperatureCurve :: nothing -> 2D Array
        // Assigns a temperature value to a height value
        //                   ALT        T           TAN-A             TAN-B
        local key0 is list  (0          ,277        ,0              ,-0.009285714).
        local key1 is list  (5250       ,206        ,-0.009253677   ,0).
        local key2 is list  (10000      ,206        ,0              ,0.001419616).
        local key3 is list  (17000      ,217.8      ,0.001414257    ,0.003959919).  
        local key4 is list  (22000      ,235.5      ,0.0039412      ,-0.0002581542).
        local key5 is list  (31000      ,203        ,-0.003911343   ,-0.0007623209).
        local key6 is list  (38000      ,199        ,0              ,0.001478429).
        local key7 is list  (50000      ,214        ,0              ,0).

        return list(
            key0,key1,key2,key3,key4,key5,key6,key7).
    }

    function getTemperatureSunMultCurve {
        // PRIVATE getTemperatureSunMultCurve :: nothing -> 2D Array
        // Defines how atmosphereTemperatureOffset varies with altitude
        //                   ALT        T           TAN-A             TAN-B
        local key0 is list  (0          ,1          ,0              ,0).
        local key1 is list  (5250       ,0.1        ,-6.848309E-05  ,-6.848309E-05).
        local key2 is list  (10000      ,0          ,0              ,0).
        local key3 is list  (17000      ,0          ,0              ,0).  
        local key4 is list  (27000      ,0.1763835  ,4.519309E-05   ,4.519309E-05).
        local key5 is list  (38000      ,1          ,4.497274E-05   ,4.497274E-05).
        local key6 is list  (50000      ,1.2        ,0              ,0).

        return list(
            key0,key1,key2,key3,key4,key5,key6).
    }

    function getTemperatureLatitudeBiasCurve {
        // PRIVATE getTemperatureLatitudeBiasCurve :: nothing -> 2D Array
        // The amount by which temperature deviates per latitude
        //                   LAT        T           TAN-A             TAN-B
        local key0 is list  (0          ,5          ,0              ,-0.04354425).
        local key1 is list  (50         ,1          ,-0.2132        ,-0.2132).
        local key2 is list  (70         ,-10        ,-1.128971      ,-1.128971).
        local key3 is list  (90         ,-30        ,-0.02418368    ,0).  

        return list(
            key0,key1,key2,key3).
    }

    function getTemperatureLatitudeSunMultCurve {
        // PRIVATE getTemperatureLatitudeSunMultCurve :: nothing -> 2D Array
        // The amount of diurnal variation
        //                   LAT        T           TAN-A             TAN-B
        local key0 is list  (0          ,6          ,0              ,0.02746098).
        local key1 is list  (40         ,9          ,0.2094055      ,0.2094055).
        local key2 is list  (65         ,11         ,0              ,0).
        local key3 is list  (90         ,2          ,0              ,0).  

        return list(
            key0,key1,key2,key3).
    }

    return lexicon(
        "TC", getTemperatureCurve@,
        "TSMC", getTemperatureSunMultCurve@,
        "TLBC", getTemperatureLatitudeBiasCurve@,
        "TLSMC", getTemperatureLatitudeSunMultCurve@,
        "Atmosphere", True,
        "Oxygen", True,    
        "Pressure", 60.795,
        "Density", 0.764571404126208,
        "adiabaticIndex", 1.39999997615814,
        "atmosphereDepth", 50000,
        "gasMassLapseRate", 0.00564,
        "atmosphereMolarMass", 0.0289644002914429,
        "temperatureLapseRate", 0.00453333333333333,
        "temperatureSeaLevel", 282,
        "albedo", 0.3,
        "emissivity", 0.7
    ).
}