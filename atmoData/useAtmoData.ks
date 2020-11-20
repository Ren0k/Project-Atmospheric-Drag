//////////////////////////////////////////
// EXAMPLE                              //
// By Ren0k                             //
//////////////////////////////////////////
@lazyGlobal off.


///// SETUP /////
runpath("atmoData/getAtmoData.ks").         // Run the getAtmoData script
local curBody is ship:body.                 // Or any body with an atmosphere you like

///// PRECISE TEMPERATURE /////
// Easy method to get your Static Ambient Temperature (SAT)
// Not computationally light (but still fast), the faster way is described below
local getSAT is getAtmosphericData(curBody)["getSAT"](False).
local SAT is getSAT().
print("SAT: "+SAT).

///// QUICK TEMPERATURE /////
// Fastest method for getting your SAT
// It reduces the 'update rate' of latitude dependant curves by a set amount, without any noticable precision reduction
// The bool determines the method used

local updateInterval is 10.         // The update rate, every 10 calculations now
set getSAT to getAtmosphericData(curBody)["getSAT"](True).
set SAT to getSAT(ship:altitude, ship:geoposition, 0, updateInterval).
print("SAT: "+SAT).

///// MORE DATA /////
// This method returns not just the temperature but also:
// Pressure, density, eas, mach number, speed of sounds, dynamic pressure, oat
// The faster method for getting temperature is also available, called with the bool

set updateInterval to 100.          // The update rate, every 100 calculations now
local getDATA is getAtmosphericData(curBody)["getDATA"](True).
local data is getData(ship:velocity:surface:mag, ship:altitude, ship:geoposition, 0, updateInterval).
print("DATA: "+data).