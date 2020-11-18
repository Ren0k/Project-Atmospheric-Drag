//////////////////////////////////////////
// Drag Profile                         //
// By Ren0k                             //
//////////////////////////////////////////
@lazyGlobal off.

function dragProfileMain {
// PUBLIC dragProfileMain :: nothing -> lexicon

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

    function getInitialCdCurve {
        // PRIVATE getInitialCdCurve :: nothing -> 2D Array
        //                   Cdi      Cdf       TAN-A       TAN-B
        local key0 is list  (0.00   ,0.0000     ,0.00       ,0.00).
        local key1 is list  (0.05   ,0.0025     ,0.15       ,0.15).
        local key2 is list  (0.40   ,0.1500     ,0.3963967  ,0.3963967).
        local key3 is list  (0.70   ,0.3500     ,0.9066986  ,0.9066986).
        local key4 is list  (0.75   ,0.4500     ,3.213604   ,3.213604).
        local key5 is list  (0.80   ,0.6600     ,3.49833    ,3.49833).
        local key6 is list  (0.85   ,0.8000     ,2.212924   ,2.212924).
        local key7 is list  (0.90   ,0.8900     ,1.1        ,1.1).
        local key8 is list  (1.00   ,1.0000     ,1.0        ,1.0).

        return list(
            key0,key1,key2,key3,key4,key5,key6,key7,key8).
    }

    function getMachCdCurve {
        // PRIVATE getMachCdCurve :: nothing -> 2D Array
        //                   Mi      Cor         TAN-A       TAN-B
        local key0 is list  (0.00   ,1.0000     ,0.00       ,0.00715953).
        local key1 is list  (0.85   ,1.2500     ,0.7780356  ,0.7780356).
        local key2 is list  (1.10   ,2.5000     ,0.2492796  ,0.2492796).
        local key3 is list  (5.00   ,3.0000     ,0          ,0).

        return list(
            key0,key1,key2,key3).
    }

    function getReynoldsCurve {
        // PRIVATE getReynoldsCurve :: nothing -> 2D Array
        //                   Rn      Cor         TAN-A          TAN-B
        local key0 is list  (0.00   ,4.0000     ,0.00           ,-2975.412).
        local key1 is list  (0.0001 ,3.0000     ,-251.1479      ,-251.1479).
        local key2 is list  (0.01   ,2.0000     ,-19.63584      ,-19.63584).
        local key3 is list  (0.10   ,1.2000     ,-0.7846036     ,-0.7846036).
        local key4 is list  (1.00   ,1.0000     ,0.00           ,0.00).
        local key5 is list  (100.0  ,1.0000     ,0.00           ,0.00).
        local key6 is list  (200.0  ,0.8200     ,0.00           ,0.00).
        local key7 is list  (500.0  ,0.8600     ,0.0001932119   ,0.0001932119).
        local key8 is list  (1000.0 ,0.9000     ,1.54299E-05    ,1.54299E-05).
        local key9 is list  (10000  ,0.9500     ,0.00           ,0.00).

        return list(
            key0,key1,key2,key3,key4,key5,key6,key7,key8,key9).
    }

    function getOverallDragCurve {
        // PRIVATE getOverallDragCurve :: nothing -> 2D Array
        //                   Mi      Cor          TAN-A       TAN-B
        local key0 is list  (0.00   ,0.5000     ,0.00       ,0.00).
        local key1 is list  (0.85   ,0.5000     ,0.00       ,0.00).
        local key2 is list  (1.10   ,1.3000     ,0.00       ,-0.008100224).
        local key3 is list  (2.00   ,0.7000     ,-0.1104858 ,-0.1104858).
        local key4 is list  (5.00   ,0.6000     ,0.00       ,0.00).
        local key5 is list  (10.00  ,0.8500     ,0.02198264 ,0.02198264).
        local key6 is list  (14.00  ,0.9000     ,0.007694946,0.007694946).
        local key7 is list  (25.00  ,0.9500     ,0.00       ,0.00).

        return list(
            key0,key1,key2,key3,key4,key5,key6,key7).
    }

    function getTipCurve {
        // PRIVATE getTipCurve :: nothing -> 2D Array
        //                   Mi      Cor          TAN-A       TAN-B
        local key0 is list  (0.00   ,1.0000     ,0.00       ,0.00).
        local key1 is list  (0.85   ,1.1900     ,0.6960422  ,0.6960422).
        local key2 is list  (1.10   ,2.8300     ,0.730473   ,0.730473).
        local key3 is list  (5.00   ,4.0000     ,0          ,0).

        return list(
            key0,key1,key2,key3).
    }

    function getSurfaceCurve {
        // PRIVATE getSurfaceCurve :: nothing -> 2D Array
        //                   Mi      Cor             TAN-A          TAN-B
        local key0 is list  (0.00   ,0.0200         ,0.00           ,0.00).
        local key1 is list  (0.85   ,0.0200         ,0.00           ,0.00).
        local key2 is list  (0.90   ,0.0152439      ,-0.07942077    ,-0.07942077).
        local key3 is list  (1.10   ,0.0025         ,-0.005279571   ,-0.001936768).
        local key4 is list  (2.00   ,0.002083333    ,-2.314833E-05  ,-2.314833E-05).
        local key5 is list  (5.00   ,0.003333333    ,-0.000180556   ,-0.000180556).
        local key6 is list  (25.00  ,0.001428571    ,-7.14286E-05   ,0.0).
        return list(
            key0,key1,key2,key3,key4,key5,key6).
    }

    function getTailCurve {
        // PRIVATE getTailCurve :: nothing -> 2D Array
        //                   Mi      Cor             TAN-A          TAN-B
        local key0 is list  (0.00   ,1.0000         ,0.00           ,0.00).
        local key1 is list  (0.85   ,1.0000         ,0.00           ,0.00).
        local key2 is list  (1.10   ,0.2500         ,-0.02215106    ,-0.02487721).
        local key3 is list  (1.40   ,0.2200         ,-0.03391732    ,-0.03391732).
        local key4 is list  (5.00   ,0.1500         ,-0.001198566   ,-0.001198566).
        local key5 is list  (25.00  ,0.1400         ,-0.00          ,-0.00).
        return list(
            key0,key1,key2,key3,key4,key5).
    }

    function getWingAoACurve {
        // PRIVATE getAoACurve :: nothing -> 2D Array
        //                   AoA        Cor             TAN-A          TAN-B
        local key0 is list  (0.00       ,0.0100         ,0.00           ,0.00).
        local key1 is list  (0.3420201  ,0.0600         ,0.1750731      ,0.1750731).
        local key2 is list  (0.50       ,0.2400         ,2.60928        ,2.60928).
        local key3 is list  (0.7071068  ,1.7000         ,3.349777       ,3.349777).
        local key4 is list  (1.00       ,2.4000         ,1.387938       ,0.00).
        return list(
            key0,key1,key2,key3,key4).
    }

    function getWingMachCurve {
        // PRIVATE getAoACurve :: nothing -> 2D Array
        //                   Mach       Cor             TAN-A          TAN-B
        local key0 is list  (0.00       ,0.3500         ,0.00           ,-0.8463008).
        local key1 is list  (0.15       ,0.1250         ,0.00           ,0.00).
        local key2 is list  (0.90       ,0.2750         ,0.541598       ,0.541598).
        local key3 is list  (1.10       ,0.7500         ,0.00           ,0.00).
        local key4 is list  (1.40       ,0.4000         ,-0.3626955     ,-0.3626955).
        local key5 is list  (1.60       ,0.3500         ,-0.1545923     ,-0.1545923).
        local key6 is list  (2.00       ,0.3000         ,-0.09013031    ,-0.09013031).
        local key7 is list  (5.00       ,0.2200         ,0.00           ,0.00).
        local key8 is list  (25.00      ,0.3000         ,0.0006807274   ,0.00).
        return list(
            key0,key1,key2,key3,key4,key5,key6,key7,key8).
    }

    function getWingLiftAoACurve {
        // PRIVATE getWingLiftAoACurve :: nothing -> 2D Array
        //                   AoA        Cor             TAN-A          TAN-B
        local key0 is list  (0.00       ,0.0000         ,0.00           ,1.965926).
        local key1 is list  (0.258819   ,0.5114774      ,1.990092       ,1.905806).
        local key2 is list  (0.50       ,0.9026583      ,0.7074468      ,-0.7074468).
        local key3 is list  (0.7071068  ,0.5926583      ,-2.087948      ,-1.990095).
        local key4 is list  (1.00       ,0.0000         ,-2.014386      ,-2.014386).
        return list(
            key0,key1,key2,key3,key4).
    }

    function getWingLiftMachCurve {
        // PRIVATE getWingLiftMachCurve :: nothing -> 2D Array
        //                   Mach       Cor             TAN-A          TAN-B
        local key0 is list  (0.00       ,1.0000         ,0.00           ,0.00).
        local key1 is list  (0.30       ,0.5000         ,-1.671345      ,-0.8273422).
        local key2 is list  (1.00       ,0.125          ,-0.0005291355  ,-0.02625772).
        local key3 is list  (5.00       ,0.0625         ,0.00           ,0.00).
        local key4 is list  (25.0       ,0.0500         ,0.00           ,0.00).
        return list(
            key0,key1,key2,key3,key4).
    }

    function getBodyLiftAoACurve {
        // PRIVATE getBodyLiftAoACurve :: nothing -> 2D Array
        //                   AoA        Cor             TAN-A          TAN-B
        local key0 is list  (0.00       ,0.0000         ,0.00           ,1.975376).
        local key1 is list  (0.309017   ,0.5877852      ,1.565065       ,1.565065).
        local key2 is list  (0.5877852  ,0.9510565      ,0.735902       ,0.735902).
        local key3 is list  (0.7071068  ,1.0000         ,0.00           ,0.00).
        local key4 is list  (0.8910065  ,0.809017       ,-2.70827       ,-2.70827).
        local key5 is list  (1.00       ,0.0000         ,-11.06124      ,0.00).
        return list(
            key0,key1,key2,key3,key4,key5).
    }

    function getBodyLiftMachCurve {
        // PRIVATE getBodyLiftMachCurve :: nothing -> 2D Array
        //                   Mach       Cor             TAN-A          TAN-B
        local key0 is list  (0.30       ,0.1670         ,0.00           ,0.00).
        local key1 is list  (0.80       ,0.1670         ,0.00           ,-0.3904104).
        local key2 is list  (1.00       ,0.125          ,-0.0005291355  ,-0.02625772).
        local key3 is list  (5.00       ,0.0625         ,0.00           ,0.00).
        local key4 is list  (25.0       ,0.0500         ,0.00           ,0.00).
        return list(
            key0,key1,key2,key3,key4).
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

    function correctInitialCd {
        // PRIVATE correctInitialCd :: float -> float
        parameter       rawCD.

        if (rawCD <= 0) return 0. if (rawCD >= 1) return 1.
        local keyValues is getKeyValues(rawCD, getInitialCdCurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(rawCD)).
    }

    function correctMachCd {
        // PRIVATE correctMachCd :: float -> kosDelegate
        parameter       rawMn is 0.5.

        local keyValues is getKeyValues(rawMn, getMachCdCurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {parameter       rawMn.
            // kosDelegate :: float -> float
            if (rawMn > endKey[0]) or (rawMn < beginKey[0]) {
                if rawMn <= 0 return 1.
                else if rawMn >= 5 return 3.
                set keyValues to getKeyValues(rawMn, getMachCdCurve()).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(rawMn)). }.
    }

    function correctReynoldsCd {
        // PRIVATE correctReynoldsCd :: float -> kosDelegate
        parameter       pseudoReynolds is 1500.

        local keyValues is getKeyValues(pseudoReynolds, getReynoldsCurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {parameter       pseudoReynolds.
            // kosDelegate :: float -> float
            if (pseudoReynolds > endKey[0]) or (pseudoReynolds < beginKey[0]) {
                if pseudoReynolds <= 0 return 4.
                else if pseudoReynolds >= 10000 return 0.95.
                set keyValues to getKeyValues(pseudoReynolds, getReynoldsCurve()).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(pseudoReynolds)). }.
    }

    function correctOverallDrag {
        // PRIVATE correctOverallDrag :: float -> kosDelegate
        parameter       overallDragVal is 0.5.

        local keyValues is getKeyValues(overallDragVal, getOverallDragCurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {parameter       overallDragVal.
            // kosDelegate :: float -> float
            if (overallDragVal > endKey[0]) or (overallDragVal < beginKey[0]) {
                if overallDragVal <= 0 return 0.5.
                else if overallDragVal >= 25 return 0.95.
                set keyValues to getKeyValues(overallDragVal, getOverallDragCurve()).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(overallDragVal)). }.
    }

    function correctTipDrag {
        // PRIVATE correctTipDrag :: float -> kosDelegate
        parameter       tipDragVal is 0.5.

        local keyValues is getKeyValues(tipDragVal, getTipCurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {parameter       tipDragVal.
            // kosDelegate :: float -> float
            if (tipDragVal > endKey[0]) or (tipDragVal < beginKey[0]) {
                if tipDragVal <= 0 return 1.
                else if tipDragVal >= 5 return 4.
                set keyValues to getKeyValues(tipDragVal, getTipCurve()).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(tipDragVal)). }.
    }

    function correctSurfaceDrag {
        // PRIVATE correctSurfaceDrag :: float -> kosDelegate
        parameter       surfaceDragVal is 0.5.

        local keyValues is getKeyValues(surfaceDragVal, getSurfaceCurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {parameter       surfaceDragVal.
            // kosDelegate :: float -> float
            if (surfaceDragVal > endKey[0]) or (surfaceDragVal < beginKey[0]) {
                if surfaceDragVal <= 0 return 0.02.
                else if surfaceDragVal >= 25 return 0.001428571.
                set keyValues to getKeyValues(surfaceDragVal, getSurfaceCurve()).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(surfaceDragVal)). }.
    }

    function correctTailDrag {
        // PRIVATE correctTailDrag :: float -> kosDelegate
        parameter       tailDragVal is 0.5.

        local keyValues is getKeyValues(tailDragVal, getTailCurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {parameter       tailDragVal.
            // kosDelegate :: float -> float
            if (tailDragVal > endKey[0]) or (tailDragVal < beginKey[0]) {
                if tailDragVal <= 0 return 1.
                else if tailDragVal >= 25 return 0.14.
                set keyValues to getKeyValues(tailDragVal, getTailCurve()).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(tailDragVal)). }.
    }

    function correctWingAoACD {
        // PRIVATE getWingAoACD :: float -> kosDelegate
        parameter       AoA is 0.1.

        local keyValues is getKeyValues(AoA, getWingAoACurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {parameter       AoA.
            // kosDelegate :: float -> float
            if (AoA > endKey[0]) or (AoA < beginKey[0]) {
                if AoA <= 0 return 0.01.
                else if AoA >= 1 return 2.40.
                set keyValues to getKeyValues(AoA, getWingAoACurve()).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(AoA)). }.
    }

    function correctWingMachCD {
        // PRIVATE getWingMachCD :: float -> kosDelegate
        parameter       rawMN is 0.1.

        local keyValues is getKeyValues(rawMN, getWingMachCurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {parameter       rawMN.
            // kosDelegate :: float -> float
            if (rawMN > endKey[0]) or (rawMN < beginKey[0]) {
                if rawMN <= 0 return 0.35.
                else if rawMN >= 25 return 0.30.
                set keyValues to getKeyValues(rawMN, getWingMachCurve()).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(rawMN)). }.
    }

    function correctWingLiftAoACD {
        // PRIVATE correctWingLiftAoACD :: float -> kosDelegate
        parameter       AoA is 0.1.

        local keyValues is getKeyValues(AoA, getWingLiftAoACurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {parameter       AoA.
            // kosDelegate :: float -> float
            if (AoA > endKey[0]) or (AoA < beginKey[0]) {
                if AoA <= 0 return 0.
                else if AoA >= 1 return 0.
                set keyValues to getKeyValues(AoA, getWingLiftAoACurve()).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(AoA)). }.
    }

    function correctWingLiftMachCD {
        // PRIVATE correctWingLiftMachCD :: float -> kosDelegate
        parameter       rawMN is 0.1.

        local keyValues is getKeyValues(rawMN, getWingLiftMachCurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {parameter       rawMN.
            // kosDelegate :: float -> float
            if (rawMN > endKey[0]) or (rawMN < beginKey[0]) {
                if rawMN <= 0 return 1.
                else if rawMN >= 25 return 0.05.
                set keyValues to getKeyValues(rawMN, getWingLiftMachCurve()).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(rawMN)). }.
    }

    function correctBodyLiftAoA {
        // PRIVATE correctBodyLiftAoA :: float -> kosDelegate
        parameter       AoA is 0.1.

        local keyValues is getKeyValues(AoA, getBodyLiftAoACurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {parameter       AoA.
            // kosDelegate :: float -> float
            if (AoA > endKey[0]) or (AoA < beginKey[0]) {
                if AoA <= 0 return 0.
                else if AoA >= 1 return 0.
                set keyValues to getKeyValues(AoA, getBodyLiftAoACurve()).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(AoA)). }.
    }

    function correctBodyLiftMach {
        // PRIVATE correctBodyLiftMach :: float -> kosDelegate
        parameter       rawMN is 0.4.

        local keyValues is getKeyValues(rawMN, getBodyLiftMachCurve()).
        local beginKey is keyValues[0].
        local endKey is keyValues[1].

        return {parameter       rawMN.
            // kosDelegate :: float -> float
            if (rawMN > endKey[0]) or (rawMN < beginKey[0]) {
                if rawMN <= 0.3 return 0.1670.
                else if rawMN >= 25 return 0.05.
                set keyValues to getKeyValues(rawMN, getBodyLiftMachCurve()).
                set beginKey to keyValues[0].
                set endKey to keyValues[1].
            }
            return hermiteInterpolator(beginKey[0],endKey[0],beginKey[1],endKey[1],beginKey[3],endKey[2],abs(rawMN)). }.
    }

    function createDragProfile {
        // PUBLIC createDragProfile :: 2D Associative Array : lexicon -> lexicon
        parameter       vesselPartList,
                        parametersCollection.

        // Creating variables
        local totalBodyArea is 0.
        // Creating lists for all types of parts and values
        local tipCdList is list(). local tipAList is list().
        local surfaceCdList is list(). local surfaceAList is list().
        local tailCdList is list(). local tailAList is list().
        local wingCdList is list(). local wingAList is list().
        local wingClList is list(). local wingAoIList is list().
        local specialCdList is list(). local specialAList is list().
        local bodyClList is list(). local bodyAList is list().
        local bodyAoIList is list().
        local capsuleClList is list(). local capsuleAList is list().
        local capsuleAoIList is list().
        // Initializing all drag correction curves
        local getOverallDragMultiplier is correctOverallDrag().
        local getMachMultiplier is correctMachCd().
        local getReynoldsMultiplier is correctReynoldsCd().
        local getTipMultiplier is correctTipDrag().
        local getSurfaceMultiplier is correctSurfaceDrag().
        local getTailMultiplier is correctTailDrag().
        local getWingLiftAoAMultiplier is correctWingLiftAoACD().
        local getWingLiftMachMultiplier is correctWingLiftMachCD().
        local getWingAoAMultiplier is correctWingAoACD().
        local getWingMachMultiplier is correctWingMachCD().
        local getBodyLiftAoAMultiplier is correctBodyLiftAoA().
        local getBodyLiftMachMultiplier is correctBodyLiftMach().
        // Iterating over all parts and adding them to the appropiate list
        for part in vesselPartList:keys {
            for key in vesselPartList[part]:keys {
                if vesselPartList[part][key]:tostring:contains("Cd: ") and (vesselPartList[part]["Excluded"] = "False") {
                    local acdValue is vesselPartList[part][key].
                    local aValue is acdValue:split("Cd:")[0]:split("A: ")[1]:toscalar().
                    local cdValue is acdValue:split("Cd:")[1]:toscalar().
                    set cdValue to correctInitialCd(cdValue).
                    local vdotX is vesselPartList[part]["vdotX"].
                    local vdotY is vesselPartList[part]["vdotY"].
                    local vdotZ is vesselPartList[part]["vdotZ"].
                    // Checking for conditions and modifying values if appropiate
                    if vesselPartList[part]:haskey("ModuleDragModifier") {
                        if vesselPartList[part]:haskey("ModuleParachute") {
                            if vesselPartList[part]["Parachute Deployed"] = "Semideployed" set aValue to aValue*(vesselPartList[part]["Dragmodifier Chute Semideployed"]).
                            else if vesselPartList[part]["Parachute Deployed"] = "Deployed" set aValue to aValue*(vesselPartList[part]["Dragmodifier Chute Deployed"]).
                        }
                        if vesselPartList[part]:haskey("ModuleWheelDeployment") {
                            if vesselPartList[part]["Extended"] = "True" set aValue to aValue*(vesselPartList[part]["Dragmodifier Deployed"]).
                            else if vesselPartList[part]["Extended"] = "False" set aValue to aValue*(vesselPartList[part]["Dragmodifier Retracted"]).
                        }
                    }
                    if (vesselPartList[part]["type"] = "Body") or (vesselPartList[part]["type"] = "Bodylift") or (vesselPartList[part]["type"] = "CapsuleLift") {
                        set totalBodyArea to totalBodyArea+aValue.
                        if key:contains("YP Default") {
                            if vdotY > (1E-3) {tipCdList:add(cdValue). tipAList:add(aValue*vdotY).}
                            else if vdotY < (-1E-3) {tailCdList:add(cdValue). tailAList:add(aValue*abs(vdotY)).}
                            if abs(vdotY) < (1-1E-3) {surfaceCdList:add(cdValue). surfaceAList:add(aValue*sin(arcCos(vdotY))).}}
                        else if key:contains("YN Default") {
                            if vdotY > (1E-3) {tailCdList:add(cdValue). tailAList:add(aValue).}
                            else if vdotY < (-1E-3) {tipCdList:add(cdValue). tipAList:add(aValue*abs(vdotY)).}
                            if abs(vdotY) < (1-1E-3) {surfaceCdList:add(cdValue). surfaceAList:add(aValue*sin(arcCos(vdotY))).}}                   
                        else if key:contains("ZP Default") {
                            if vdotZ > (1E-3) {tipCdList:add(cdValue). tipAList:add(aValue*abs(vdotZ)).}
                            else if vdotZ < (-1E-3) {tailCdList:add(cdValue). tailAList:add(aValue*abs(vdotZ)).}
                            if abs(vdotZ) < (1-1E-3) {surfaceCdList:add(cdValue). surfaceAList:add(aValue*sin(arcCos(vdotZ))).}}  
                        else if key:contains("ZN Default") {
                            if vdotZ < (-1E-3) {tipCdList:add(cdValue). tipAList:add(aValue*abs(vdotZ)).}
                            else if vdotZ > (1E-3) {tailCdList:add(cdValue). tailAList:add(aValue*abs(vdotZ)).}
                            if abs(vdotZ) < (1-1E-3) {surfaceCdList:add(cdValue). surfaceAList:add(aValue*sin(arcCos(vdotZ))).}}  
                        else if key:contains("XP Default") {
                            if vdotX > (1E-3) {tipCdList:add(cdValue). tipAList:add(aValue*abs(vdotX)).}
                            else if vdotX < (-1E-3) {tailCdList:add(cdValue). tailAList:add(aValue*abs(vdotX)).}
                            if abs(vdotX) < (1-1E-3) {surfaceCdList:add(cdValue). surfaceAList:add(aValue*sin(arcCos(vdotX))).}}  
                        else if key:contains("XN Default") {
                            if vdotX < (-1E-3) {tipCdList:add(cdValue). tipAList:add(aValue*abs(vdotX)).}
                            else if vdotX > (1E-3) {tailCdList:add(cdValue). tailAList:add(aValue*abs(vdotX)).}
                            if abs(vdotX) < (1-1E-3) {surfaceCdList:add(cdValue). surfaceAList:add(aValue*sin(arcCos(vdotX))).}}
                        if (vesselPartList[part]["type"] = "Bodylift") and (key:contains("YP Default")) {
                            bodyClList:add(getBodyLiftAoAMultiplier(abs(vdotZ))).
                            bodyAoIList:add(abs(vdotZ)).
                            bodyAList:add(vesselPartList[part]["deflectionLiftCoeff"]).
                        }
                        else if (vesselPartList[part]["type"] = "CapsuleLift") and (key:contains("YP Default")) {
                            capsuleClList:add(getBodyLiftAoAMultiplier(abs(vdotZ))).
                            capsuleAoIList:add(abs(vdotZ)).
                            capsuleAList:add(vesselPartList[part]["deflectionLiftCoeff"]).
                        }
                    } else if (vesselPartList[part]["type"] = "Wing") or (vesselPartList[part]["type"] = "AeroSurface") {
                        if key:contains("YP Default") {
                            if vesselPartList[part]:haskey("Extended") {
                                if vesselPartList[part]["Extended"] = "True" {
                                    set vesselPartList[part]["deflection angle"] to sin(vesselPartList[part]["deploy angle"] + arcSin(max(min(vdotZ,1),-1))).
                                } else set vesselPartList[part]["deflection angle"] to abs(vdotZ).
                            }
                            set aValue to vesselPartList[part]["deflectionLiftCoeff"].
                            if vesselPartList[part]:haskey("deflection angle") set cdValue to getWingAoAMultiplier(vesselPartList[part]["deflection angle"]).
                            else set cdValue to getWingAoAMultiplier(abs(vdotZ)).
                            wingClList:add(getWingLiftAoAMultiplier(abs(vdotZ))).
                            wingAoIList:add(abs(vdotZ)).
                            wingCdList:add(cdValue).
                            wingAList:add(aValue).
                        }
                    } else if (vesselPartList[part]["type"] = "Airbrake") {
                        if key:contains("YP Default") {  
                            if vesselPartList[part]["Extended"] = "True" {
                                // Note that the next line is due to a bug in the airbrake drag system; an issue for this is already opened
                                set vesselPartList[part]["deflection angle"] to sin(vesselPartList[part]["deploy angle"] - arcSin(max(min(vdotZ,1),-1))).
                            } else set vesselPartList[part]["deflection angle"] to abs(vdotZ).
                            local airbrakeDeflection is vesselPartList[part]["deflection angle"].
                            set aValue to vesselPartList[part]["deflectionLiftCoeff"].
                            set cdValue to getWingAoAMultiplier(abs(airbrakeDeflection)).
                            specialCdList:add(cdValue).
                            specialAList:add(aValue).               
                        }             
                    } 
                }
            }
        }

        function dragCubeMachAdjust {
            // PRIVATE dragCubeMachAdjust :: list : float -> list
            parameter       iList, machMultiplier.
            local corList is list().
            for cdValue in iList {
                corList:add((cdValue^machMultiplier)).
            } 
            return corList.
        }

        function getACDValues {
            // PRIVATE getACDValues :: list : list -> list
            parameter       cdList, aList.
            local index is 0.
            local totalValue is 0.
            for value in cdList {
                set totalValue to totalValue + (value*alist[index]).
                set index to index+1.
            }
            return totalValue.
        }

        function multiplyLists {
            // PRIVATE multiplyLists :: list : list -> list
            parameter       listA, listB.
            local index is 0.
            local listC is list().
            for value in listA {
                listC:add(value*listB[index]).
                set index to index+1.
            }
            return listC.
        }

        //// COMMUTATIVE VALUES /////
        // This section combines some Area and Cd values in advance, as they are commutative in the full equation
        // This prevents doing it repeatably in the created function
        // NOTE: Dragcube values are Non-Commutative
        // Wing
        local wingLiftDragList is multiplyLists(wingClList, wingAoIList).
        local wingACD is getACDValues(wingCdList, wingAList) * 15.
        local wingLiftACD is getACDValues(wingClList, wingAList) * 36.
        local wingLiftDragACD is getACDValues(wingLiftDragList, wingAList) * 36.
        // Special
        local specialACD is getACDValues(specialCdList, specialAList) * 15.
        // Bodylift
        local bodyLiftDragList is multiplyLists(bodyClList, bodyAoIList).
        local bodyLiftDragACD is getACDValues(bodyLiftDragList, bodyAList) * 36.
        local bodyLiftACD is getACDValues(bodyClList, bodyAList) * 36.
        // CapsuleLift
        local capsuleLiftDragList is multiplyLists(capsuleClList, capsuleAoIList).
        local capsuleLiftDragACD is getACDValues(capsuleLiftDragList, capsuleAList) * 36.
        local capsuleLiftACD is getACDValues(capsuleClList, capsuleAList) * 36.
        // Return Lexicon for Information Display
        local returnLexicon is lexicon(
            "Dynamic Pressure", 0,
            "Body Drag", 0,
            "Wing Lift", 0,
            "Wing Drag", 0,
            "Wing Induced Drag", 0,
            "Total Wing Drag", 0,
            "Special Drag", 0,
            "Body Lift Induced Drag", 0,
            "Capsule Lift Induced Drag", 0,
            "Total Drag", 0,
            "Body Lift", 0,
            "Capsulse Lift", 0,
            "Lift-to-Drag Ratio", 0
        ).

        function realtimeDrag {
            // PUBLIC realtimeDrag :: float : float : float -> lexicon
            // This function's purpose is to provide actual real time drag information to the user
            parameter       tas, 
                            density,
                            mach.
            
            local reynoldsNumber is density*tas.
            local overallMultiplier is getOverallDragMultiplier(mach).
            local machMultiplier is getMachMultiplier(mach).
            local reynoldsMultiplier is getReynoldsMultiplier(reynoldsNumber).
            local tipMultiplier is getTipMultiplier(mach).
            local surfaceMultiplier is getSurfaceMultiplier(mach).
            local tailMultiplier is getTailMultiplier(mach).
            local wingMachMultiplier is getWingMachMultiplier(mach).
            local wingLiftMachMultiplier is getWingLiftMachMultiplier(mach).
            local bodyLiftMachMultiplier is getBodyLiftMachMultiplier(mach).
            local dynamicPressure is (0.5 * density * (tas^2)).
            set returnLexicon["Dynamic Pressure"] to dynamicPressure.
            set returnLexicon["Reynolds Number"] to reynoldsNumber.
            set returnLexicon["Overall Multiplier"] to overallMultiplier.
            set returnLexicon["Mach Multiplier"] to machMultiplier.
            set returnLexicon["Reynolds Multiplier"] to reynoldsMultiplier.
            set returnLexicon["Tip Multiplier"] to tipMultiplier.
            set returnLexicon["Surface Multiplier"] to surfaceMultiplier.
            set returnLexicon["Tail Multiplier"] to tailMultiplier.
            set returnLexicon["Wing Mach Multiplier"] to wingMachMultiplier.
            set returnLexicon["Wing Lift Mach Multiplier"] to wingLiftMachMultiplier.
            set returnLexicon["Body Lift Mach Multiplier"] to bodyLiftMachMultiplier.

            ///// DRAGCUBE /////
            // Mach Correction
            local curTipCdList is dragCubeMachAdjust(tipCdList, machMultiplier).
            local curSurfaceCdList is dragCubeMachAdjust(surfaceCdList, machMultiplier).
            local curTailCdList is dragCubeMachAdjust(tailCdList, machMultiplier).
            // Cd*A Multiplication
            local tipACD is getACDValues(curTipCdList, tipAList) * tipMultiplier.
            local surfaceACD is getACDValues(curSurfaceCdList, surfaceAList)  * surfaceMultiplier.
            local tailACD is getACDValues(curTailCdList, tailAList) * tailMultiplier.
            // Overall/Reynolds Multiplication
            local totalACD is (tipACD+surfaceACD+tailACD) * overallMultiplier * reynoldsMultiplier.
            local bodyDrag is dynamicPressure * totalACD * 0.8.
            local totalDrag is bodyDrag.

            set returnLexicon["Body Tip Drag"] to (tipACD*overallMultiplier*reynoldsMultiplier*dynamicPressure*0.8).
            set returnLexicon["Body Surface Drag"] to (surfaceACD*overallMultiplier*reynoldsMultiplier*dynamicPressure*0.8).
            set returnLexicon["Body Tail Drag"] to (tailACD*overallMultiplier*reynoldsMultiplier*dynamicPressure*0.8).
            set returnLexicon["Body Drag"] to totalDrag.
            set returnLexicon["Body Drag per Area"] to (totalDrag/totalBodyArea).

            ///// WING /////
            if wingCdList:length > 0 {
                local wingLift is dynamicPressure * wingLiftACD * wingLiftMachMultiplier.
                local wingDrag is wingACD * wingMachMultiplier.
                local wingLiftDrag is wingLiftDragACD * wingLiftMachMultiplier.
                local totalWingDrag is (wingDrag+wingLiftDrag) * dynamicPressure.
                set totalDrag to totalDrag+totalWingDrag.
                set returnLexicon["Wing Lift"] to wingLift.
                set returnLexicon["Wing Drag"] to wingDrag * dynamicPressure.
                set returnLexicon["Wing Induced Drag"] to wingLiftDrag * dynamicPressure.
                set returnLexicon["Total Wing Drag"] to totalWingDrag.
            }

            ///// SPECIAL /////
            if specialCdList:length > 0 {
                local specialDrag is specialACD * dynamicPressure * wingMachMultiplier.
                set totalDrag to totalDrag+specialDrag.
                set returnLexicon["Special Drag"] to specialDrag.
            }

            ///// BODYLIFT /////
            if bodyClList:length > 0 {
                local bodyLiftDrag is dynamicPressure * bodyLiftDragACD * bodyLiftMachMultiplier.
                local bodyLift is dynamicPressure * bodyLiftACD * bodyLiftMachMultiplier.
                set totalDrag to totalDrag+bodyLiftDrag.
                set returnLexicon["Body Lift Induced Drag"] to bodyLiftDrag.
                set returnLexicon["Body Lift"] to bodyLift.
            }

            ///// CAPSULELIFT /////
            if capsuleClList:length > 0 {
                local capsuleLiftDrag is dynamicPressure * capsuleLiftDragACD * 0.0625.
                local capsuleLift is dynamicPressure * capsuleLiftACD * 0.0625.
                set totalDrag to totalDrag+capsuleLiftDrag.
                set returnLexicon["Capsule Lift Induced Drag"] to capsuleLiftDrag.
                set returnLexicon["Capsulse Lift"] to capsuleLift.
            }
            
            set returnLexicon["Total Lift"] to returnLexicon["Capsulse Lift"]+returnLexicon["Body Lift"]+returnLexicon["Wing Lift"].
            set returnLexicon["Lift-to-Drag Ratio"] to returnLexicon["Total Lift"]/totalDrag.
            set returnLexicon["Total Drag"] to totalDrag.
            return (returnLexicon).
        }.

        function getDragProfile {
            // PUBLIC getDragProfile :: float : float : float : labelObject -> 2D Associative Array
            // This function's purpose is to create a dragProfile in a selected mach range, and return a lexicon of lexicons
            // Note that the lexicon contains both a body A*CD Value and a wing A*CD Value, as they require different approaches
            parameter   startMach,
                        endMach,
                        dT,
                        labelObject is "".

            // Preparing variables and lexicons
            local dragProfileLexicon is lexicon(
                "Selected Configuration", parametersCollection,
                "startMach", startMach,
                "endMach", endMach,
                "dT", dT
            ).
            
            local numberIterations is (endMach-startMach)/dT.

            from {local i is round(startMach/dT,1).} until i > (round(endMach/dT,1)) step {set i to round(i+1,1).} do {
                local mach is i*dT.
                local machMultiplier is getMachMultiplier(mach).
                local overallMultiplier is getOverallDragMultiplier(mach).
                local tipMultiplier is getTipMultiplier(mach).
                local surfaceMultiplier is getSurfaceMultiplier(mach).
                local tailMultiplier is getTailMultiplier(mach).
                local wingMachMultiplier is getWingMachMultiplier(mach).
                local wingLiftMachMultiplier is getWingLiftMachMultiplier(mach).
                local bodyLiftMachMultiplier is getBodyLiftMachMultiplier(mach).
                local wingDragACDValue is 0.
                local specialDragACDValue is 0.
                local bodyLiftDragACDValue is 0.
                local capsuleLiftDragACDValue is 0.

                ///// DRAGCUBE /////
                // Mach Correction
                local curTipCdList is dragCubeMachAdjust(tipCdList, machMultiplier).
                local curSurfaceCdList is dragCubeMachAdjust(surfaceCdList, machMultiplier).
                local curTailCdList is dragCubeMachAdjust(tailCdList, machMultiplier).
                // Cd*A Multiplication
                local tipACD is getACDValues(curTipCdList, tipAList) * tipMultiplier.
                local surfaceACD is getACDValues(curSurfaceCdList, surfaceAList)  * surfaceMultiplier.
                local tailACD is getACDValues(curTailCdList, tailAList) * tailMultiplier.
                // Overall Multiplication
                local bodyDragACDValue is (tipACD+surfaceACD+tailACD) * overallMultiplier * 0.8.
                ///// WING /////
                if wingCdList:length > 0 {
                    local wingDrag is wingACD * wingMachMultiplier.
                    local wingLiftDrag is wingLiftDragACD * wingLiftMachMultiplier.
                    set wingDragACDValue to (wingDrag+wingLiftDrag).
                }
                ///// SPECIAL /////
                if specialCdList:length > 0 {
                    set specialDragACDValue to specialACD * wingMachMultiplier.
                }
                ///// BODYLIFT /////
                if bodyClList:length > 0 {
                    set bodyLiftDragACDValue to bodyLiftDragACD * bodyLiftMachMultiplier.
                }
                ///// CAPSULELIFT /////
                if capsuleClList:length > 0 {
                    set capsuleLiftDragACDValue to capsuleLiftDragACD * 0.0625.
                }
                local nonBodyDragACDValue is wingDragACDValue+specialDragACDValue+bodyLiftDragACDValue+capsuleLiftDragACDValue.

                ///// FILE CREATION /////
                set dragProfileLexicon[i] to list(list(mach, bodyDragACDValue), list(mach, nonBodyDragACDValue)).         

                ///// Catmull–Rom Spline Creation /////      
                if i > ((startMach/dT)+1) {
                    for dragType in range(0,2) {
                        local i0 is i-2.
                        local i1 is i.
                        local i2 is i-1.
                        local t0 is dragProfileLexicon[i0][dragType][0].
                        local t1 is dragProfileLexicon[i1][dragType][0].
                        local t2 is dragProfileLexicon[i2][dragType][0].
                        local y0 is dragProfileLexicon[i0][dragType][1].
                        local y1 is dragProfileLexicon[i1][dragType][1].
                        local y2 is dragProfileLexicon[i2][dragType][1].
                        local m0 is (y1-y0)/(t1-t0).
                        local m1 is m0.
                        set dragProfileLexicon[i2][dragType] to list(t2, y2, m0, m1).
                    }
                }
                if i = ((endMach/dT)) {
                    for dragType in range(0,2) {
                        // Begin Key
                        local i0 is startMach/dT.
                        local i1 is (startMach/dT)+1.
                        local t0 is dragProfileLexicon[i0][dragType][0].
                        local t1 is dragProfileLexicon[i1][dragType][0].
                        local y0 is dragProfileLexicon[i0][dragType][1].
                        local y1 is dragProfileLexicon[i1][dragType][1].
                        local m1 is (y1-y0)/(t1-t0).
                        local m0 is m1.
                        set dragProfileLexicon[i0][dragType] to list(t0, y0, m0, m1).
                        // End Key
                        set i0 to (endMach/dT)-1.
                        set i1 to endMach/dT.
                        set t0 to dragProfileLexicon[i0][dragType][0].
                        set t1 to dragProfileLexicon[i1][dragType][0].
                        set y0 to dragProfileLexicon[i0][dragType][1].
                        set y1 to dragProfileLexicon[i1][dragType][1].
                        set m0 to (y1-y0)/(t1-t0).
                        set m1 to m0.
                        set dragProfileLexicon[i1][dragType] to list(t1, y1, m0, m1).
                    }
                }  
                local progress is (i/numberIterations)*100.
                if labelObject <> "" set labelObject:text to "Progress : "+progress+" %".
            }

            return dragProfileLexicon.

        }

        return lexicon(
            "getRealtimeDrag", realtimeDrag@,
            "getDragProfile", getDragProfile@
        ).

    }

    return lexicon(
        "hermiteInterpolator", hermiteInterpolator@,
        "getReynolds", correctReynoldsCd@,
        "createProfile", createDragProfile@
    ).
}

global lib_DragProfile is dragProfileMain().
