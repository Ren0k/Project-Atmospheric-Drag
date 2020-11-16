![Title Image](https://github.com/Ren0k/Project-Atmospheric-Drag/blob/main/Images/Header.jpg)    

# A model to determine atmospheric drag with kOS, for stock KSP

# Introduction

This tool allows you to determine accurate atmospheric drag for stock KSP vessels, under a constant orientation.  
It encompasses a complete re-creation of the actual KSP drag and lift calculations, and takes into account different configurations of your vessel.  
The idea is to create a profile for your vessel only once with which you can calculate drag; you do this for a specific vessel/vesselState and you only have to do it it again if the vessel changes significantly.  
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

# Section 1

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
- dragGUI    
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

# Section 2

# KSP Drag

## Introduction
Welcome to the fascinating world of KSP aerodynamics.  
You might have worked with the drag equation before, illustrated in the image below.

![Drag Equation](https://www.grc.nasa.gov/www/k-12/airplane/Images/drageq.gif)  

This is on a basic level how it works in KSP.  
You take dynamic pressure ((Rho x V^2)/2) and multiply it with a (Cd x A) value.  

Getting dynamic pressure is possibly with the method provided by kOS (ship:q), or can be calculated independently.  
To calculate dynamic pressure, you need an accurate value of density, which is not provided by kOS but can be determined. I have provided a tool that allows you to get accurate density values for Kerbin's atmosphere, for other atmospheres you can get an estimated value.  

The main 'gotcha' is the value of (Cd x A) or CdA, which is very dynamic.  

Before we dive in, here a full overview of the 'types' of drag, modifiers and influencing factors:  

#### **Drag Cubes**  
- 6 Dragcube Surfaces per Body Part  
- Dragcube Tip Modifier  
- Dragcube Surface Modifier  
- Dragcube Tail Modifier  
- Mach Based Drag Modifier
- Initial Drag Coefficient Correction
- Mach Based Drag Coefficient Modifier
- Reynolds Number Based Drag Modifier  
- Occupied Node CdA Corrections
- Part Variant based Drag Cubes
- 'Part-State' based Drag Cubes
- Procedural Drag Cube Generation (Fairings)  
- Part Exclusion (Cargobays/fairings etc)
- Part Specific Drag Modifiers  
- Global Dragcube Multiplier
- Global Overall Drag Multiplier  
#### **Lifting Surfaces**  
- AoA Based Lift Coefficient
- Mach Based Lift Coefficient Modifier
- AoA Based Drag Coefficient
- Mach Based Drag Coefficient Modifier
- Deflection Lift Coefficient (Main Area Value)
- Induced Drag (Anti-Velocity Vector Horizontal Lift Component)
- Global Lift Multiplier
- Global Lift Drag Multiplier  
#### **Body/Capsule Lift**  
- AoA Based Body Lift Coefficient 
- Mach Based Body Lift Coefficient Modifier
- Deflection Lift Coefficient (Main Area Value)
- Induced Drag (Anti-Velocity Vector Horizontal Lift Component)
- Global Lift Multiplier  
#### **Speedbrake**  
- AoA Based Drag Coefficient
- Mach Based Drag Coefficient Modifier
- Deflection Lift Coefficient (Main Area Value)
- Global Lift Drag Multiplier

With this out of the way, you might realize that a little bit more is involved than filling in the drag equation.  
We will break it down section by section, calculation by calculation, starting with Drag Cubes.

## Drag Cubes

### What are drag cubes?  
Every part in KSP has 6 surfaces: A front surface (YP), a back surface (YN), and 4 side surfaces (XP/XN/ZP/ZN).
A drag cube is a 3 Dimensional Cube that sits on top of every of those surfaces, with 3 values:  
- Area
- Drag Coefficient
- Depth  

Depth is not used for our purposes.  
This leaves 12 values for every part that is involved in drag.  

Drag Cubes for parts are saved in the PartDatabase.cfg file in the root KSP folder.  
If you look through this file, you can find all drag cubes for all parts.  
You might find that some parts have multiple cubes. This is due different part variants or different part states.  

### How is drag applied to drag cubes?

When it comes to drag cubes, there are 3 'types' of drag:  
- Tip Drag
- Surface (skin friction) Drag
- Tail Drag  

Every surface can have either 1 or 2 different types of drag applied to it, either a combination of Tip/Surface or Tail/Surface.  

In my opinion, the best way to further explain the concept is by using actual situations whilst in KSP.  
Lets consider the following situation.  

## Drag Cube Example 1

![Example 1](https://github.com/Ren0k/Project-Atmospheric-Drag/blob/main/Images/Example%201.jpg)  

See the above image.  
A **C7 Aerospace Division - Mk1 Liquid Fuel Fuselage** is falling directly down to Kerbin in a mostly prograde orientation. How do we determine the drag on this part?  

#### Getting Drag Cube Values
Lets start by getting the drag cube values in the PartDatabase.cfg file, this is what I found:  

> cube = Default, 2.432,0.7714,0.7222, 2.432,0.7714,0.7222, 1.213,0.9716,0.1341, 1.213,0.9716,0.1341, 2.432,0.7688,0.7222, 2.432,0.7688,0.7222, 0,0,0, 1.25,1.938,1.25  

There are a total of 8 sections of 3 values, seperated by a comma. The first 6 apply to us and are in order XP/XN/YP/YN/ZP/ZN.  
We use the first 2 values per section which are A and 'initial Cd'.  
This gives us the following:  
XP = A: 2.432 Cd: 0.7714  
XN = A: 2.432 Cd: 0.7714  
YP = A: 1.213 Cd: 0.9716  
YN = A: 1.213 Cd: 0.9716  
ZP = A: 2.432 Cd: 0.7688  
ZN = A: 2.432 Cd: 0.7688  
Note how the surface sides (XP/XN/ZP/ZN) are pretty much the same as the shape of the tank is a cylinder.  

#### Splines
The Cd values we obtained are not really Cd Values, you might have noticed that they are very high.  
Consider them 'Intial Cd Values', and before they are applied to the actual part an initial transformation to the Cd values is done to make them more 'realistic'.  
The process of those transformations is done a lot. KSP (Unity) uses float curves in the form of cubic hermite splines, to get values from complex curves.  
In the physics.cfg file in the root KSP folder, about halfway down, you can find a collection of Key Value pairs. Those Key Value pairs determine the shape of the curves.  
Between every key value, a spline (curve) is created. To read values between key value pairs, a [Hermite Interpolator](https://en.wikibooks.org/wiki/Cg_Programming/Unity/Hermite_Curves) is used.  
A hermite interpolator function is used in the script. We will further explore this later. For now lets apply the first transformation to the values above.  

#### 1) Initial Cd Transformation
We will transform every Cd value above, according to these splines found in the physics.cfg file:  

>DRAG_CD // The final Cd of a given facing is the drag cube Cd evalauted on this curve  
>{  
>	key = 0.05 0.0025 0.15 0.15  
>	key = 0.4 0.15 0.3963967 0.3963967  
>	key = 0.7 0.35 0.9066986 0.9066986  
>	key = 0.75 0.45 3.213604 3.213604  
>	key = 0.8 0.66 3.49833 3.49833  
>	key = 0.85 0.8 2.212924 2.212924  
>	key = 0.9 0.89 1.1 1.1  
>	key = 1 1 1 1  
>}  
  
Example: For the XP Value (Cd = 0.7714), this falls between 0.75 and 0.8, and a spline interpolation is done between the 2 key value pairs.  

With the included function, we can quickly determine the new 'realistic' Cd values:  
XP = A: 2.432 Cd: 0.5366  
XN = A: 2.432 Cd: 0.5366   
YP = A: 1.213 Cd: 0.9702    
YN = A: 1.213 Cd: 0.9702    
ZP = A: 2.432 Cd: 0.5248    
ZN = A: 2.432 Cd: 0.5248    

#### 2) Mach Cd Transformation  
Now a second transformation is done, based on the current mach number.  
The order of which you apply the transformations is important. This transformation has to be done at this particular moment.  
These are the relevant key value pairs, again from the physics.cfg file:  

>DRAG_CD_POWER // The final Cd of a given facing is then raised to this power, indexed by mach number  
>{  
>	key = 0 1 0 0.00715953  
>	key = 0.85 1.25 0.7780356 0.7780356  
>	key = 1.1 2.5 0.2492796 0.2492796  
>	key = 5 3 0 0  
>}  

Note that the Cd is raised to the power of the interpolated value.  
The mach number in our example is 0.552. This return a value of 1.082.
So for every Cd we apply the transformation of Cd^1.082.  
XP = A: 2.432 Cd: 0.5098  
XN = A: 2.432 Cd: 0.5098   
YP = A: 1.213 Cd: 0.9677    
YN = A: 1.213 Cd: 0.9677    
ZP = A: 2.432 Cd: 0.4977    
ZN = A: 2.432 Cd: 0.4977    

#### 3) Surface Transformation
Now we are going to look at every of the 6 surfaces, and determine what 'direction' of drag they experience. 

Lets consider the front section of the falling fuel tank.  
It is falling directly down, facing the relative airflow. In our example it only experiences 'Tip Drag'. Would it have an angle to the relative airflow, it could also experience some 'Surface Drag'. More on that in the next example.  

Now the tail or back section of the fuel tank. It is directly facing away from the relative airflow, hence it only experiences Tail Drag.  

The 4 surfaces section only experience Surface Drag.  

There are different curves/modifiers for tip/surface/tail drag, based on mach number. They can be found in the top of they key value sections of the physics file.  
Lets work out the tip modifier first:

##### Tip Modifier
From our spline curve we get a value of 1.0488.  
This value is multiplied by the YP (Currently facing the airflow) Cd, returning:  
YP = A: 1.213 Cd: 1.014  

##### Surface/Skin Modifier
From our spline curve we get a value of 0.02.  
This value is multiplied by the XP/XN/ZP/ZN Cd, returning:   
XP = A: 2.432 Cd: 0.0101  
XN = A: 2.432 Cd: 0.0101  
ZP = A: 2.432 Cd: 0.0099  
ZN = A: 2.432 Cd: 0.0099   

##### Tail Modifier  
From our spline curve we get a value of 1, so the YN Cs stays the same. 

##### Results
XP = A: 2.432 Cd: 0.0101  
XN = A: 2.432 Cd: 0.0101  
YP = A: 1.213 Cd: 1.014  
YN = A: 1.213 Cd: 0.9677  
ZP = A: 2.432 Cd: 0.0099  
ZN = A: 2.432 Cd: 0.0099   

#### 4) Overall Mach Transformation
The next transformation is applied to all surfaces, and depends on mach number.  
Its found in the physics file as:  
> DRAG_MULTIPLIER // Overall multiplier to drag based on mach  

We repeated the process, get the interpolated value, and apply it to all 6 Cd Values.  
The interpolated value is 0.5, applying to all drag cubes:  
XP = A: 2.432 Cd: 0.00505  
XN = A: 2.432 Cd: 0.00505  
YP = A: 1.213 Cd: 0.507  
YN = A: 1.213 Cd: 0.48385   
ZP = A: 2.432 Cd: 0.00495  
ZN = A: 2.432 Cd: 0.00495   

#### 5) 
