![Title Image](https://github.com/Ren0k/Project-Atmospheric-Drag/blob/main/Images/Header.jpg)    

# A model to determine atmospheric drag with kOS, for stock KSP

# Introduction 

This tool allows you to determine accurate atmospheric drag for stock KSP vessels, for a configurable fixed configuration.  
It encompasses a complete re-creation of the actual KSP drag and lift calculations, and takes into account different configurations of your vessel.  
The idea is to create a 'drag profile' for your vessel only once with which you can calculate drag at any later time; you do this for a specific vessel/vesselState and you only have to do it it again if the vessel changes significantly.  
More specifically, with this tool you will be able to:  
- Investigate and analyze your vessel's drag under different situations and configurations  
- Manually specify the orientation of your flight, whether prograde or retrograde, and specific AoA's  
- Specify part configurations i.e. gear extension, airbrake deployment, parachute state etc  
- Specify only certain sections or stages of your vessel  
- Create a 'drag profile' that can be used and re-used at later moments for rapid drag determinations  

Due to the complexity of the method, a simple user interface is provided that will guide you quickly through the process.  
Of course you can skip the user interface, and just use the script as part of your script. For that purpose, I recommend reading through the relevant section.  
  
This manual is split up in 3 sections.  
The 1st section will get you started, without providing in depth details of the underlying mechanics.  
The 2nd section will dive deeply into the mechanics of KSP, how drag is determined from start to finish.  
The 3rd section goes into the different scripts and files used.  

# Table of Contents  
## 1. [Section 1 - Get Started](#Section1)  
### a. [Limitations](#limitations)  
### b. [Quick Start Guide](#quickstart)  
### c. [How to install?](#install)  
### d. [How to start?](#usage)  
### e. [User Interface](#menus)  
### f. [What is a drag profile?](#whatdragprofile)  
### g. [How to use a drag profile?](#useprofile)   
## 2. [Section 2 - KSP Aerodynamics](#Section2)  
### 1. [KSP Drag](#kspdrag)  
#### a. [Drag Overview](#dragoverview)  
#### b. [Drag Cubes](#dragcubes)  
#### c. [Example 1](#dcexample1)  
#### d. [Example 2](#dcexample2)  
### 2. [Lifting Surfaces](#liftdrag)  
#### a. [Wings](#wings)  
#### b. [Wing Lift](#winglift)  
#### c. [Profile Drag](#wingprofiledrag)  
#### d. [Induced Drag](#winginduceddrag)  
### 3. [Body Lift](#bodylift)  
### 4. [Airbrakes](#airbrakes)  
### 5. [Heatshields](#capsule)   
### 6. [Special Parts](#specialparts)   
## 3. [Section 3 - Script Structure](#Section3)  
### 1. [Cubic Hermite Splines](#hermite)  
### 2. [Additional Part Database](#extradatabase)  
### 3. [Bypass the GUI](#nogui)  
### 4. [How to read a drag profile?](#readprofile)  
### 5. [Useful Links](#links)  

# Section 1 <a name="Section1"></a>

## Why was this tool created?

- It paves the way for accurate impact position calculations on planets with an atmosphere.
- It helps you analyze and optimize your vessel in atmospheric flight by providing in depth detail of different types of drag
- By using the drag profile tool provided you can very quickly and accurately determine drag, faster than any other methods

## Limitations <a name="limitations"></a>

There are of course limitations to what this tool can do.  
Drag will be determined for a fixed vessel orientation and configuration, so changing any of these in flight will result in inaccurate readings.    
While in theory it is possible to allow for changing orientations and configurations, the amount of calculations required to do this is too great for kOS.  
Hence I have chosen to restrict the tool to this setup.  

Other limitations and bugs:  
- The information required to do these calculations can not be obtained with kOS alone. A copy of your 'partdatabase.cfg' and your vessel's .craft file have to be put in the correct folder for use by the tool
- **Airbrake** Deployment angle is bugged in KSP; a bug report is filed. The bug is actually coded in this script, and if it is fixed in KSP this will have to be adjusted here. You should not have to worry about this, just be aware it exists.  
- **Engine Plates** are currently bugged in KSP; a bug report for this is filed. This is NOT coded into the script, engine plates do not apply their drag cubes. You will have to manually enter drag cube values.  
- **Fairings** work by procedural drag cube generation. The process KSP uses to do this can not be re-created, and if you use fairings manual values have to be entered.  
A tool is used to guesstimate the values, but it is not too accurate.  
- **Cargobay** part exclusion can not be determined, you will have to specify which parts are excluded if you have a cargobay fitted.  
- Simple non-stock/modded parts will work; more complex non-stock parts that have different variants and modules might not work  
- You need accurate mach number values; this is determined by the accuracy of the static ambient temperature (SAT) and density, which is not provided by kOS. I have added a tool that allows you to obtain accurate SAT's for kerbin, but for other planets you will have to use an estimated value.

![Demo Image](https://github.com/Ren0k/Project-Atmospheric-Drag/blob/main/Images/Demo%20Image.jpg)    
**Image of the dragGUI interface**  

# Quickstart Guide <a name="quickstart"></a>

A quick overview of things you need to know:  
- 2 files are required for this to work; your partdatabase.cfg file, and the .craft file of the vessel you use
- The calculations only work for a custom orientation and configuration, but you can make multiple profiles for different situations
- A custom dragGUI is provided with the user interface, where you can analyze and review your vessel's drag
- Multiple drag profiles can be created that can be used later, also for different vessels
- Be aware that complex modded parts might not work correctly

## Install  <a name="install"></a>

- Put the dragProfile folder in your KSP\Ships\Script folder
- Create a copy of your partdatabase.cfg file found in the KSP root folder, and place it in KSP\Ships\Script\dragProfile\DATA\PartDatabase
- Create a copy of your ship's .craft file (found in KSP\saves\savename\ships) in KSP\Ships\Script\dragProfile\DATA\Vessels.  
Note: do this at the last possible moment, as any time you save your vessel in the VAB, new part ID's are created and a new copy has to be put in the \Vessels folder.

## Usage <a name="usage"></a>

There are 2 main scripts to use, found in the dragProfile root folder.  
'createProfile.ks' and 'useProfile.ks'.  
You start by running the 'createProfile.ks' script.  
To do this simply create a script in the root \Script folder and enter runpath("dragProfile/createProfile.ks").  

The 1st thing the script does is check if a partdatabase.json exists, and if not it will create one from your partdatabase.cfg file.  
If you interrupt this scanning process, the created json file might be incomplete and will result in errors later.  
If you do get errors, you can rescan the partdatabase in the main menu.     
Once complete, it will open the user interface.  
  
The menu that loads will have multiple options. 
I will give a quick overview of the options you have:  

## createProfile <a name="menus"></a>

### Menu 1 - Configuration  
- Configure  
This allows you to manually specify your vessel's configuration of parts and flight orientation.  
Amongst the options here is 'special menu', which will at a later stage allow you to manually edit every single part of the analyzed vessel.  
- Load Partlist  
You can save an analyzed partlist for re-use at a later section, and load it here so you can skip the part analysis 
- Scan Partdatabase  
If the partdatabase.cfg file has changed if you for example have added a few custom parts, put a new copy of your partdatabase file in the correct folder and rescan it
- Analyze Now  
This will let you skip the manual configuration section, and the script will 'Scan' your vessel as it currently is and continue as if you will fly retrograde
- IPU Selector  
Depending on the size of your vessel, it might take a long time to analyze your vessel and create a profile. To lower the time required you can increase the IPU value.  
  
When you are done configuring, or if you have selected 'Analyze Now', the analysis tool begins.  
It will scan every single part, both in game and from the .craft file, obtain relevant information, and put it in one vesselPartList file.  
You will be shown a loading screen showing you the progress.  
Once this is completed, a new window with multiple options is shown. A quick overview:  

### Menu 2 - Review  
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

### Menu 3 - Profile Creation  
**IMPORTANT**  
Depending on the values you select, a profile might become an excessively large file with file sizes up to 20-30 Mb.  
If you create a profile for a very wide range of mach numbers, be gentle on the dT value you select.  
Also be sensible for the range you select. Are you really going beyond mach 10 in atmospheric flight?  

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

### Menu 4 - Profile Review  
- Review Profile  
A huge list of the calculated values, for your review.  
Be warned that kOS does not like reading large files.  
- Save As  
Save the profile under the selected filename. You can name it anything you like, but the default is your vessel's name.  
It will be saved in the dragProfile\DATA\Profiles folder.  
- Finish  
This will end the createProfile script.  

![Demo Image 2](https://github.com/Ren0k/Project-Atmospheric-Drag/blob/main/Images/Demo%20Image%202.jpg)    
**Image of the drag profile results**  

## useProfile  

At this stage you have created a 'Drag Profile' for your selected vessel and configuration.  
You might wonder what this actually is, and how to use it.  

### What is a drag profile?  <a name="whatdragprofile"></a>
It turns out that the most important property that determines Drag Coefficients (CD) and Lift Coefficients (CL) is mach number.  
If you know what Cd/Cl value corresponds to what mach number, only a few additional steps are required for you to acquire the drag force on your vessel.  
A drag profile is a collection of calculated Cd values for different mach numbers, with a specified interval.  
In kOS language, it is a lexicon of lists.  Every list, contains 2 lists: One for dragcube Cd values, one for 'other' Cd values.  
The 2 seperate lists are required as the calculation applied to them is different. Drag cube drag calculation requires a reynolds number modifier, while 'other' cd values skip this modifier.  

### What do I need to use a drag profile?  <a name="useprofile"></a>
An example function is provided that you can use, and modify, to your liking.  
Run it with runpath("dragProfile/useProfile.ks").  
As mentioned earlier, the main limitation to using this is the accuracy of the mach number you provide. In addition, the accuracy of the provided SAT and Density used in Dynamic Pressure calculation is also a big factor.  
I have provided tools that allow you to quite accurately determine these values for Kerbin.  
Further information on this topic can be found [here](https://github.com/Ren0k/Kerbin-Temperature-Model).  
For other planets kOS will provide an estimated value, and will reduce the accuracy of the calculation.  

I recommend exploring the useProfile.ks script and investigate what data is used.  
Also I recommend reading this section [How to read a drag profile?](#readprofile).  
This concludes a high-level overview, the next section will go in depth into how it all works.  

# Section 2 <a name="Section2"></a>

# KSP Drag <a name="kspdrag"></a>

## Introduction
Welcome to the fascinating world of KSP aerodynamics.  
You might have worked with the drag equation before, illustrated in the image below.

![Drag Equation](https://www.grc.nasa.gov/www/k-12/airplane/Images/drageq.gif)  

This is on a basic level how it works in KSP.  
You take dynamic pressure ((Rho x V^2)/2) and multiply it with a (Cd x A) value.  

Getting dynamic pressure is possible with the method provided by kOS (ship:q), or can be calculated independently.  
To calculate dynamic pressure, you need an accurate value of density, which is not provided by kOS but can be determined. I have provided a tool that allows you to get accurate density values for Kerbin's atmosphere, for other atmospheres you can get an estimated value.  

The main 'gotcha' is the value of (Cd x A) or CdA, which is very dynamic.  

This is a full overview of the 'types' of drag, modifiers and influencing factors:  <a name="dragoverview"></a>

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
Lets go down the rabbit hole.  

# Drag Cubes <a name="dragcubes"></a>

### What are drag cubes?  
Every part in KSP has 6 surfaces: A front surface (YP), a back surface (YN), and 4 side surfaces (XP/XN/ZP/ZN).  
The side surfaces can be further divided into right (XP), left (XN), top (ZN), bottom (ZP).  
A drag cube is a 3 Dimensional Cube that sits on top of every of those surfaces, with 3 values:  
- Area
- Drag Coefficient
- Depth  

Depth is not used in these scripts.  
This leaves 12 values for every part that is involved in drag.  

Drag Cubes for parts are saved in the PartDatabase.cfg file in the root KSP folder.  
If you look through this file, you can find all drag cubes for all parts.  
You might find that some parts have multiple cubes. This is due different part variants or different part states.  
The script can figure out what drag cube corresponds to what state, and it should be applied automatically.  

**IMPORTANT NOTE**  
You might think, looking at the image, that the X+ (XP) and X- (XN) sides are reversed. This is not the case.  
KSP uses a [left-handed](https://ksp-kos.github.io/KOS/math/ref_frame.html#left-handed) coordinate system.  
However when you spawn a part in the SPH, it actually spawns with the ZP side on the bottom, the ZN side on the top, the XP side on the right and the XN side on the left.  
That is why I chose a different method to deal with this system.  
My way of correcting for this left-handed system is to 'reverse' the top and bottom sides, so the top side is called ZN and the bottom side is called ZP.  
Now the sides line up with the kOS vector system, where a part:topvector actually originates from the ZN side, and a part:starvector originates from the XP side.    
This was the best way to get the actual calculations to line up with in game drag vectors.  
To make sense of this is to see this image as it is upside down. 

![dragcube1](https://lh6.googleusercontent.com/wYG-GLOLnBKE3vilulRY9uhMRN3eosBdO8aCY_KvxkmdhSnmbStaiOgJgaH2ebMiC3rM6ilk4g_BSDtyn7AYACO3jeAqu5zEDtfx8NBJ4luhXiZ9X7QpiC79aaveVJ_oHFtFaQsY)  

### How is drag applied to drag cubes?

When it comes to drag cubes, there are 3 'types' of drag:  
- Tip Drag
- Surface (skin friction) Drag
- Tail Drag  

Every surface can have either 1 or 2 different types of drag applied to it, either a combination of Tip/Surface or Tail/Surface.  

In my opinion, the best way to further explain the concept is by using actual situations while in KSP.  
Lets consider the following situation.  

## Drag Cube Example 1 <a name="dcexample1"></a>

![Example 1](https://github.com/Ren0k/Project-Atmospheric-Drag/blob/main/Images/Example%201.jpg)  

See the above image.  
A **C7 Aerospace Division - Mk1 Liquid Fuel Fuselage** is falling directly down to Kerbin in a mostly prograde orientation. How do we determine the drag on this part?  

#### 1) Getting Drag Cube Values
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
The process of those transformations is done a lot. KSP (Unity) uses float curves in the form of cubic hermite splines, from which values are interpolated.  
In the physics.cfg file in the root KSP folder, about halfway down, you can find a collection of Key Value pairs. Those Key Value pairs determine the shape of the curves.  
Between every key value, a spline (curve) is created. To read values between key value pairs, a [Hermite Interpolator](#hermite) is used.  
A hermite interpolator function is used in the script. We will further explore this later. For now lets apply the first transformation to the values above.  

#### 2) Initial Cd Transformation
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

#### 3) Mach Cd Transformation  
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
The mach number in our example is 0.552. This returns a value of 1.082.
So for every Cd we apply the transformation of Cd^1.082.  
XP = A: 2.432 Cd: 0.5098  
XN = A: 2.432 Cd: 0.5098   
YP = A: 1.213 Cd: 0.9677    
YN = A: 1.213 Cd: 0.9677    
ZP = A: 2.432 Cd: 0.4977    
ZN = A: 2.432 Cd: 0.4977    

#### 4) Surface Transformation
Now we are going to look at each of the 6 surfaces, and determine what 'direction' of drag they experience. 

Lets consider the front section of the falling fuel tank.  
It is falling directly down, facing the relative airflow. In our example it only experiences 'Tip Drag'. Would it have an angle to the relative airflow, it could also experience some 'Surface Drag'. More on that in the next example.  

Now the tail or back section of the fuel tank. It is directly facing away from the relative airflow, hence it only experiences Tail Drag.  

The 4 side section only experience Surface Drag.  

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
From our spline curve we get a value of 1, so the YN Cd stays the same. 

##### Results
XP = A: 2.432 Cd: 0.0101  
XN = A: 2.432 Cd: 0.0101  
YP = A: 1.213 Cd: 1.014  
YN = A: 1.213 Cd: 0.9677  
ZP = A: 2.432 Cd: 0.0099  
ZN = A: 2.432 Cd: 0.0099   

#### 5) Overall Mach Transformation
The next transformation is applied to all surfaces, and depends on mach number.  
Its found in the physics file as:  
> DRAG_MULTIPLIER // Overall multiplier to drag based on mach  

We repeat the process, get the interpolated value, and apply it to all 6 Cd Values.  
The interpolated value is 0.5, applying to all drag cubes:  
XP = A: 2.432 Cd: 0.00505  
XN = A: 2.432 Cd: 0.00505  
YP = A: 1.213 Cd: 0.507  
YN = A: 1.213 Cd: 0.48385   
ZP = A: 2.432 Cd: 0.00495  
ZN = A: 2.432 Cd: 0.00495   

#### 6) Reynolds Number Transformation  
Or more a Pseudo-Reynolds as mentioned in the physics file. This is simply a value calculated by (density x velocity) with density as kg/m3 and velocity in m/s.  
The reynolds number in our example is 163.69 (0.8606 x 190.2).  

The relevant spline curves are found again in the physics file:  
> DRAG_PSEUDOREYNOLDS // Converts a pseudo-Reynolds number (density * velocity) into a multiplier to drag coefficient  

The interpolated value we get back is 0.8739, and after transforming:  
XP = A: 2.432 Cd: 0.0044   
XN = A: 2.432 Cd: 0.0044   
YP = A: 1.213 Cd: 0.4430   
YN = A: 1.213 Cd: 0.4228    
ZP = A: 2.432 Cd: 0.0043   
ZN = A: 2.432 Cd: 0.0043     

#### 7) Drag Equation  
We have finally come to the section where we can apply the drag equation.  
There are 2 more things to add, and those things are global drag modifiers.  
A global drag modifier exists for drag cube drag (0.1), and a global drag modifier exists for overall drag (8).  
Combining these gives an overall multiplier of 0.8 to the result of the drag equation.   

> Fd = ((Rho x V^2) / 2) * A * Cd * 0.8  with Rho = 0.8606 and V = 190.2.  

The final calculation now becomes:  

> ((2.432 * 0.0044) + (2.432 * 0.0044) + (1.213 * 0.4430) + (1.213 * 0.4430) + (2.432 * 0.0043) + (2.432 * 0.0043)) * ((Rho * V^2) / 2) * 0.8.  

It returns 13910 Newtons of Drag, an error of about 1.8% with the actual AeroGUI value.  

#### 8) Conclusion  
This is the method that KSP uses to calculate drag cube drag.  
You might have realized that since only the 2nd (Mach) transformation is done to The Power Of, that all transformations after that are commutative, as long as you keep a constant orientation. So instead of calculating values for every drag cube, we can already apply and add drag cubes together after the surface modifiers are applied.  
This significantly speeds up the process, and is used in this script.  

## Drag Cube Example 2 <a name="dcexample2"></a>

![Example 2](https://github.com/Ren0k/Project-Atmospheric-Drag/blob/main/Images/Example%202.jpg)  

The same fuel tank as in example 1 is falling down towards Kerbin. In addition, a smaller Mk0 fuel tank is added to the front section of the Mk1 fuel tank. Also, the craft has an AoA of about 20 degrees up to the relative airflow. 
There are some internal gyros that produce drag, we ignore them for now, and only look at drag values of the 2 fuel tanks.  
So how do we get the drag on the 2 fuel tanks?  

We follow the exact same steps as in example 1, but a few addition before starting with transformations.  

#### 1) Getting Drag Cube Values
Same as in example 1:

**Mk1 Liquid Fuel Fuselage**  
XP = A: 2.432 Cd: 0.7714  
XN = A: 2.432 Cd: 0.7714  
YP = A: 1.213 Cd: 0.9716  
YN = A: 1.213 Cd: 0.9716  
ZP = A: 2.432 Cd: 0.7688  
ZN = A: 2.432 Cd: 0.7688  

**Mk0 Liquid Fuel Fuselage**  
XP = A: 0.623 Cd: 0.7672  
XN = A: 0.623 Cd: 0.7672  
YP = A: 0.3033 Cd: 0.9425  
YN = A: 0.3033 Cd: 0.9425  
ZP = A: 0.623 Cd: 0.7672  
ZN = A: 0.623 Cd: 0.7672  

#### 2) Occupied Node Corrections

The Mk0 fuel tank is 'blocking' a section of the YP side of the Mk1 fuel tank. You can imagine that this will change the drag on both the Mk1 YP and Mk0 YN sides.  
This is what KSP does by applying corrections to occupied nodes. The only way to know if a node is occupied is by looking at the .Craft file, thats why the script needs it.  

##### So how do these corrections work?  
Whenever a node is occupied by another node, the exact same transformation is done every single time; irrespective of orientation. This means that once a node is occupied, you can do whatever you want with the part and the CdA values stay the same. This can be (mis)used to your advantage...  

Lets look at our example. The front (YP) side of the Mk1 tank is occupied by the back (YN) side of the Mk0 tank:  
Mk1 YP = A: 1.213 Cd: 0.9716  
Mk0 YN = A: 0.3033 Cd: 0.9425   

The area of the occupied node changes by subtracting the area of the attached node, lets do this.  
Mk1 YPA = Mk1 YPA - Mk0 YNA = 1.213-0.3033 = 0.9097  
Mk0 YNA = Mk0 YNA - Mk1 YPA = 0.3033-1.213 = 0 (Cannot be negative)  

The Cd values also change, they follow this transformation:  
> ((rootCdValue x rootAValue) - attachedAValue) / newRootAValue  

Mk1 YPCd = ((Mk1 YPCd * Mk1 YPA) - Mk0 YNA) / (Mk1 YPA - Mk0 YNA)  
Mk1 YPCd = ((0.9716  * 1.213) - 0.3033) / (1.213 - 0.3033)  
Mk1 YPCd = ((1.1785508) - 0.3033) / (0.9097)  
Mk1 YPCd = 0.9621312521  

Mk0 YNCd = ((Mk0 YNCd * Mk0 YNA) - Mk1 YPA) / (Mk0 YNA - Mk1 YPA)  
Mk0 YNCd = ((0.9425  * 0.3033) - 1.213) / (0.3033 - 1.213)  
Mk0 YNCd = (-0.92713975) / (**0**) (The new area value cannot be negative)  
Mk0 YNCd = 0  

##### Results  
Mk1 YP = A: 0.9097 Cd: 0.9621312521  
Mk0 YN = A: 0.0000 Cd: 0.0000    

#### 3) Initial Cd Transformation   
Exactly the same process as in the 1st example, these are the results:  

**Mk1 Liquid Fuel Fuselage**  
XP = A: 2.432 Cd: 0.536649606952518  
XN = A: 2.432 Cd: 0.536649606952518  
YP = A: 0.9097 Cd: 0.959806221740299  
YN = A: 1.213 Cd: 0.97021594304  
ZP = A: 2.432 Cd: 0.524834334231859  
ZN = A: 2.432 Cd: 0.524834334231859  

**Mk0 Liquid Fuel Fuselage**  
XP = A: 0.623 Cd: 0.517662391136973  
XN = A: 0.623 Cd: 0.517662391136973  
YP = A: 0.3033 Cd: 0.93778859375  
YN = A: 0.0000 Cd: 0.0000  
ZP = A: 0.623 Cd: 0.517662391136973  
ZN = A: 0.623 Cd: 0.517662391136973    
  
#### 4) Mach Cd Transformation  
The mach number in our example is 0.793.  
The interpolated value is 1.20820404078286.  
The results after applying the transformation, just like in example 1:  

**Mk1 Liquid Fuel Fuselage**  
XP = A: 2.432 Cd: 0.4714236338  
XN = A: 2.432 Cd: 0.4714236338  
YP = A: 0.9097 Cd: 0.9516431069  
YN = A: 1.213 Cd: 0.9641272461  
ZP = A: 2.432 Cd: 0.4589123414  
ZN = A: 2.432 Cd: 0.4589123414  

**Mk0 Liquid Fuel Fuselage**  
XP = A: 0.623 Cd: 0.4513463801  
XN = A: 0.623 Cd: 0.4513463801  
YP = A: 0.3033 Cd: 0.9253309388  
YN = A: 0.0000 Cd: 0.0000  
ZP = A: 0.623 Cd: 0.4513463801  
ZN = A: 0.623 Cd: 0.4513463801      

#### 5) Surface Transformation  
Unlike in example 1, our craft is falling down under an angle to the relative airflow. This complicates things.  

##### Front
Imagine the front section (YP) of the smaller Mk0 fuel tank.  
Of course it faces mostly in the relative airflow (Tip Direction), but since it is angled it will also experience side/skin drag.  
Essentially what happens is that the YP dragcube is split up in 2 sections. The Tip section, and the Side section.  
Per section, the Cd value does not change, but the A value does.  
So how big are those sections?  

The tip section is Cos(AoA) * A = 0.9376343655 * 0.3033 = 0.2843845031  
The side section is Sin(AoA) * A = 0.3476230668 * 0.3033 = 0.1054340762  
Result:  
YPtip = A: 0.2843845031 Cd: 0.9253309388  
YPside = A: 0.1054340762 Cd: 0.9253309388  

Instead of this method, the script will calculate this with the Vector Dot Product of the part:facing:forevector with the ship:facing:forevector.  

##### Side  

So far we have called the XP/XN/YP/YN side sections, but in reality they are Right, Left, Bottom, Top Sections.  
It is now important to consider them as such, since orientation will not have the same effect on each side.  
Lets think about the top section (ZN). From a port side perspective, since the AoA is about 20 degrees up, the top section is tilted clockwise.  
The top section is already facing directly up from the vessels perspective, so now it is tilting backwards.  
If it is tilting backwards, that means that the ZN side now, in addition to side drag, also experiences tail drag.  
Same method as before:  

The side section is Cos(AoA) * A = 0.9376343655 * 0.623 = 0.5841462097  
The tail section is Sin(AoA) * A = 0.3476230668 * 0.623 = 0.2165691706  
Result:  
ZNside = A: 0.5841462097 Cd: 0.4513463801  
ZNtail = A: 0.2165691706 Cd: 0.4513463801  

Now lets think about the right (XP) and left (XN) sides. Their orientation in the airstream did not change, they only rotated CW/CCW.  
Their values do not change and they stay the XP/XN values they were, as they do not experience any tip/tail drag.  

##### Tail  
Same as above; in our situation the YN sections are tilted so that they also experience Side drag.  

##### Results  
After applying all of the above, these are the results:  

**Mk1 Liquid Fuel Fuselage**  
XP = A: 2.432 Cd: 0.4714236338  
XN = A: 2.432 Cd: 0.4714236338  
YPtip = A: 0.8529659823 Cd: 0.9516431069  
YPside = A: 0.3162327039 Cd: 0.9516431069  
YNside = A: 0.42166678 Cd: 0.9641272461  
YNtail = A: 1.137350485 Cd: 0.9641272461  
ZNside = A: 2.280326777 Cd: 0.4589123414  
ZNtail = A: 0.8454192985 Cd: 0.4589123414  
ZPtip = A: 0.8454192985 Cd: 0.4589123414  
ZPside = A: 2.280326777 Cd: 0.4589123414  

**Mk0 Liquid Fuel Fuselage**  
XP = A: 0.623 Cd: 0.4513463801  
XN = A: 0.623 Cd: 0.4513463801  
YPtip = A: 0.2843845031 Cd: 0.9253309388  
YPside = A: 0.1054340762 Cd: 0.9253309388  
YN = A: 0.0000 Cd: 0.0000  
ZNside = A: 0.5841462097 Cd: 0.4513463801  
ZNtail = A: 0.2165691706 Cd: 0.4513463801  
ZPtip = A: 0.2165691706 Cd: 0.4513463801  
ZPside = A: 0.5841462097 Cd: 0.4513463801  

Now we will apply the tip/side/tail modifiers to each corresponding Cd value.  
Tip Modifier: 1.15301958754785  
Side Modifier: 0.02  
Tail Modifier: 1  

##### Results  
**Mk1 Liquid Fuel Fuselage**  
XP = A: 2.432 Cd: 0.009428472676  
XN = A: 2.432 Cd: 0.009428472676  
YPtip = A: 0.8529659823 Cd: 1.097263143  
YPside = A: 0.3162327039 Cd: 0.01903286214  
YNside = A: 0.42166678 Cd: 0.01928254492  
YNtail = A: 1.137350485 Cd: 0.9641272461  
ZNside = A: 2.280326777 Cd: 0.009178246828  
ZNtail = A: 0.8454192985 Cd: 0.4589123414  
ZPtip = A: 0.8454192985 Cd: 0.5291349186  
ZPside = A: 2.280326777 Cd: 0.009178246828  

**Mk0 Liquid Fuel Fuselage**  
XP = A: 0.623 Cd: 0.009026927602  
XN = A: 0.623 Cd: 0.009026927602  
YPtip = A: 0.2843845031 Cd: 0.9253309388  
YPside = A: 0.1054340762 Cd: 0.01850661878  
YN = A: 0.0000 Cd: 0.0000  
ZNside = A: 0.5841462097 Cd: 0.009026927602  
ZNtail = A: 0.2165691706 Cd: 0.4513463801  
ZPtip = A: 0.2165691706 Cd: 0.520411217  
ZPside = A: 0.5841462097 Cd: 0.009026927602  

#### 6) Overall Mach Transformation  
Before moving on, lets try something different.  
Instead of doing calculations now for every surface, we can make this process more efficient.  
Every transformation from now on is the same and applied to every dragcube.  
The order of this, is no longer of influence.  
We can add all (Cd * A) values together, and get only 1 value back to which we apply the coming transformations.  
Lets do this now:  

**Mk1 Liquid Fuel Fuselage**  
(2.432 * 0.009428472676) + (2.432 * 0.009428472676) + (0.8529659823 * 1.097263143) + (0.3162327039 * 0.01903286214) + (0.42166678 * 0.01928254492) + (1.137350485 * 0.9641272461) + (2.280326777 * 0.009178246828) + (0.8454192985 * 0.4589123414) + (0.8454192985 * 0.5291349186) + (2.280326777 * 0.009178246828) = **2.969661464**  

**Mk0 Liquid Fuel Fuselage**  
(0.623 * 0.009026927602) + (0.623 * 0.009026927602) + (0.2843845031 * 0.9253309388) + (0.1054340762 * 0.01850661878) + (0.5841462097 * 0.009026927602) + (0.2165691706 * 0.4513463801) + (0.2165691706 * 0.520411217 ) + (0.5841462097 * 0.009026927602) = **0.4973473872**  

Lets get the interpolated value from the overall mach transformation: **0.5**  

**Mk1 Liquid Fuel Fuselage**  
2.969661464 * 0.5 = 1.484830732  
**Mk0 Liquid Fuel Fuselage**  
0.4973473872 * 0.5 = 0.2486736936  

#### 7) Reynolds Number Transformation  
Reynolds Number = Density * Velocity = 0.797353 * 269.1 = 214.5676923  
Reynolds Modifier = 0.820143757099439  

**Mk1 Liquid Fuel Fuselage**  
1.484830732 * 0.820143757099439 = 1.217774655  
**Mk0 Liquid Fuel Fuselage**  
0.2486736936 * 0.820143757099439 = 0.2039481774  

#### 7) Drag Equation  
Rho = 0.797353  
V = 269.1  

> Fd = ((Rho x V^2) / 2) * A * Cd * 0.8

**Mk1 Liquid Fuel Fuselage**  
> Fd = ((0.797353 * 269.1^2) / 2) * 1.217774655  * 0.8 = 28125 = 28.1kN  
**Mk0 Liquid Fuel Fuselage**  
> Fd = ((0.797353 * 269.1^2) / 2) * 0.2039481774  * 0.8 = 4710 = 4.7kN  

#### 8) Conclusion  
The calculated drag values are very close to the displayed in game values.  
It is not quite clear to me where the errors come from, but with an average error of around 1-2% the level of precision required for our purposes is sufficient.  
My guess is that KSP rounds up or down some values, perhaps the 'Drag Vector' as displayed in the part GUI. We used the exact values, perhaps we should have use the displayed values (0.0, 0.9, 0.3).  
This concludes drag cubes, next we will be looking at other 'types' of drag.  

# Lifting Surface Drag  <a name="liftdrag"></a>  

![Lift Drag](https://github.com/Ren0k/Project-Atmospheric-Drag/blob/main/Images/Demo%20Image%203.jpg)  

The image above demonstrates quite a few 'effects' that we are going to cover. It is a bit chaotic, lets make some sense of all those arrows. 

The **red arrows** are all drag vectors. Drag vectors always apply in the opposite direction of motion. Every part with drag will have drag vectors in the same direction.   

The **light blue arrows** are 'sideways' drag vectors. Every part that uses drag cubes will not only have drag applied in the opposite direction of motion, but also directly perpendicular to the direction of motion depending on the parts orientation into the airstream. This results in a kind of Lift as a result of drag, but its not the same type of lift as we discuss next.  
In this image you will see only a few light blue arrows, those are the only parts that solely use drag cubes. The other parts are 'special parts'.  

The **dark blue arrows** are lift vectors. Unlike lift as a result of drag, lift vectors do not apply perpendicular to the direction of motion.  
The higher the AoA, the more the lift vector tilts back to the opposite direction of motion.  
The result of this, is that there is a opposite velocity vector lift component, that adds to drag. For all intents and purposes I'm going to call this Induced Drag.  
Real world induced drag is the result of a different mechanic, but the main idea is that Induced Drag is the result of lift and that is true in this situation.  

The **yellow arrows** are lift vectors from control surfaces. They work mostly the same as the dark blue lift vectors, but can have more tilt since control surfaces rotate.  

## Wings  <a name="wings"></a>  

**What makes a part a wing?**  
If you explore the GameData parts folders, you find that every part has a CFG file defining its properties.  
So far we have been looking at drag cubes. Whether a part uses drag cubes is defined by the 'dragModelType' property. If it is 'default', it means that standard drag cubes are used. If it is 'none', it means that no drag cubes are used.  
You will find that wings have a 'dragModelType' property of 'none', i.e. they do not use drag cubes. So where do wing's properties come from?  
All wings have a module called 'ModuleLiftingSurface'. This module defines the properties of the wings.  
We are actually only interested in a single property, called 'deflectionLiftCoeff'.  

**deflectionLiftCoeff** defines the Area of the wing, but also not really. It is just a modifier that we use in the place of 'A' in the drag equation.  
As it stands there is no way to calculate or acquire this value from kOS. For simple wings it turns out that it is simply its mass multiplied by 10, but this is not the case for all wings.  
To solve this problem I have included an extra database containing all stock and dlc lifting surface parts with its values.  

### Wing Lift  <a name="winglift"></a>  

Lets start with lift.  
Why is this important if we are intersted in drag? Well, because induced drag as previously mentioned is a direct result of lift generated.  

![Lift](https://www.grc.nasa.gov/www/k-12/airplane/Images/lifteq.gif)  

The image above shows the lift equation. Similar to the drag equation, but instead of a coefficient of drag (Cd) a coefficient of lift (Cl) is used.  
Again, this is how KSP does it. Luckily the method is a lot simpler than with drag cubes.  
We have all information we need, including the 'A' value (deflectionLiftCoeff), except the Cl value.  
To acquire Cl, we again follow a series of transformations described below.  

#### 1) Creating a CL value based on Angle of Attack (AoA)  
Again from the physics.cfg file we find key values described as:  

>lift // Converts Sin(AoA) into a lift coefficient (Cl) then multiplied by the below mach multiplier, dynamic pressure, the wing area, and the global lift multiplier  

Exactly the same spline curve structure as with drag cubes, but with AoA as an input.  

#### 2) Mach based CL modifier  
From the physics file:  

>liftMach // Converts mach number into a multiplier to Cl  

No further explantation required, the value of this is multiplied by Cl to get a final value

#### Results
There is one more things before we get our final equation, and that is to add the **liftMultiplier** found in the physics file, of 0.036.  
This will return a value of Lift in Kilonewton, but the rest of the equations uses Newton. That is why the multiplier I use in the script is 36.  

> L (N) = ((Rho * V^2) / 2) * **deflectionLiftCoeff** * (CL_aoa * CL_mach) * 36  

### Wing Profile Drag  <a name="wingprofiledrag"></a>  

From the same section in the physics file we find 2 sets of key value pairs. They are responsible for 'wing profile drag'.  
Perhaps not the official name, but a name that stuck with me.  
You can consider wing profile drag as drag that is always there, and is also influenced by AoA and mach but in a different way than drag cubes.  

Again 2 transformations are done:  

#### 1) Creating a CD value based on Angle of Attack (AoA)  

>drag // Converts Sin(AoA) into a drag coefficient (Cd) then multiplied by the below mach multiplier, dynamic pressure, the wing area, and the global lifting surface drag multiplier  

#### 2) Mach based CD modifier  

>dragMach // Converts mach number into a multiplier to Cd  

#### Results  
Adding the specific **liftDragMultiplier** of 0.015, or 15 for a result in Newton.  

>Wingdrag (N) = ((Rho * V^2) / 2) * **deflectionLiftCoeff** * (CD_aoa * CD_mach) * 15  

### Lift Induced Drag  <a name="winginduceddrag"></a>  

When a lifting surface produces lift, its lift vector tilts in the opposite direction of motion.  
The relationship is very simple.  

>Induced Drag (N) = Sin (AoA) * ((Rho * V^2) / 2) * **deflectionLiftCoeff** * (CL_aoa * CL_mach) * 36

## Body Lift   <a name="bodylift"></a>  

You will also find parts that both use drag cubes and have a 'ModuleLiftingSurface'.  
For example, Mk2 Spaceplane parts fall in this category, just like the vessel used in the image above.  
This does not make the part a wing though, there is a difference.  
These parts do not make use of wing profile drag, but lift and induced drag are valid properties of such a part.  
This can also be determined by the property 'useInternalDragModel' which is false at Mk2 spaceplane parts.  

Body lift is however important, the 'deflectionLiftCoeff' is usually quite a high value and induced drag can be significant.  
Body lift also uses the **liftMultiplier**, and body lift has its own spline curves in the physics file.  
You now understand why in the image above, the fuselage parts do not have light blue arrows attached.  

## Airbrakes  <a name="airbrakes"></a>  

Airbrakes do not use dragcubes. They have a module called **ModuleAeroSurface** that also has a **deflectionLiftCoeff** value.  
They do not produce lift, only drag following 2 transformations in the specific airbrake section in the physics file.  

>Converts Sin(AoA) into a drag coefficient (Cd) then multiplied by the below mach multiplier, dynamic pressure, the wing area, and the global lifting surface drag multiplier  

>dragMach // Converts mach number into a multiplier to Cd  

## Capsules and Heat Shields   <a name="capsule"></a>  

Another special case. They use drag cubes and they have the same module as wings (ModuleLiftingSurface), but without profile drag.  
They have 2 specific sets of curves in the physics file:  

>lift // Converts Sin(AoA) into a lift coefficient (Cl) then multiplied by the below mach multiplier, dynamic pressure, the wing area, and the global lift multiplier  

>liftMach // Converts mach number into a multiplier to Cl  

The mach multiplier is a constant of 0.0625.  
If you remove drag cube drag by occupying nodes, no drag but induced drag remains. Definitely not an exploitable wing.  

# Special Parts   <a name="specialparts"></a>  

Lets go over a few types of parts that need further explaining.  

## Cargo Bays  

If a cargo bay is closed, any part inside it is excluded from drag.  
The method KSP uses to determine if a part is inside a cargo bay is as follows:  
- Determine the center of the cargo bay and the specific part based on their bounds   
- Draw a line (raycast) from the center of the part to the center of the cargo bay. The line can only collide with the cargo bay.  
- If the line intersects the mesh colliders of the cargo bay, it is outside  
- If the line does not intersect the mesh colliders of the cargo bay, it is inside  

Unfortunately, I was not able to figure out how to recreate this with kOS and as such the user will have to manually specify which parts are excluded from drag or just use a vessel without parts in its cargobay.  

## Fairings  

Fairings use a procedural drag cube generation system, and are not available in the partdatabase file.  
The system used to generate drag cubes is based on a camera tool in unity and can not be recreated with kOS.  
As such, if fairings are used the user will have to manually specify drag cube values with the tool provided by the user interface.  
If not, a function will try to guess the value based on its properties.  

## Shrouds  

Some parts like engines, once combined with decouplers, can have a shroud attached.  
The script will automatically identify which parts have shrouds attached, but only from the craft file.  
Be aware that once you modify your craft in game and remove a shroud, the model will no longer be accurate.  

## ModuleDragModifier  

Certain parts like landing gears and parachute have a module called **ModuleDragModifier**.  
They are a direct modifier to drag, usually depending on a certain state.  
Landing gears have different modifier values for their deployed/retracted states.  
The ModuleDragModifier values are included in the ExtraDatabase.  

# Section 3 <a name="Section3"></a>  

## Introduction  

Now that we have a proper understanding of how things work in KSP, lets go over a few scripts or structures that require further explanation.    
I am not going to explain every part in detail, instead there are notes added to every script that will guide you.  

##  Cubic Hermite Interpolator <a name="hermite"></a>  

The splines used for the Cd/Cl transformations are of of the [cubic hermite type](https://en.wikipedia.org/wiki/Cubic_Hermite_spline).     

[This](https://en.wikibooks.org/wiki/Cg_Programming/Unity/Hermite_Curves) is the structure that unity uses in the 'LineRenderer' class.  
Since the splines already exist in the physics file, we need a cubic hermite interpolator to 'read' them.  
A cubic hermite interpolator is created with the function:  

![Hermite Interpolator](https://github.com/Ren0k/Kerbin-Temperature-Model/blob/master/Images/Hermite.jpg)   

Or as used in kOS:  

> (2 * t^3 - 3 * t^2 + 1) * y0 + (t^3 - 2 * t^2 + t) * m0 + (-2 * t^3 + 3 * t^2) * y1 + (t^3 - t^2) * m1  

With:   
t = position on curve  
y0 = start value  
y1 = end value  
m0 = start tangent  
m1 = end tangent  

### Interaction with key values

Key values in the scripts are represented as a list.  
To create a curve, you need 2 keys.  
Consider the following set from the initial CD modifier curve from the physics file:  
> local key0 is list  (0.05   ,0.0025     ,0.15      ,0.15).  
> local key1 is list  (0.4    ,0.1500     ,0.3963967 ,0.3963967).  

Here, [0] represents Cd_in, [1] represents Cd_out, [2] represents the in-tangent, [3] represents the out-tangent.  
A hermite curve can be created in this instance using: 
- key0[1] as y0. 
- key1[1] as y1. 
- key0[3] as m0.
- key1[2] as m1.

As these are the first and final keys, key0[2] and key1[3] are not used.  
The position on the curve 't' is a value between key0[0] and key1[0], this is converted to a value between 0-1 in the function using:
> t = (input-x0)/(x1-x0)  

The tangents have to be represented to scale, and a 'normfactor' is used defined as:  
> normFactor = (x1-x0)  

### Example  

We want to get the Initial Drag Cube Cd of 0.55 corrected using the spline curve found in the physics file.  
These are the 2 key values that we need:  

> key = 0.4 0.15 0.3963967 0.3963967  
> key = 0.7 0.35 0.9066986 0.9066986  

value = 0.55  
x0 = 0.4  
x1 = 0.7  
y0 = 0.15  
y1 = 0.35  
m0 = 0.3963967  
m1 = 0.9066986  
normFactor = (x1 - x0) = (0.7 - 0.4) = 0.3  
t = (value - x0) / normFactor = (0.55 - 0.4) / (0.3) = 0.15/0.3 = 0.5  
m0 = m0 * normFactor = 0.11891901  
m1 = m1 * normFactor = 0.27200958  

Cd = (2 * t^3 - 3 * t^2 + 1) * y0 + (t^3 - 2 * t^2 + t) * m0 + (-2 * t^3 + 3 * t^2) * y1 + (t^3 - t^2) * m1  
Cd = (2 * 0.5^3 - 3 * 0.5^2 + 1) * 0.15 + (0.5^3 - 2 * 0.5^2 + 0.5) * 0.11891901 + (-2 * 0.5^3 + 3 * 0.5^2) * 0.35 + (0.5^3 - 0.5^2) * 0.27200958  
Cd = 0.075 + 0.01486487625 + 0.175 - 0.0340011975 = **0.2308636787** 

## Additional Part Database  <a name="extradatabase"></a>  

Like we have seen in the previous sections, some information is not obtainable from kOS, the partdatabase or the craft file.  
For these parts a small database is added from which the relevant script can get its values.  
If you want to use modded parts with special properties, they will have to be added here.  
This is a list of properties added to the database:  

- **deflectionLiftCoeff**  
For wings/capsule/heatshields/fairings etc  
- **capsuleBottomList**  
List of parts that are of the special type 'capsulebottom' (heat shields/capsules etc)  
- **dragModifierList**  
Some parts like landing gears and parachutes have an additional drag modifier defining a specific state  
- **partVariants**  
Some parts like engines have different variants that correspond to different drag cubes. What partVariant is used, can be determined from the Craft file.  
A variable I use is called 'extensionState', and it defines what drag cube number is used. Turns out that the way drag cubes are ordered, depends on what module comes first in the part's config file. This should be automatically applied correctly by the script for all stock and dlc parts.  

## Bypassing the User Interface  <a name="nogui"></a>  

Look at the file called createProfile.ks.  
The function called 'example_CreateProfile' is an example of how to skip the user interface, just input the parameters as demonstrated, and the function will create and return the dragProfile.    
The input to the 'executeAnalysis' function has to be a lexicon of defined parameters.  

## How to read a drag profile?   <a name="readprofile"></a>  

A dragprofile has a machStart, machEnd and dT property.  
For every mach number, a lexicon key of (mach/dT) is created.  
So going mach 1.5, dT being 0.01, a key of 1.5/0.01 = 150 is used.  
The same applies to the machStart and machEnd key.  
The reason for this is to prevent floating point (rounding) errors in the keys.  

In addition, 2 tangent vectors are computed so a 'Catmull-Rom Spline' can be created between every mach key.  
This allows you to use the same hermite interpolator to get the most exact values between mach keys.  
Of course you can use a linear method (example provided), or simply round your mach number to the nearest key.  

The function 'useProfile' demonstrates a few of these concepts and it will make more sense looking through this file.  

## Useful Links   <a name="links"></a>  

- [Dev Post](https://forum.kerbalspaceprogram.com/index.php?/topic/195178-modders-notes-1100/) from the KSP team about the update that introduced drag cubes  

- [Dev Post](https://forum.kerbalspaceprogram.com/index.php?/developerarticles.html/on-cargo-bays-and-part-occlusion-r156/) about cargo bay exclusion  

- [Forum Post](https://forum.kerbalspaceprogram.com/index.php?/topic/182616-the-drag-of-parts/) about KSP drag  

- [Forum Post](https://forum.kerbalspaceprogram.com/index.php?/topic/107254-overhauls-for-10/page/4/#comment-2165453) and an insightful discussion about Lift and Drag  

- [Guide](https://github.com/Ren0k/Kerbin-Temperature-Model) for the tool provided here with which you calculate kerbin air temperatures  



