//////////////////////////////////////////
// Ambient Temperature Model for Kerbin //
// By Ren0k                             //
//////////////////////////////////////////

@LAZYGLOBAL off.

function getLocalTime {
    // PUBLIC getLocalTime :: geoposition : scalar -> scalar
    parameter       location is ship:geoposition,
                    timeToCalc is 0.

    // Returns a value between 0-2 where Tmin is 0 and Tmax is 2.
    // It calculates longitude shift over time and returns the future time if time is inserted

    if timeToCalc = 0 {
        local locationUpVector is (LatLng(location:lat, location:lng-45):position-body:position):normalized.
        local locationSunVector is (body("sun"):position-location:position):normalized.
        return vdot(locationSunVector,locationUpVector)/cos(location:lat)+1.
    } else {
        local lngShift is (timeToCalc/body:rotationperiod)*360.
        local futureLocation is LatLng(location:lat, location:lng+lngShift).
        local locationUpVector is (LatLng(futureLocation:lat, futureLocation:lng-45):position-body:position):normalized.
        local locationSunVector is (body("sun"):position-futureLocation:position):normalized.
        return vdot(locationSunVector,locationUpVector)/cos(location:lat)+1.   
    }
}

function getAmbientTemperature {
    // PUBLIC getAmbientTemperature :: nothing -> lexicon

    function hermiteInterpolator {
        // PRIVATE hermiteInterpolator :: scalar x7 -> scalar
        parameter       x0 is 0,
                        x1 is 1,
                        y0 is 0,
                        y1 is 1,
                        m0 is 0,
                        m1 is 0,
                        dataPoint is 1.

        // H(t)=(2t^3-3t^2+1)y0+(t^3-2t^2+t)m0+(-2t^3+3t^2)y1+(t^3-t^2)m1
        // This function returns the int y value resulting from position t on the curve

        // x0 = start point
        // x1 = end point
        // y0 = start value
        // y1 = end value
        // m0 = start tangent
        // m1 = end tangent
        // dataPoint = int to get the y value

        local t is (dataPoint-x0)/(x1-x0).
        return (2*t^3-3*t^2+1)*y0+(t^3-2*t^2+t)*m0+(-2*t^3+3*t^2)*y1+(t^3-t^2)*m1.
    }

    function hermiteInterpolatorFunction {
        // PRIVATE hermiteInterpolatorFunction :: scalar x7 -> kosDelegate
        parameter       x0 is 0,
                        x1 is 1,
                        y0 is 0,
                        y1 is 1,
                        m0 is 0,
                        m1 is 0,
                        dataPoint is 1.

        // H(t)=(2t^3-3t^2+1)y0+(t^3-2t^2+t)m0+(-2t^3+3t^2)y1+(t^3-t^2)m1
        // This function returns the function itself

        // x0 = start point
        // x1 = end point
        // y0 = start value
        // y1 = end value
        // m0 = start tangent
        // m1 = end tangent
        // dataPoint = int to get the y value

        local t is (dataPoint-x0)/(x1-x0).

        return {
            parameter       dataPoint.
            set t to (dataPoint-x0)/(x1-x0).
            return (2*t^3-3*t^2+1)*y0+(t^3-2*t^2+t)*m0+(-2*t^3+3*t^2)*y1+(t^3-t^2)*m1.
        }.
    }

    function getDiurnalVariationCurve {
        // PRIVATE getDiurnalVariationCurve :: nothing -> list
        //                   LAT      DT        TAN-A   TAN-B
        local key0 is list  (00.0   ,09.00     ,0.10   , 0.10).
        local key1 is list  (02.5   ,09.37     ,0.10   , 0.10).
        local key2 is list  (05.0   ,09.77     ,0.35   , 0.35).
        local key3 is list  (07.5   ,10.14     ,0.20   , 0.20).
        local key4 is list  (10.0   ,10.53     ,0.25   , 0.25).
        local key5 is list  (12.5   ,10.89     ,0.15   , 0.15).
        local key6 is list  (15.0   ,11.27     ,0.20   , 0.20).
        local key7 is list  (17.5   ,11.61     ,0.15   , 0.15).
        local key8 is list  (20.0   ,11.97     ,0.15   , 0.15).
        local key9 is list  (22.5   ,12.28     ,0.00   , 0.00).
        local key10 is list (25.0   ,12.62     ,0.20   , 0.20).
        local key11 is list (27.5   ,12.91     ,0.10   , 0.10).
        local key12 is list (30.0   ,13.22     ,0.25   , 0.25).
        local key13 is list (32.5   ,13.49     ,0.20   , 0.20).
        local key14 is list (35.0   ,13.75     ,0.10   , 0.10).
        local key15 is list (37.5   ,13.99     ,0.10   , 0.10).
        local key16 is list (40.0   ,14.20     ,0.10   , 0.10).
        local key17 is list (42.5   ,14.39     ,0.10   , 0.10).
        local key18 is list (45.0   ,14.57     ,0.15   , 0.15).
        local key19 is list (47.5   ,14.71     ,0.10   , 0.10).
        local key20 is list (50.0   ,14.82     ,0.00   , 0.00).
        local key21 is list (52.5   ,14.88     ,0.00   , 0.00).
        local key22 is list (55.0   ,14.90     ,0.00   , 0.00).
        local key23 is list (57.5   ,14.72     ,-0.45  ,-0.45).
        local key24 is list (60.0   ,14.31     ,-0.60  ,-0.60).
        local key25 is list (62.5   ,13.70     ,-0.75  ,-0.75).
        local key26 is list (65.0   ,13.02     ,-0.55  ,-0.55).
        local key27 is list (67.5   ,12.30     ,-0.65  ,-0.65).
        local key28 is list (70.0   ,11.53     ,-0.85  ,-0.85).
        local key29 is list (72.5   ,10.47     ,-1.25  ,-1.25).
        local key30 is list (75.0   ,09.17     ,-1.30  ,-1.30).
        local key31 is list (77.5   ,07.75     ,-1.30  ,-1.30).
        local key32 is list (80.0   ,06.65     ,-0.85  ,-0.85).
        local key33 is list (82.5   ,05.86     ,-0.35  ,-0.35).
        local key34 is list (85.0   ,05.25     ,-0.25  ,-0.25).
        local key35 is list (87.5   ,05.09     ,-0.05  ,-0.05).
        local key36 is list (90.0   ,04.96     ,0.10   , 0.10).

        return list(
            key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,
            key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,
            key30,key31,key32,key33,key34,key35,key36).
    }

    function getTemperatureLatitudeCurve {
        // PRIVATE getTemperatureLatitudeCurve :: nothing -> list
        //                   LAT      TMAX       TAN-A     TAN-B
        local key0 is list  (00.0   ,314.15     ,-0.50   ,-0.40).
        local key1 is list  (02.5   ,313.60     ,-0.55   ,-0.70).
        local key2 is list  (05.0   ,312.82     ,-0.90   ,-0.80).
        local key3 is list  (07.5   ,311.85     ,-1.00   ,-1.00).
        local key4 is list  (10.0   ,310.68     ,-1.30   ,-1.30).
        local key5 is list  (12.5   ,309.22     ,-1.70   ,-1.70).
        local key6 is list  (15.0   ,307.64     ,-1.55   ,-1.55).
        local key7 is list  (17.5   ,306.38     ,-1.00   ,-1.00).
        local key8 is list  (20.0   ,305.75     ,-0.55   ,-0.55).
        local key9 is list  (22.5   ,305.38     ,-0.50   ,-0.50).
        local key10 is list (25.0   ,304.83     ,-0.80   ,-0.80).
        local key11 is list (27.5   ,303.64     ,-1.75   ,-1.75).
        local key12 is list (30.0   ,301.37     ,-3.00   ,-3.00).
        local key13 is list (32.5   ,296.87     ,-5.30   ,-5.30).
        local key14 is list (35.0   ,291.90     ,-4.00   ,-4.00).
        local key15 is list (37.5   ,288.28     ,-3.45   ,-3.45).
        local key16 is list (40.0   ,285.10     ,-3.10   ,-3.00).
        local key17 is list (42.5   ,282.28     ,-2.70   ,-2.70).
        local key18 is list (45.0   ,279.72     ,-2.50   ,-2.50).
        local key19 is list (47.5   ,277.42     ,-2.10   ,-2.10).
        local key20 is list (50.0   ,275.41     ,-1.90   ,-1.90).
        local key21 is list (52.5   ,273.64     ,-1.65   ,-1.65).
        local key22 is list (55.0   ,272.05     ,-1.55   ,-1.55).
        local key23 is list (57.5   ,270.62     ,-1.45   ,-1.45).
        local key24 is list (60.0   ,269.31     ,-1.45   ,-1.45).
        local key25 is list (62.5   ,267.98     ,-1.50   ,-1.50).
        local key26 is list (65.0   ,266.54     ,-1.50   ,-1.50).
        local key27 is list (67.5   ,264.85     ,-1.85   ,-1.85).
        local key28 is list (70.0   ,262.68     ,-2.55   ,-2.55).
        local key29 is list (72.5   ,259.79     ,-3.20   ,-3.20).
        local key30 is list (75.0   ,256.43     ,-3.50   ,-3.50).
        local key31 is list (77.5   ,252.86     ,-3.50   ,-3.30).
        local key32 is list (80.0   ,249.68     ,-2.95   ,-2.95).
        local key33 is list (82.5   ,247.01     ,-2.40   ,-2.40).
        local key34 is list (85.0   ,244.97     ,-1.65   ,-1.65).
        local key35 is list (87.5   ,243.65     ,-0.90   ,-0.90).
        local key36 is list (90.0   ,243.13     ,-0.00   ,-0.00).

        return list(
            key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,
            key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,
            key30,key31,key32,key33,key34,key35,key36).
    }

    function getTropopauseTemperatureCurve {
        // PRIVATE getTropopauseTemperatureCurve :: nothing -> list
        //                   LAT      TMAX       TAN-A    TAN-B
        local key0 is list  (00.0   ,224.45     ,-0.10  ,-0.10).
        local key1 is list  (02.5   ,224.29     ,-0.20  ,-0.20).
        local key2 is list  (05.0   ,224.05     ,-0.35  ,-0.35).
        local key3 is list  (07.5   ,223.76     ,-0.35  ,-0.35).
        local key4 is list  (10.0   ,223.41     ,-0.45  ,-0.45).
        local key5 is list  (12.5   ,222.97     ,-0.55  ,-0.55).
        local key6 is list  (15.0   ,222.50     ,-0.45  ,-0.45).
        local key7 is list  (17.5   ,222.12     ,-0.30  ,-0.30).
        local key8 is list  (20.0   ,221.93     ,-0.15  ,-0.15).
        local key9 is list  (22.5   ,221.82     ,-0.15  ,-0.15).
        local key10 is list (25.0   ,221.66     ,-0.20  ,-0.20).
        local key11 is list (27.5   ,221.30     ,-0.50  ,-0.50).
        local key12 is list (30.0   ,220.62     ,-0.90  ,-0.90).
        local key13 is list (32.5   ,219.27     ,-1.60  ,-1.60).
        local key14 is list (35.0   ,217.78     ,-1.15  ,-1.15).
        local key15 is list (37.5   ,216.69     ,-1.05  ,-1.05).
        local key16 is list (40.0   ,215.74     ,-0.90  ,-0.90).
        local key17 is list (42.5   ,214.89     ,-0.85  ,-0.85).
        local key18 is list (45.0   ,214.12     ,-0.80  ,-0.80).
        local key19 is list (47.5   ,213.43     ,-0.70  ,-0.70).
        local key20 is list (50.0   ,212.83     ,-0.60  ,-0.60).
        local key21 is list (52.5   ,212.30     ,-0.50  ,-0.50).
        local key22 is list (55.0   ,211.83     ,-0.40  ,-0.40).
        local key23 is list (57.5   ,211.39     ,-0.50  ,-0.50).
        local key24 is list (60.0   ,211.00     ,-0.45  ,-0.45).
        local key25 is list (62.5   ,210.60     ,-0.45  ,-0.45).
        local key26 is list (65.0   ,210.17     ,-0.45  ,-0.45).
        local key27 is list (67.5   ,209.66     ,-0.60  ,-0.60).
        local key28 is list (70.0   ,209.01     ,-0.80  ,-0.80).
        local key29 is list (72.5   ,208.14     ,-1.00  ,-1.00).
        local key30 is list (75.0   ,207.13     ,-1.20  ,-1.20).
        local key31 is list (77.5   ,206.07     ,-0.20  ,-0.20).
        local key32 is list (80.0   ,205.11     , 0.00  , 0.00).
        local key33 is list (82.5   ,204.31     , 0.00  , 0.00).
        local key34 is list (85.0   ,203.70     , 0.00  , 0.00).
        local key35 is list (87.5   ,203.37     , 0.00  , 0.00).
        local key36 is list (90.0   ,203.15     , 0.00  , 0.00).

        return list(
            key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,
            key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,
            key30,key31,key32,key33,key34,key35,key36).
    }

    function getTropopauseTangentCurve {
        // PRIVATE getTropopauseTangentCurve :: nothing -> list
        //                   LAT      TAN       TAN-A      TAN-B
        local key0 is list  (00.0   ,-85.00     ,1.0      , 1.0).
        local key1 is list  (05.0   ,-84.30     ,0.0      , 0.0).
        local key2 is list  (10.0   ,-83.20     ,0.0      , 1.0).
        local key3 is list  (15.0   ,-81.50     ,2.0      , 2.0).
        local key4 is list  (20.0   ,-80.64     ,-1.0     ,-1.0).
        local key5 is list  (25.0   ,-80.05     ,2.0      , 2.0).
        local key6 is list  (30.0   ,-78.22     ,4.0      , 4.0).
        local key7 is list  (35.0   ,-73.35     ,3.0      , 3.0).
        local key8 is list  (40.0   ,-69.80     ,2.0      , 2.0).
        local key9 is list  (45.0   ,-67.00     ,2.0      , 2.0).
        local key10 is list (50.0   ,-64.75     ,1.0      , 1.0).
        local key11 is list (55.0   ,-62.92     ,2.5      , 2.5).
        local key12 is list (60.0   ,-61.50     ,2.0      , 2.0).
        local key13 is list (65.0   ,-60.10     ,2.0      , 2.0).
        local key14 is list (70.0   ,-58.10     ,3.0      , 3.0).
        local key15 is list (75.0   ,-54.90     ,2.5      , 2.5).
        local key16 is list (80.0   ,-51.00     ,4.0      , 4.0).
        local key17 is list (85.0   ,-48.00     ,4.0      , 4.0).
        local key18 is list (90.0   ,-45.00     ,4.0      , 4.0).

        return list(
            key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,
            key16,key17,key18).
    }

    function getIndex {
        // PRIVATE getIndex :: scalar : scalar -> scalar
        parameter       inputNumber,
                        latSteps is 2.5.
        return floor((abs(inputNumber)/latSteps)).
    }

    function getLatitudeTemperature {
        // PRIVATE getLatitudeTemperature :: scalar -> kosDelegate
        parameter       shipLatitude.
        // Returns the tmax hermite curve for a given latitude.

        local keyIndex is getIndex(shipLatitude).
        local tempLatCurve is getTemperatureLatitudeCurve().
        local beginKey is tempLatCurve[keyIndex].
        local endKey is tempLatCurve[keyIndex+1].

        return { return hermiteInterpolatorFunction(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(shipLatitude)). }.
    }

    function getLatitudeTropopause {
        // PRIVATE getLatitudeTropopause :: scalar -> kosDelegate
        parameter           shipLatitude.
        // Returns the tropopause tmax hermite curve for a given latitude.

        local keyIndex is getIndex(shipLatitude).
        local tropopauseCurve is getTropopauseTemperatureCurve().
        local beginKey is tropopauseCurve[keyIndex].
        local endKey is tropopauseCurve[keyIndex+1].

        return { return hermiteInterpolatorFunction(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(shipLatitude)). }.
    }

    function getDiurnalTemperature {
        // PRIVATE getDiurnalTemperature :: scalar -> kosDelegate
        parameter       shipLatitude.
        // Returns the diurnal variation hermite curve for a given latitude.

        local keyIndex is getIndex(shipLatitude).
        local tempDiurnalCurve is getDiurnalVariationCurve().
        local beginKey is tempDiurnalCurve[keyIndex].
        local endKey is tempDiurnalCurve[keyIndex+1].

        return { return hermiteInterpolatorFunction(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(shipLatitude)). }.
    }

        function getLatitudeTropopauseTangent {
        // PRIVATE getLatitudeTropopauseTangent :: scalar -> kosDelegate
        parameter       shipLatitude.
        // Returns the tangent hermite curve at the tropopause for a given latitude.

        local keyIndex is getIndex(shipLatitude,5).
        local tangentCurve is getTropopauseTangentCurve().
        local beginKey is tangentCurve[keyIndex].
        local endKey is tangentCurve[keyIndex+1].

        return { return hermiteInterpolatorFunction(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(shipLatitude)). }.
    }

    function getSeaLevelTemperature {
        // PRIVATE getSeaLevelTemperature :: scalar -> scalar : scalar -> scalar
        parameter           shipLatitude.
        // Returns the base sea level temperature hermite curve for a given latitude.
        // The latitude curve and the diurnal variation curves are combined.

        local latitudeTemperature is getLatitudeTemperature(shipLatitude)().
        local diurnalTemperature is getDiurnalTemperature(shipLatitude)().
        local oldIndex is getIndex(shipLatitude).
        local newIndex is oldIndex.
        local newKey is false.

        return {parameter       shipLatitude,
                                localTime.
        
            set newIndex to getIndex(shipLatitude).
            if newIndex <> oldIndex set newKey to true.

            if (not newKey) {
                return (latitudeTemperature(shipLatitude) - diurnalTemperature(shipLatitude)*(1-(localTime/2))).
            } else {
                set latitudeTemperature to getLatitudeTemperature(shipLatitude)().
                set diurnalTemperature to getDiurnalTemperature(shipLatitude)().
                set oldIndex to getIndex(shipLatitude).
                set newKey to false.
                return (latitudeTemperature(shipLatitude) - diurnalTemperature(shipLatitude)*(1-(localTime/2))).
            }
        }.
    }

    function getTropopauseTemperature {
        // PRIVATE getTropopauseTemperature :: scalar -> scalar : scalar -> scalar
        parameter           shipLatitude.
        // Returns the tropopause temperature hermite curve for a given latitude.
        // The tropopause latitude curve and the diurnal variation curves are combined.
        // The tropopause diurnal variation is exactly 30% of sea level, so a 0.3 multiplier is introduced

        local tropopauseMaxTemperature is getLatitudeTropopause(shipLatitude)().
        local diurnalTemperature is getDiurnalTemperature(shipLatitude)().
        local oldIndex is getIndex(shipLatitude).
        local newIndex is oldIndex.
        local newKey is false.

        return {parameter       shipLatitude,
                                localTime.
        
            set newIndex to getIndex(shipLatitude).
            if newIndex <> oldIndex set newKey to true.

            if (not newKey) {
                return (tropopauseMaxTemperature(shipLatitude) - diurnalTemperature(shipLatitude)*0.3*(1-(localTime/2))).
            } else {
                set tropopauseMaxTemperature to getLatitudeTropopause(shipLatitude)().
                set diurnalTemperature to getDiurnalTemperature(shipLatitude)().
                set oldIndex to getIndex(shipLatitude).
                set newKey to false.
                return (tropopauseMaxTemperature(shipLatitude) - diurnalTemperature(shipLatitude)*0.3*(1-(localTime/2))).
            }
        }.
    }

    function getTropopauseTangent {
        // PRIVATE getTropopauseTangent :: scalar -> scalar : scalar -> scalar
        parameter           shipLatitude.
        // Returns the tropopause tangent hermite curve for a given latitude and time
        // The tangent curve at night is 0.52 * the day tangent curve

        local tropopauseTangent is getLatitudeTropopauseTangent(shipLatitude)().
        local diurnalTemperature is getDiurnalTemperature(shipLatitude)().
        local oldIndex is getIndex(shipLatitude,2.5).
        local newIndex is oldIndex.
        local newKey is false.

        return {parameter       shipLatitude,
                                localTime.
        
            set newIndex to getIndex(shipLatitude).
            if newIndex <> oldIndex set newKey to true.

            if (not newKey) {
                return (tropopauseTangent(shipLatitude) + ((1-(localTime/2)) * 0.52 * diurnalTemperature(shipLatitude))).
            } else {
                set tropopauseTangent to getLatitudeTropopauseTangent(shipLatitude)().
                set diurnalTemperature to getDiurnalTemperature(shipLatitude)().
                set oldIndex to getIndex(shipLatitude).
                set newKey to false.
                return (tropopauseTangent(shipLatitude) + ((1-(localTime/2)) * 0.52 * diurnalTemperature(shipLatitude))).
            }
        }.
    }

    function getAltitudeTemperature {
        // PUBLIC getAltitudeTemperature :: scalar : scalar -> scalar : scalar : scalar -> scalar
        parameter           shipLatitude is ship:geoposition:lat,
                            localTime is getLocalTime().

        // This functions returns the ambient temperature and updates itself for latitude, time and altitude.
        // It updates itself for new key values.

        local seaLevelTemp is getSeaLevelTemperature(abs(shipLatitude)).
        local tropopauseTemp is getTropopauseTemperature(abs(shipLatitude)).
        local tropopauseTangent is getTropopauseTangent(abs(shipLatitude)).
        local y0 is seaLevelTemp(abs(shipLatitude), localTime).
        local y1 is tropopauseTemp(abs(shipLatitude), localTime).
        local m1 is tropopauseTangent(abs(shipLatitude),localTime).

        return {parameter   shipLatitude,
                            localTime,
                            shipAltitude.

                set y0 to seaLevelTemp(abs(shipLatitude), localTime).
                set y1 to tropopauseTemp(abs(shipLatitude), localTime).
                set m1 to tropopauseTangent(abs(shipLatitude),localTime).
                if shipAltitude <= 8815 return hermiteInterpolator(0,8815,y0,y1,-71.60,m1,shipAltitude).
                else if shipAltitude <= 16000 return hermiteInterpolator(8815,16000,y1,216.65,((216.65-y1)*1.40),0,shipAltitude).
                else return ship:body:atm:alttemp(shipAltitude).
            }.
    }

    function getAltitudeTemperatureFunction {
        // PUBLIC getAltitudeTemperatureFunction :: scalar : scalar -> scalar -> kosDelegate
        parameter           shipLatitude is ship:geoposition:lat,
                            localTime is getLocalTime().

        // This function returns just the altitude curve function for the corresponding time and latitude.
        // This allows for very fast temperature determinations, however the error increases with changing time and latitude.
        // You can update this function when the error has increased significantly, by just calling the main function again

        local seaLevelTemp is getSeaLevelTemperature(abs(shipLatitude)).
        local tropopauseTemp is getTropopauseTemperature(abs(shipLatitude)).
        local tropopauseTangent is getTropopauseTangent(abs(shipLatitude)).

        return {
            parameter           shipLatitude,
                                localTime.

            local x0 is 0.
            local x1 is 8815.
            local y0 is seaLevelTemp(abs(shipLatitude), localTime).
            local y1 is tropopauseTemp(abs(shipLatitude), localTime).
            local m0 is -71.60.
            local m1 is tropopauseTangent(abs(shipLatitude),localTime).

            return {parameter   shipAltitude is ship:altitude.
                    if shipAltitude <= 8815 return hermiteInterpolator(x0,x1,y0,y1,m0,m1,shipAltitude).
                    else if shipAltitude <= 16000 return hermiteInterpolator(8815,16000,y1,216.65,((216.65-y1)*1.40),0,shipAltitude).
                    else return body:atm:alttemp(shipAltitude).
                }.
        }.
    }

    return lexicon (
        "OAT", getAltitudeTemperature()@,
        "OATF", getAltitudeTemperatureFunction()@
    ).
}

global lib_kerbinTemperature is getAmbientTemperature().
