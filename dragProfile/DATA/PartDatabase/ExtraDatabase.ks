//////////////////////////////////////////
// Database of aero parts               //
// By Ren0k                             //
//////////////////////////////////////////
// This file contains collections of parameters that can not be obtained any other means

@lazyGlobal off.

function getDeflectionLiftCoeff {
    // PUBLIC getDeflectionLiftCoeff :: Nothing -> Lexicon
    local liftCoeffCollection is lexicon (
        "wingConnector", 2.0,
        "wingConnector2", 2.0,
        "wingConnector3", 1.0,
        "wingConnector4", 0.5,
        "wingConnector5", 0.5,
        "deltaWing", 2.0,
        "delta.small", 0.5,
        "StandardCtrlSrf", 0.25,
        "elevon2", 0.3,
        "elevon3", 0.42,
        "smallCtrlSrf", 0.18,
        "elevon5", 0.4,
        "wingStrake", 0.5,
        "structuralWing", 1.0,
        "structuralWing2", 1.0,
        "structuralWing3", 0.5,
        "structuralWing4", 0.25,
        "sweptWing1", 1.13,
        "sweptWing2", 2.26,
        "winglet3", 0.65,
        "winglet", 0.37,
        "R8winglet", 0.5,
        "wingShuttleDelta", 5.0,
        "wingShuttleElevon1", 0.77,
        "wingShuttleElevon2", 1.16,
        "wingShuttleRudder", 3.49,
        "wingShuttleStrake", 1.0,
        "HeatShield0", 0.0875,
        "HeatShield1", 0.35,
        "HeatShield2", 1.5,
        "HeatShield3", 3.375,
        "basicFin", 0.12,
        "AdvancedCanard", 0.4,
        "CanardController", 0.52,
        "sweptWing", 1.37,
        "tailfin", 0.61,
        "airlinerCtrlSrf", 0.86,
        "airlinerMainWing", 7.8,
        "airlinerTailFin", 2.69,
        "airbrake1", 0.38,
        "mk1pod.v2", 0.35,
        "mk2Cockpit.Inline", 0.47,
        "mk2Cockpit.Standard", 0.6,
        "mk1.3pod", 1.4,
        "mk1pod", 0.35,
        "mk2Fuselage", 0.7,
        "mk2FuselageShortLiquid", 0.35,
        "mk2FuselageLongLFO", 0.7,
        "mk2FuselageShortLFO", 0.35,
        "mk2FuselageShortMono", 0.35,
        "mk2.1m.Bicoupler", 0.3,
        "mk2.1m.AdapterLong", 0.6,
        "mk2SpacePlaneAdapter", 0.28,
        "mk2CrewCabin", 0.35,
        "mk2CargoBayL", 0.7,
        "mk2CargoBayS", 0.35,
        "mk2DockingPort", 0.24,
        "HeatShield1p5", 1.5,
        "largeFanBlade", 0.1,
        "largeHeliBlade", 1.6,
        "largePropeller", 0.12,
        "mediumFanBlade", 0.025,
        "mediumHeliBlade", 0.4,
        "mediumPropeller", 0.03,
        "smallFanBlade", 0.00625,
        "smallHeliBlade", 0.1,
        "smallPropeller", 0.0075
    ).
    return liftCoeffCollection.
}

function getCapsuleBottomList {
    // PUBLIC getCapsuleBottomList :: nothing -> lexicon
    local capsuleBottomList is lexicon(
        "mk1pod", True,
        "mk1.3pod", True,
        "mk1pod.v2", True,
        "HeatShield0", True,
        "HeatShield1", True,
        "HeatShield2", True,
        "HeatShield3", True
    ).
    return capsuleBottomList.
}

function getDragModifierList {
    // PUBLIC getDragModifierList :: Nothing -> 2D Associative Array
    local dragModifierList is lexicon(
        "SmallGearBay", lexicon("Deployed", 2, "Retracted", 0.5),
        "GearLarge", lexicon("Deployed", 2, "Retracted", 0.5),
        "GearMedium", lexicon("Deployed", 2, "Retracted", 0.5),
        "GearSmall", lexicon("Deployed", 2, "Retracted", 0.5),
        "parachuteSingle", lexicon("Semideployed", 1.25, "Deployed", 12),
        "parachuteRadial", lexicon("Semideployed", 1, "Deployed", 58),
        "radialDrogue", lexicon("Semideployed", 2.5, "Deployed", 8),
        "parachuteLarge", lexicon("Semideployed", 0.67, "Deployed", 25),
        "parachuteDrogue", lexicon("Semideployed", 0.67, "Deployed", 3.5)
    ).
    return dragModifierList.
}

function getPartVariantList {
    // PUBLIC getPartVariantList :: Nothing -> 2D Associative Array
    local partVariantList is lexicon(
        "liquidEngineMini.v2", lexicon("Shroud", 2, "TrussMount", 3, "Bare", 4),
        "microEngine.v2", lexicon("Shroud", 0, "Bare", 1),
        "radialEngineMini.v2", lexicon("Shroud", 0, "Bare", 1),
        "liquidEngine3.v2", lexicon("Shroud", 2, "TrussMount", 3, "Bare", 4),
        "liquidEngineMainsail.v2", lexicon("Full", 0, "Mid", 1, "Bare", 2),
        "engineLargeSkipper.v2", lexicon("Shroud", 2, "TrussMount", 3, "Bare", 4),
        "liquidEngine2-2.v2", lexicon("DoubleBell", 2, "SingleBell", 3),
        "LiquidEngineKE-1", lexicon("Full", 0, "Mid", 1, "Bare", 2),
        "LiquidEngineLV-T91", lexicon("Cap", 0, "Bare", 1),
        "LiquidEngineLV-TX87", lexicon("TankButt", 0, "TrussMount", 1),
        "LiquidEngineRE-I2", lexicon("Shroud", 0, "Bare", 1),
        "LiquidEngineRE-J10", lexicon("Shroud", 0, "Bare", 1),
        "LiquidEngineRK-7", lexicon("Bare", 0, "ShroudSmall", 1, "ShroudBig", 2),
        "EnginePlate1p5", lexicon("Short", 0, "Medium-Short", 1, "Medium", 2, "Medium-Long", 3, "Long", 4),
        "EnginePlate2", lexicon("Short", 0, "Medium-Short", 1, "Medium", 2, "Medium-Long", 3, "Long", 4),
        "EnginePlate3", lexicon("Short", 0, "Medium-Short", 1, "Medium", 2, "Medium-Long", 3, "Long", 4),
        "EnginePlate4", lexicon("Short", 0, "Medium-Short", 1, "Medium", 2, "Medium-Long", 3, "Long", 4)
    ).
    return partVariantList.
}