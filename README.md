# A model to determine atmospheric drag with kOS, for stock KSP

# Introduction

This tool allows you to determine accurate atmospheric drag for stock KSP vessels, under a constant orientation.  
The tool encompasses a complete re-creation of the actual KSP drag and lift calculations, and takes into account different configurations of your vessel.  
More specifically, with this tool you will be able to:  
- Investigate and analyze your vessel's drag under different situations and configurations
- Manually specify the orientation of your flight, whether prograde or retrograde, and specific AoA's
- Specify part configurations i.e. gear extension, airbrake deployment, parachute state etc
- Specify only certain sections or stages of your vessel
- Create a 'drag profile' that can be used and re-used at later moments for rapid drag determinations

Due to the complexity of the method, a simple user interface is provided that will guide you quickly through the process.  
Of course you can skip the user interface, and just use the script as part of your script. For that purpose, I recommended reading through the relevant section.  
  
This manual is split up in sections.  
The purpose of the 1st main section is to quickly get you started, without providing in depth details of the underlying mechanics.  
The 2nd main section will dive deeply into the mechanics of KSP, how drag is determined from start to finish, and goes into the workings of the different scripts.  

## Why was this tool created?

- It paves the way for accurate impact position calculations on planets with an atmosphere.
- It helps you analyze and optimize your vessel in atmospheric flight by providing in depth detail of different types of drag
- By using the drag profile tool provided you can very quickly and accurately determine drag, faster than any other methods

## Limitations

There are of course limitations to what this tool can do. 
Drag will be determined for a fixed vessel orientation and configuration, so changing any of these in flight will result in inaccurate readings.  
While in theory it is possible to allow for changing orientations and configurations, the amount of calculations required to do this is too great for kOS.  
Hence I have chosen to restrict the tool to this setup.  
Other limitations and bugs:  
- The information required to do these calculations can not be obtained with kOS alone. A copy of your 'partdatabase.cfg' and your vessel's .craft file have to be put in the correct folder for use by the tool
- Airbrake Deployment angle is bugged in KSP; a bug report is filed. The bug is actually coded in this script, and if it is fixed in KSP this will have to be adjusted here.
- Engine Plates are currently bugged in KSP; a bug report for this is filed. This is NOT coded into the script, engine plates do not apply their drag cubes. You will have to manually enter drag cube values
- Simple non-stock/modded parts will work; more complex non-stock parts that have different variants and modules might not work  
- You need accurate mach number values; this is determined by the accuracy of the static ambient temperature (SAT) and density, which is not provided by kOS. I have added a tool that allows you to obtain accurate SAT's for kerbin, but for other planets you will have to use an estimated value.

# Quickstart Guide

A quick overview of things you need to know:  
- 2 files are required for this to work; your partdatabase.cfg file, and the .craft file of the vessel you use
- The calculations only work for a custom orientation and configuration, but you can make multiple profiles for different situations
- A custom dragGUI is provided with the user interface, where you can analyze and review your vessel's drag
- Multiple drag profiles can be created that can be used later, also for different vessels
- Be aware that complex modded parts might not work correctly

## Install

- Put the dragProfile folder in your KSP\Ships\Script folder
- Create a copy of your partdatabase.cfg file found in the KSP root folder, and place it in KSP\Ships\Script\dragProfile\DATA\PartDatabase
- Create a copy of your ship's .craft file (found in KSP\saves\savename\ships) in KSP\Ships\Script\dragProfile\DATA\Vessels.  
Note: do this at the last possible moment, as any time you save your vessel in the VAB, new part ID's are created and a new copy has to be put in the \Vessels folder.

## Using






