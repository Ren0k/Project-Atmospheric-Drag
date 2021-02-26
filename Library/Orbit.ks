//////////////////////////////////////////
// Orbital Functions                    //
// By Ren0k                             //
//////////////////////////////////////////
@LAZYGLOBAL off.

function getOrbitalRadius {
    // PUBLIC getOrbitalRadius :: float : float : float -> float
    // Get the distance from the center of the orbiting body
    parameter       sma is ship:orbit:semimajoraxis,
                    ecc is ship:orbit:eccentricity,
                    tran is ship:orbit:trueanomaly.

    return sma * (1 - ecc^2) / (1 + ecc * cos(tran)).
}

function getTrueAnomaly {
    // PUBLIC getTrueAnomaly :: float : float : float -> list
    // Get 2 True Anomaly Theta (θ) values 
    parameter       rad is ship:altitude+body:radius,
                    a is ship:orbit:semimajoraxis,
                    e is ship:orbit:eccentricity.

    set e to min(max(e,1e-5),1-(1e-5)).
    local θ is arcCos(min(max(((-a * e^2 + a - rad) / (e * rad)),-1),1)).
    
    return list(θ, 360-θ).
}

function getEccentricAnomaly {
    // PUBLIC getEccentricAnomaly :: float : float -> float
    // Get the Eccentric Anomaly from the True Anomaly
    parameter       θ is ship:orbit:trueanomaly,
                    e is ship:orbit:eccentricity.

    return arcTan2(sqrt(1-e^2) * sin(θ), e + cos(θ)).
}

function getMeanAnomaly {
    // PUBLIC getMeanAnomaly :: float : float : float -> float
    // Get the mean anomaly from the true anomaly
    parameter       θ is ship:orbit:trueanomaly,
                    e is ship:orbit:eccentricity,
                    Ea is getEccentricAnomaly(θ, e).
    
    local M is Ea - (e * sin(Ea) * constant:radtodeg).
    return mod(M + 360, 360).
}

function getThetaTime {
    // PUBLIC getThetaTime :: float : float : float : float -> float
    // Get the time difference between 2 True Anomalies
    parameter       θ1,
                    θ2,
                    e is ship:orbit:eccentricity,
                    P is ship:orbit:period.

    local M1 is getMeanAnomaly(θ1, e).
    local M2 is getMeanAnomaly(θ2, e).
    local ΔT is P * ((M2-M1) / 360).
    return mod(ΔT + P, P).
}

function getMeanNotion {
    // PUBLIC getMeanNotion :: float : float -> float
    // Get the Mean Notion or Angular Velocity 'ω'
    parameter       mu is ship:body:mu,
                    a is ship:orbit:semimajoraxis.

    return sqrt(mu/(a^3)).
}

function getLongitudeOfPeriapsis {
    // PUBLIC getLongitudeOfPeriapsis :: float : float -> float
    // Get the Longitude of Periapsis 'ϖ'
    parameter       Ω is ship:orbit:longitudeofascendingnode,
                    w is ship:orbit:argumentofperiapsis.
    
    return mod(Ω + w, 360).
}

function getMeanLongitude {
    // PUBLIC getMeanLongitude :: float : float -> float
    // Get the Mean Longitude -> λ=M+ϖ
    parameter       M is getMeanAnomaly(),
                    ϖ is getLongitudeOfPeriapsis().

    return mod(M + ϖ, 360).
}

function getPlanarCoordinates {
    // PUBLIC getPlanarCoordinates :: float : float : float : float -> vector
    // Returns the planar (2d) coordinates
    parameter       a is ship:orbit:semimajoraxis,
                    e is ship:orbit:eccentricity,
                    eA is getEccentricAnomaly(),
                    ϖ is getLongitudeOfPeriapsis().

    local ξ0 is a * (cos(eA) - e).
    local η0 is a * sqrt(1 - e^2) * sin(eA).
    local ξ is (ξ0 * cos(ϖ)) - (η0 * sin(ϖ)).
    local η is (ξ0 * sin(ϖ)) + (η0 * cos(ϖ)).
    return V(ξ, η, 0).
}

function getPlanarVelocities {
    // PUBLIC getPlanarVelocities :: float : float : float : float : float : float -> vector
    // Returns the planar (2d) velocity vector
    parameter       a is ship:orbit:semimajoraxis,
                    e is ship:orbit:eccentricity,
                    eA is getEccentricAnomaly(),
                    n is getMeanNotion(),
                    ϖ is getLongitudeOfPeriapsis(),
                    λ is getMeanLongitude().
                    
    local k is e * cos(ϖ).
    local h is e * sin(ϖ).
    local p is e * sin(eA).
    local q is e * cos(eA).
    if (k = 0) and (h = 0) {
        set p to 0. set q to 0.
    }
    local l is 1 - sqrt(1 - e^2).

    local ξη1 is ((a * n) / (1 - q)).
    local ξη2 is (V(-sin(λ + p), cos(λ + p), 0)).
    local ξη3 is (q / (2 - l)).
    local ξη4 is V(h, -k, 0).
    local ξη is ξη1 * (ξη2 + (ξη3*ξη4)).

    return ξη.
}

function getSpatialCoordinates {
    // PUBLIC getSpatialCoordinates :: float : float : float : float -> vector
    // Returns the spatial (3d) coordinates
    parameter       planarCoordinates is getPlanarCoordinates(),
                    i is ship:orbit:inclination,
                    Ω is ship:orbit:longitudeofascendingnode.

    local ξ is planarCoordinates:x.
    local η is getPlanarCoordinates:y.

    local ix is 2*sin(i/2)*cos(Ω).
    local iy is 2*sin(i/2)*sin(Ω).
    local iz is sqrt(4-(ix^2)-(iy^2)).

    local W is (ξ*ix) - (η*iy).

    local x is ξ + (iy*w)/2.
    local y is η - (ix*w)/2.
    local z is (iz*w)/2.

    return V(x,z,y).

}

function getSpatialVelocities {
    // PUBLIC getSpatialVelocities :: float : float : float : float -> list
    // Returns the spatial (3d) velocity vector
    parameter       planarVelocities is getPlanarVelocities(),
                    i is ship:orbit:inclination,
                    Ω is ship:orbit:longitudeofascendingnode.

    local ξ is planarVelocities:x.
    local η is planarVelocities:y.

    local ix is 2*sin(i/2)*cos(Ω).
    local iy is 2*sin(i/2)*sin(Ω).
    local iz is sqrt(4-(ix^2)-(iy^2)).

    local W is (ξ*ix) - (η*iy).

    local x is ξ + (iy*w)/2.
    local y is η - (ix*w)/2.
    local z is (iz*w)/2.

    return V(x,z,y).
}

function orbitFromElements {
    // PUBLIC orbitFromElements :: float (x8) -> orbit
    // Create an orbit struct from orbital elements
    parameter       ϵ is ship:orbit:epoch,
                    i is ship:orbit:inclination,
                    e is ship:orbit:eccentricity,
                    a is ship:orbit:semimajoraxis,
                    Ω is ship:orbit:longitudeofascendingnode,
                    w is ship:orbit:argumentofperiapsis,
                    θ is ship:orbit:meananomalyatepoch,
                    c is ship:body.

    return createOrbit(i, e, a, Ω, w, θ, ϵ, c).
}

function orbitFromVector {
    // PUBLIC orbitFromVector :: vector : vector : body : float -> orbit
    // Create an orbit struct from vectors
    parameter       posVec is -ship:body:position,
                    obtVelVec is ship:velocity:orbit,
                    c is ship:body,
                    kscUniversalTime is timestamp():seconds.

    set posVec to V(posVec:x, posVec:z, posVec:y).
    set obtVelVec to V(obtVelVec:x, obtVelVec:z, obtVelVec:y).

    return createOrbit(posVec, obtVelVec, c, kscUniversalTime).
}

function getTimeToAltitude {
    // PUBLIC getTimeToAltitude :: float : body : float : float : float : float : float : float -> float
    // Returns the time it takes to reach the target altitude for the 1st time
    parameter       targetAlt,
                    C is ship:body,
                    θ1 is ship:orbit:trueanomaly,
                    e is ship:orbit:eccentricity,
                    a is ship:orbit:semimajoraxis,
                    Ap is ship:orbit:apoapsis,
                    Pe is ship:orbit:periapsis,
                    Op is ship:orbit:period.

    local targetRad is targetAlt+C:radius.
    local P is 0.
    if Ap > 0 set P to Op.
    if (Ap > 0) and (e < 1) and (Pe < targetAlt) and (Ap > targetAlt) {
        local Thetas is getTrueAnomaly(targetRad, a, e).
        local θ2 is Thetas[0].
        local θ3 is Thetas[1].
        local T1 is getThetaTime(θ1, θ2, e, P).
        local T2 is getThetaTime(θ1, θ3, e, P).
        if T1 < T2 return T1.
        else return T2.
    } else {
        return 0.
    }
}

function altitudeToOrbit {
    // PUBLIC altitudeToOrbit :: float : vector : vector : body : float -> lexicon
    // Returns the orbit, time, position vector and velocity vector at the 1st target altitude crossing
    parameter       targetAlt,
                    posVec is -ship:body:position,
                    obtVelVec is ship:velocity:orbit,
                    c is ship:body,
                    kscUniversalTime is timestamp():seconds.

    local curOrbit is orbitFromVector(posVec, obtVelVec, c, kscUniversalTime).

    local TT is getTimeToAltitude(
        targetAlt, c, 
        curOrbit:trueanomaly, curOrbit:eccentricity,
        curOrbit:semimajoraxis, curOrbit:apoapsis,
        curOrbit:periapsis, curOrbit:period
        ).

    local nextOrbit is orbitFromElements(
        curOrbit:epoch-TT-(timestamp():seconds-kscUniversalTime),
        curOrbit:inclination,
        curOrbit:eccentricity,
        curOrbit:semimajoraxis,
        curOrbit:longitudeofascendingnode,
        curOrbit:argumentofperiapsis,
        curOrbit:meananomalyatepoch,
        c
        ).
    
    return lexicon(
        "Position", nextOrbit:position,
        "Orbital Velocity Vector", nextOrbit:velocity:orbit,
        "Surface Velocity Vector", nextOrbit:velocity:surface,
        "Height MSL", ((nextOrbit:position-c:position):mag - c:radius),
        "Time", TT,
        "Next Orbit", nextOrbit
    ).
}

