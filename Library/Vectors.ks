//////////////////////////////////////////
// Vectors and Orientation              //
// By Ren0k                             //
//////////////////////////////////////////
@lazyGlobal off.

function get_VesselOrientation {
    // PUBLIC get_AtmosphericFlightData :: nothing -> lexicon

    function getRoll {
        // PUBLIC getRoll :: nothing -> float
        local sideDirection is vcrs(up:vector, facing:forevector).
        local arcVal1 is vdot(facing:topvector, sideDirection).
        local arcVal2 is vdot(facing:starvector, sideDirection).
        return arctan2(arcVal1, arcVal2).
    }

    function getPitch {
        // PUBLIC getPitch :: nothing -> float
        return 90-vang(up:forevector, facing:forevector).
    }

    function getHeading {
        // PUBLIC getHeading :: nothing -> float
        return mod(360-ship:bearing,360).
    }

    function relBearing {
        // PUBLIC relBearing :: float : float -> float
        parameter   targetHeading,
                    curHeading is getHeading().
        
        return mod((targetHeading - curHeading + 540), 360)-180.
    }

    function rotateQuaternion {
        // PUBLIC rotateQuaternion :: vector : float : float : float -> vector
        parameter       inputVec,
                        pitch,
                        yaw,
                        roll.

        local cr is cos(yaw/2).
        local cp is cos(pitch/2).
        local cy is cos(-roll/2).
        local sr is sin(yaw/2).
        local sp is sin(pitch/2).
        local sy is sin(-roll/2).
        local cpcy is cp * cy.
        local spsy is sp * sy.
        local w is (cr * cpcy + sr * spsy).
        local x is (sr * cpcy - cr * spsy).
        local y is (cr * sp * cy + sr * cp * sy).
        local z is (cr * cp * sy - sr * sp * cy).

        return (inputVec:direction + Q(x,y,z,w)):vector.
    }

    return lexicon (
        "getRoll", getRoll@,
        "getPitch", getPitch@,
        "getHeading", getHeading@,
        "getRelBearing", relBearing@,
        "rotateQuaternion", rotateQuaternion@
    ).
}

global lib_VesselOrientation is get_VesselOrientation().