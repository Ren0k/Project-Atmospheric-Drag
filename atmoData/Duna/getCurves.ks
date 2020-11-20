//////////////////////////////////////////
// Duna Atmospheric Curves              //
// By Ren0k                             //
//////////////////////////////////////////
@LAZYGLOBAL off.

function getDunaAtmosphere {
    // PUBLIC getDunaAtmosphere :: nothing -> lexicon

    function getTemperatureCurve {
        // PRIVATE getTemperatureCurve :: nothing -> 2D Array
        // Assigns a temperature value to a height value
        //                   ALT        T           TAN-A             TAN-B
        local key0 is list  (0          ,233        ,0              ,-0.0004261126).
        local key1 is list  (1000       ,232.8      ,-0.000573325   ,-0.000573325).
        local key2 is list  (25000      ,153.7      ,-0.001877083   ,-0.001877083).
        local key3 is list  (30000      ,150        ,0              ,0).  
        local key4 is list  (45000      ,150        ,0              ,0).
        local key5 is list  (50000      ,160        ,0.003746914    ,0).

        return list(
            key0,key1,key2,key3,key4,key5).
    }

    function getTemperatureSunMultCurve {
        // PRIVATE getTemperatureSunMultCurve :: nothing -> 2D Array
        // Defines how atmosphereTemperatureOffset varies with altitude
        //                   ALT        T           TAN-A             TAN-B
        local key0 is list  (0          ,1          ,0              ,0).
        local key1 is list  (1000       ,1          ,0              ,0).
        local key2 is list  (25000      ,0          ,0              ,0).
        local key3 is list  (45000      ,0          ,0              ,0).  
        local key4 is list  (47350      ,0.4551345  ,0.0006885778   ,0.0006885778).
        local key5 is list  (50000      ,1          ,0              ,0).

        return list(
            key0,key1,key2,key3,key4,key5).
    }

    function getTemperatureLatitudeBiasCurve {
        // PRIVATE getTemperatureLatitudeBiasCurve :: nothing -> 2D Array
        // The amount by which temperature deviates per latitude
        //                   LAT        T           TAN-A             TAN-B
        local key0 is list  (0          ,20         ,0              ,-0.0957164).
        local key1 is list  (50         ,0          ,-0.950278      ,-0.950278).
        local key2 is list  (70         ,-30        ,-1.955704      ,-1.955704).
        local key3 is list  (90         ,-50        ,-0.02418368    ,0).  

        return list(
            key0,key1,key2,key3).
    }

    function getTemperatureLatitudeSunMultCurve {
        // PRIVATE getTemperatureLatitudeSunMultCurve :: nothing -> 2D Array
        // The amount of diurnal variation
        //                   LAT        T           TAN-A             TAN-B
        local key0 is list  (0          ,18         ,0              ,0.06497125).
        local key1 is list  (40         ,25         ,0              ,0).
        local key2 is list  (65         ,20         ,-0.5202533     ,-0.5202533).
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
        "Pressure", 6.75500011444092,
        "Density", 0.149935108881759,
        "adiabaticIndex", 1.20000004768372,
        "atmosphereDepth", 50000,
        "gasMassLapseRate", 3.04406677337964,
        "atmosphereMolarMass", 0.0430000014603138,
        "temperatureLapseRate", 0.005,
        "temperatureSeaLevel", 250,
        "albedo", 0.170000001788139,
        "emissivity", 0.829999983310699
    ).
}