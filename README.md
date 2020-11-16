![Title Image](https://github.com/Ren0k/Project-Atmospheric-Drag/blob/main/Images/Header.jpg)    

# A model to determine atmospheric drag with kOS, for stock KSP

# Introduction

This tool allows you to determine accurate atmospheric drag for stock KSP vessels, under a constant orientation.  
It encompasses a complete re-creation of the actual KSP drag and lift calculations, and takes into account different configurations of your vessel.  
The idea is to create a profile for your vessel only once with which you can calculate drag; you do this for a specific vessel/vesselState and you only have to it it again if the vessel changes significantly.  
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
A tool is used to guesstimate the values, but it is not too accurate.  
- Cargobay part exclusion can not be determined, you will have to specify which parts are excluded if you have a cargobay fitted.  
- Simple non-stock/modded parts will work; more complex non-stock parts that have different variants and modules might not work  
- You need accurate mach number values; this is determined by the accuracy of the static ambient temperature (SAT) and density, which is not provided by kOS. I have added a tool that allows you to obtain accurate SAT's for kerbin, but for other planets you will have to use an estimated value.

![Demo Image](https://github.com/Ren0k/Project-Atmospheric-Drag/blob/main/Images/Demo%20Image.jpg)    
**Image of the dragGUI interface**  

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

There are 2 main scripts to use, found in the dragProfile root folder.  
'createProfile.ks' and 'useProfile.ks'.  
You start by running the 'createProfile.ks' script.  
To do this simply create a script in the root \Script folder and enter runpath("dragProfile/createProfile.ks").  
This will open the user interface.  If you do not want to use the user interface further reading is required in the more advanced sections.  
  
The menu that loads will have multiple options. Whatever you select, the script starts by checking if the partdatabase.cfg file has been analyzed yet, and if not it will analyze the file and put relevant information in a partdatabase.json file, so you do not have to do this scan everytime.  
I will give a quick overview of the options you have:  

## createProfile

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

If you select 'Create Profile' you will continue to the next menu where you can create a 'Drag Profile'.  

### Menu 3
- Mach Start  
At what mach number should the profile start. This indicates the lowest mach number at which you can use this profile.  
- Mach End  
At what mach number should the profile end. It indicates the highest mach number at which you can use this profile.  
Note that the highest value you will find in KSP is mach 25; higher mach numbers will have constant Cd/Cl values.  
- Delta-T  
The intervals for which you calculate the Cd value. The default selected value of 0.01 works well. Lowering this value will increase accuracy but also increase calculation time.  
I recommend using either 0.0001 / 0.001 / 0.01 / 0.1.  
- Review Part List  
Same as in Menu 2
- Review Parameters  
Same as in Menu 2  
- Create  
Starts creating this profile, calculating the Cd/Cl values for every mach interval until completed.  

Once you have selected 'Create', a loading menu opens that will show you the progress until completed.  
Once the profile has completed building, a new menu opens.  

### Menu 4
- Review Profile  
A huge list of the calculated values, for your review.  
- Save As  
Save the profile under the selected filename. You can name it anything you like, but the default is your vessel's name.  
It will be saved in the dragProfile\DATA\Profiles folder.  
- Finish  
This will end the createProfile script.  

## useProfile

At this stage you have created a 'Drag Profile' for your selected vessel and configuration.  
You might wonder what this actually is, and how to use it.  

### What is a drag profile?  
It turns out that the most important property that determines Drag Coefficients (CD) and Lift Coefficients (CL) is mach number.  
If you know what Cd/Cl value corresponds to what mach number, only a few additional steps are required for you to acquire the drag force on your vessel.  
A drag profile is a collection of calculated Cd values for different mach numbers, with a specified interval.  
In kOS language, it is a lexicon of lists.  Every list, contains 2 lists: One for dragcube Cd values, one for 'other' Cd values.  
The 2 seperate lists are required as the calculation applied to them is different. Drag cube drag calculation requires a reynolds number modifier, while 'other' cd values skip this modifier.  

### What do I need to use a drag profile?  
An example function is provided that you can use, and modify, to your liking.  
Run it with runpath("dragProfile/useProfile.ks").  
As mentioned earlier, the main limitation to using this is the accuracy of the mach number you provide. In addition, the accuracy of the provided SAT and Density used in Dynamic Pressure calculation is also a big factor.  
I have provided tools that allow you to quite accurately determine these values for Kerbin.  
Further information on this topic can be found [here](https://github.com/Ren0k/Kerbin-Temperature-Model).  
For other planets kOS will provide an estimated value, and will reduce the accuracy of the calculation.  

I recommend exploring the useProfile.ks script and investigate what data is used.  
This concludes a high-level overview, the next section will go in depth into how it all works.  


