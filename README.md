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
- Fairings work by procedural drag cube generation. The process KSP uses to do this can not be re-created, and if you use fairings manual values have to be entered.  
- Cargobay part exclusion can not be determined, you will have to specify which parts are excluded if you have a cargobay fitted.  
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

## Usage

There are 2 main scripts to use, found in the dragProfile root folder. 'createProfile.ks' and 'useProfile.ks'.  
You start by running the 'createProfile.ks' script. To do this simply create a script in the root \Script folder and enter runpath("dragProfile/createProfile.ks").
This will open the user interface.  If you do not want to use the user interface further reading is required in the more advanced sections.  
  
The menu that loads will have multiple options. Whatever you select, the script starts by checking if the partdatabase.cfg file has been analyzed yet, and if not it will analyze the file and put relevant information in a partdatabase.json file, so you do not have to do this scan everytime.  
I will give a quick overview of the options you have:  

### Menu 1
- Configure  
This allows you to manually specify your vessel's configuration of parts and flight orientation.  
Amongst the options here is 'special menu', which will at a later stage allow you to manually edit every single part of the analyzed vessel.  
- Load Partlist  
You can save an analyzed partlist for re-use at a later section, and load it here so you can skip the part analysis 
- Rescan Partdatabase  
If the partdatabase.cfg file has changed if you for example have added a few custom parts, put a new copy of your partdatabase file in the correct folder and rescan it
- Analyze Now  
This will let you skip the manual configuration section, and the script will 'Scan' your vessel as it currently is and continue as if you will fly retrograde
- IPU Selector  
Depending on the size of your vessel, it might take a long time to analyze your vessel and create a profile. To lower the time required you can increase the IPU value.  
  
When you are done configuring, or if you have selected 'Analyze Now', the analysis tool begins.  
It will scan every single part, both in game and from the .craft file, obtain relevant information, and put it in one vesselPartList file.  
You will be shown a loading screen showing you the progress.  
Once this is completed, a new window with multiple options is shown. A quick overview:  

### Menu 2
- Save Part List  
You can save the analyzed part list here and re-use it. 
Comes in handy if your vessel is complex and you had to manually input drag cube values; saves you from repeating this
- Review Part List  
Analyze every single analyzed part, used to verify correct drag cube calculations  
- Review Parameters
Shows you what parameters/configuration/orientation you have selected for this
- Realtime Drag
A dragGUI, similar to the KSP aeroGUI menu, but with more in depth information about vessel drag. Is computationally quite heavy and lacks a little bit behind the actual calculated drag values by KSP.  
- Create Profile
Continues to the next menu where you can create a drag profile  



