//////////////////////////////////////////
// Kerbin Atmospheric Curves            //
// By Ren0k                             //
//////////////////////////////////////////
@LAZYGLOBAL off.

function getKerbinAtmosphere {
    // PUBLIC getKerbinAtmosphere :: nothing -> lexicon

    function getTemperatureCurve {
        // PRIVATE getTemperatureCurve :: nothing -> 2D Array
        // Assigns a temperature value to a height value
        //                   ALT        T           TAN-A             TAN-B
        local key0 is list  (00.0       ,288.15     ,0.00           ,-0.008125).
        local key1 is list  (8815.22    ,216.65     ,-0.008096968   ,0.00).
        local key2 is list  (16050.39   ,216.65     ,0.00           ,0.001242164).
        local key3 is list  (25729.23   ,228.65     ,0.001237475    ,0.003464929).  
        local key4 is list  (37879.44   ,270.65     ,0.00344855     ,0.00).
        local key5 is list  (41129.24   ,270.65     ,0.00           ,-0.003444189).
        local key6 is list  (57440.13   ,214.65     ,-0.003422425   ,-0.002444589).
        local key7 is list  (68797.88   ,186.946    ,-0.002433851   ,0.00).
        local key8 is list  (70000      ,186.946    ,0.00           ,0.00).

        return list(
            key0,key1,key2,key3,key4,key5,key6,key7,key8).
    }

    function getTemperatureSunMultCurve {
        // PRIVATE getTemperatureSunMultCurve :: nothing -> 2D Array
        // Defines how atmosphereTemperatureOffset varies with altitude
        //                   ALT        T           TAN-A             TAN-B
        local key0 is list  (0          ,1          ,0              ,0).
        local key1 is list  (8815.22    ,0.3        ,-5.91316E-05   ,-5.91316E-05).
        local key2 is list  (16050.39   ,0          ,0              ,0).
        local key3 is list  (25729.23   ,0          ,0              ,0).  
        local key4 is list  (37879.44   ,0.2        ,0              ,0).
        local key5 is list  (57440.13   ,0.2        ,0              ,0).
        local key6 is list  (63902.72   ,1          ,0.0001012837   ,0.0001012837).
        local key7 is list  (70000      ,1.2        ,0              ,0).

        return list(
            key0,key1,key2,key3,key4,key5,key6,key7).
    }

    function getTemperatureLatitudeBiasCurve {
        // PRIVATE getTemperatureLatitudeBiasCurve :: nothing -> 2D Array
        // The amount by which temperature deviates per latitude
        //                   LAT        T           TAN-A             TAN-B
        local key0 is list  (0          ,17         ,0              ,-0.3316494).
        local key1 is list  (10         ,12         ,-0.65          ,-0.65).
        local key2 is list  (18         ,6.36371    ,-0.4502313     ,-0.4502313).
        local key3 is list  (30         ,0          ,-1.3           ,-1.3).  
        local key4 is list  (35         ,-10        ,-1.65          ,-1.65).
        local key5 is list  (45         ,-23        ,-1.05          ,-1.05).
        local key6 is list  (55         ,-31        ,-0.6           ,-0.6).
        local key7 is list  (70         ,-37        ,-0.6689383     ,-0.6689383).
        local key8 is list  (90         ,-50        ,-0.02418368    ,0).

        return list(
            key0,key1,key2,key3,key4,key5,key6,key7,key8).
    }

    function getTemperatureLatitudeSunMultCurve {
        // PRIVATE getTemperatureLatitudeSunMultCurve :: nothing -> 2D Array
        // The amount of diurnal variation
        //                   LAT        T           TAN-A             TAN-B
        local key0 is list  (0          ,9          ,0              ,0.1554984).
        local key1 is list  (40         ,14.2       ,0.08154097     ,0.08154097).
        local key2 is list  (55         ,14.9       ,-0.006055089   ,-0.006055089).
        local key3 is list  (68         ,12.16518   ,-0.2710912     ,-0.2710912).  
        local key4 is list  (76         ,8.582909   ,-0.6021729     ,-0.6021729).
        local key5 is list  (90         ,5          ,0              ,0).

        return list(
            key0,key1,key2,key3,key4,key5).
    }

    return lexicon(
        "TC", getTemperatureCurve@,
        "TSMC", getTemperatureSunMultCurve@,
        "TLBC", getTemperatureLatitudeBiasCurve@,
        "TLSMC", getTemperatureLatitudeSunMultCurve@,
        "Atmosphere", True,
        "Oxygen", True,    
        "Pressure", 101.324996948242,
        "Density", 1.22497705725583,
        "adiabaticIndex", 1.39999997615814,
        "atmosphereDepth", 70000,
        "gasMassLapseRate", 8.33518264702189,
        "atmosphereMolarMass", 0.0289644002914429,
        "temperatureLapseRate", 0.0041,
        "temperatureSeaLevel", 287,
        "albedo", 0.35,
        "emissivity", 0.65
    ).
}