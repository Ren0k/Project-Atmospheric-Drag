//////////////////////////////////////////
// Analysis Menu                        //
//////////////////////////////////////////
// This is the script that creates the analysis menu using the Guitools lib
@lazyGlobal off.

function analysisMenu {
    // PUBLIC analysisMenu :: nothing -> 2D Associative Array

    // Variables Init
    local vesselPartList is lexicon().
    local dragProfile is lexicon().
    local hasAtm is body:atm:exists.
    local heightAtm is body:atm:height.

    // Lexicon responsible for loop selection
    local loopSelection is lexicon(
        "Continue", False,
        "Realtime", False,
        "End", False
    ).

    ///// POSITION VECTOR COLLECTION /////
    local positionVectorList is list().

    ///// PARAMETER COLLECTION /////
    local parametersCollection is lexicon(
        "Scan", True,
        "Gears", "Up",
        "Airbrakes", "Retracted",
        "AeroSurfaces", "Retracted",
        "Parachutes", "Idle",
        "Custom AoA", 0,
        "Custom AoA Yaw", 0,
        "Profile", "Retrograde",
        "Original Scan", True 
    ).

    ///// STRING COLLECTION /////
    local stringCollection is lexicon(
        "label1", "<color=#1e3fa4>Vessel Analysis Menu</color>",
        "label2", "Before analyzing your vessel, please do the following:",
        "label3", "<b>1) Create a copy of your PartDatabase.cfg file in the Ships/Script/dragProfile/DATA/PartDatabase folder and select 'Scan Database', if not already done so.</b>",
        "label4", "<b>2) Create a copy of your current ship .Craft file in the Ships/Script/dragProfile/DATA/Vessels folder.</b>",
        "label5", "<b>3) Make sure that your ship is in the correct configuration that you want to create the profile for, or manually configure your ships configuration.</b>",
        "label6", "<color=#1e3fa4>Part Configuration Menu</color>",
        "label7", "<b>Select what specific configuration you want to use. Additionally you can decide to scan the vessel in its current actual configuration.</b>",
        "label8", "If you select <b>Analyze Now</b> your vessel will be analyzed for a retrograde profile in your current state. Special parts will be guesstimated.",
        "label9", "Vessel is analysed, select <b>create profile</b> to go to the creation of a drag profile.",
        "label10", "Selecting <b>dragGUI</b> will display realtime drag information and analysis for your vessel.",
        "label11", "<b>Note that this might take some time, it is recommended to increase the KOS IPU value below.</b>",
        "Label12", "<b>Special part modification menu</b>",
        "label13", "Some parts could be excluded from drag if they are, for example, within a closed cargobay. Select those parts; their position will be highlighted upon selection.",
        "label14", "Manually edit part values. Useful if for example fairings are fitted.",
        "label15", "<b>WARNING! Values are not checked for errors. Inputting wrong values or strings might result in errors!</b>",
        "label16", "You can load a saved partlist here. This has to be a partlist created here, in the right format.",
        "label17", "You can save the created partlist here."
    ).

    //////////////////////////////////////////
    // GUI FUNCTIONS                        //
    //////////////////////////////////////////

    function checkForFiles {
        // PRIVATE checkForFiles :: nothing -> nothing
        local craftName is (ship:name+".craft").
        if (exists("dragProfile/DATA/PartDatabase/PartDatabase.cfg")) and (exists("dragProfile/DATA/Vessels/"+craftName)) return True.
        else set warningLabel:text to "<color=red><b>ONE OF THE FILES WAS NOT FOUND, PLEASE FOLLOW THE INSTRUCTIONS!</b></color>".
    }

    function buttonRescan {
        // PRIVATE buttonRescan :: nothing -> nothing
        if (exists("dragProfile/DATA/PartDatabase/PartDatabase.cfg")) {
            set warningLabel:text to "<color=red><b>SCANNING PARTDATABASE</b></color>".
            lib_getVesselAnalysis["rescanPartDatabase"]().
            set warningLabel:text to "Partdatabase scanned!".
        } else set warningLabel:text to "<color=red><b>PARTDATABASE.CFG NOT FOUND!</b></color>".
    }

    function slider_IPU {
        // PRIVATE slider_IPU :: string : float -> nothing
        parameter sliderName, Value.
        set getGui("1-label-7"):text to "IPU SELECTED = "+round(Value,0):tostring.
        set config:ipu to round(Value,0).
    }

    function button_Gears {
        // PRIVATE button_Gears :: string : bool -> nothing
        parameter       buttonName, buttonState.
        if buttonState {set getGui(buttonName):text to "Down". set parametersCollection["Gears"] to "Down".}
        else {set getGui(buttonName):text to "Up". set parametersCollection["Gears"] to "Up".}
    }

    function button_Airbrake {
        // PRIVATE button_Airbrake :: string : bool -> nothing
        parameter       buttonName, buttonState.
        if buttonState {set getGui(buttonName):text to "Extended". set parametersCollection["Airbrakes"] to "Extended".}
        else {set getGui(buttonName):text to "Retracted". set parametersCollection["Airbrakes"] to "Retracted".}
    }

    function button_AeroSurfaces{
        // PRIVATE button_AeroSurfaces :: string : bool -> nothing
        parameter       buttonName, buttonState.
        if buttonState {set getGui(buttonName):text to "Deployed". set parametersCollection["AeroSurfaces"] to "Deployed".}
        else {set getGui(buttonName):text to "Retracted". set parametersCollection["AeroSurfaces"] to "Retracted".}
    }

    function button_Parachutes{
        // PRIVATE button_Parachutes :: string -> nothing
        parameter       buttonName.
        if getGui(buttonName):text = "Idle" {set parametersCollection["Parachutes"] to "Semideployed". set getGui(buttonName):text to "Semideployed".}
        else if getGui(buttonName):text = "Semideployed" {set parametersCollection["Parachutes"] to "Deployed". set getGui(buttonName):text to "Deployed".}
        else if getGui(buttonName):text = "Deployed" {set parametersCollection["Parachutes"] to "Idle". set getGui(buttonName):text to "Idle".}
    }

    function button_Profile{
        // PRIVATE button_Profile :: string : bool -> nothing
        parameter       buttonName, buttonState.
        if buttonState {set getGui(buttonName):text to "Prograde". set parametersCollection["Profile"] to "Prograde".}
        else {set getGui(buttonName):text to "Retrograde". set parametersCollection["Profile"] to "Retrograde".}
    }

    function select_CustomAoA {
        // PRIVATE select_CustomAoA :: string -> nothing
        parameter       inputString.
        local selectedAoA is inputString:toscalar(0).
        if (selectedAoA > 90) set selectedAoA to 90.
        else if selectedAoA < -90 set selectedAoA to -90.
        set AoATextfield:text to selectedAoA:tostring.
        set parametersCollection["Custom AoA"] to selectedAoA.
    }

    function select_CustomAoAYaw {
        // PRIVATE select_CustomAoAYaw :: string -> nothing
        parameter       inputString.
        local selectedAoA is inputString:toscalar(0).
        if (selectedAoA > 90) set selectedAoA to 90.
        else if selectedAoA < -90 set selectedAoA to -90.
        set AoATextfieldYaw:text to selectedAoA:tostring.
        set parametersCollection["Custom AoA Yaw"] to selectedAoA.
    }

    function button_OpenSpecialPartsMenu {
        // PRIVATE button_OpenSpecialPartsMenu :: string -> nothing
        parameter       buttonName.
        if getGui(buttonName):text = "False" {set parametersCollection["Special Parts"] to "True". set getGui(buttonName):text to "True".}
        else if getGui(buttonName):text = "True" {set parametersCollection["Special Parts"] to "False". set getGui(buttonName):text to "False".}
    }

    function button_Create{
        // PRIVATE button_Create :: nothing -> nothing
        set parametersCollection["Scan"] to True. 
        showGUI(3).
        doAnalysis().
    }

    function button_CreateScan {
        // PRIVATE button_CreateScan :: nothing -> nothing
        set parametersCollection["Scan"] to False. 
        set AoATextfield:confirmed to True. 
        set AoATextfieldYaw:confirmed to True.
        hideGUI(2). 
        showGUI(3).
        doAnalysis().
    }

    function button_Continue {
        // PRIVATE button_Ignore :: nothing -> nothing
        hideGUI(8).
        showGUI(3).
        set getGui("3-label-1"):text to "Creating Vessel Drag Object".
        set labelPartList:text to vesselPartList:tostring.
        createDragObject().
        hideGUI(3).
        showGUI(4).  
    }

    ///// PART EXCLUSION FUNCTIONS /////

    function exclude_Item {
        // PRIVATE exclude_Item :: guiObject : vector : vector : vector : string -> nothing
        parameter       buttonObject,
                        partName,
                        partObject.

            local positionVector is vecdraw(partObject:position, up:topvector, RGB(1,0,0), "|", 3, false, 0.1, true, true).
            local positionVector2 is vecdraw(partObject:position, up:starvector, RGB(0,1,0), "|", 3, false, 0.1, true, true).
            local positionVector3 is vecdraw(partObject:position, up:forevector, RGB(0,0,1), "|", 3, false, 0.1, true, true).
            positionVectorList:add(positionVector).
            positionVectorList:add(positionVector2).
            positionVectorList:add(positionVector3).           

        if buttonObject:text:contains("Included") {
            set buttonObject:text to "Excluded".
            set positionVector:show to true.
            set positionVector2:show to true.
            set positionVector3:show to true.
            set vesselPartList[partName]["Excluded"] to "True".
        }
        else if buttonObject:text:contains("Excluded") {
            set buttonObject:text to "Included".
            set positionVector:show to false.
            set positionVector2:show to false.
            set positionVector3:show to false.
            set vesselPartList[partName]["Excluded"] to "False".
        }
    }

    function partExclusion {
        // PRIVATE partExclusion :: nothing -> nothing
        hideGui(8).
        showGui(9).
        for item in vesselPartList:keys {
            local partObject is vesselPartList[item]["object"].
            local partName is item.
            guiBox("9-scrollbox-1", "9-box-"+item:tostring, 475, 30).
            label("9-box-"+item:tostring, "9-label-"+item:tostring, item:tostring, 14, "LEFT", "Calibri", false, false, 365, 25).

            local partExcludeButton is button("9-box-"+item:tostring, "9-button-"+item:tostring, "Included", {exclude_Item(partExcludeButton, partName, partObject).}, false, false, false, 14, "Calibri", false, false, 100, 25).
        }
    }

    function removeExlusionMenu {
        // PRIVATE removeExlusionMenu :: nothing -> nothing
        for guiObject in getGui("9-scrollbox-1"):widgets {
            guiObject:dispose().
        }
    }

    function removePositionVectors {
        // PRIVATE removePositionVectors :: nothing -> nothing
        if positionVectorList:length > 0 {
            for pv in positionVectorList {
                set pv:show to false.
            }
        }
        positionVectorList:clear().
        clearvecdraws().
    }

    ///// MANUAL EDITING FUNCTIONS /////

    function manualEdit {
        // PRIVATE manualEdit :: nothing -> nothing
        hideGui(8).
        showGui(10).
        for item in vesselPartList:keys {
            local partName is item.
            guiBox("10-scrollbox-1", "10-box-"+item:tostring, 675, 30).
            label("10-box-"+item:tostring, "10-label-"+item:tostring, item:tostring, 14, "LEFT", "Calibri", false, false, 565, 25).
            button("10-box-"+item:tostring, "10-button-"+item:tostring, "Select", {selectPartManualEdit(partName).}, false, false, false, 14, "Calibri", false, false, 100, 25).
        }
    }

    function selectPartManualEdit {
        // PRIVATE selectPartManualEdit :: string -> nothing
        parameter       partName.

        local selectedPart is partName.
        local partObject is vesselPartList[partName]["object"].
        mainGUI("Temp", 5, 700, 700).
        label("Temp","Temp-label-1","<color=#1e3fa4>Edit Part</color>",28,"Center").
        button("Temp", "Temp-button-1", "Return", {for gw in getGui("Temp"):widgets gw:dispose(). removePositionVectors(). hideGui("Temp"). showGui(10).}, false, false, false, 20, "Calibri", false, false, 675, 30).
        scrollbox("Temp", "Temp-scrollbox-1").
        hideGui(10).
        showGui("Temp").
        if parametersCollection["Original Scan"] {
            local positionVector is vecdraw(partObject:position, up:topvector, RGB(1,0,0), "|", 3, true, 0.1, true, true).
            local positionVector2 is vecdraw(partObject:position, up:starvector, RGB(0,1,0), "|", 3, true, 0.1, true, true).
            local positionVector3 is vecdraw(partObject:position, up:forevector, RGB(0,0,1), "|", 3, true, 0.1, true, true).
            positionVectorList:add(positionVector).
            positionVectorList:add(positionVector2).
            positionVectorList:add(positionVector3).
        }
        for entry in vesselPartList[partname]:keys {
            local keyName is entry.
            local originalValue is vesselPartList[selectedPart][keyName].
            guiBox("Temp-scrollbox-1", "Temp-box-"+entry:tostring, 675, 30).
            label("Temp-box-"+entry:tostring, "Temp-label-"+entry:tostring, entry:tostring, 14, "LEFT", "Calibri", false, false, 250, 25).
            textfield("Temp-box-"+entry:tostring, "Temp-textfield-"+entry:tostring, vesselPartList[partname][entry]:tostring, {parameter str. confirmManualEdit(str, keyName, selectedPart, originalValue).}, "", false, false, 425, 25).
        }
    }

    function confirmManualEdit {
        // PRIVATE confirmManualEdit :: string : string : string : string -> nothing
        parameter       inputString,
                        keyName,
                        partName,
                        originalValue.

        if originalValue <> inputString {
            if inputString:toscalar(1E20) < 1E19 set inputString to inputString:toscalar().
            set vesselPartList[partName][keyName] to inputString.
        }
    }

    function removeManualEditObjects {
        // PRIVATE removeManualEditObjects :: nothing -> nothing
        for guiObject in getGui("10-scrollbox-1"):widgets {
            guiObject:dispose().
        }
    }

    ///// PARTLIST LOADING AND SAVING /////

    function button_savePartlist {
        // PRIVATE button_savePartlist :: nothing -> nothing
        set savePartlistTextfield:confirmed to true.
        local partlistFileName is savePartlistTextfield:text.
        set vesselPartList["parametersCollection"] to parametersCollection.
        writejson(vesselPartList, "dragProfile/DATA/Partlists/"+partlistFileName).
        set partlistSaveMenuLabel3:text to partlistFileName+"<color=red><b> saved! </b></color>".
        vesselPartList:remove("parametersCollection").
    }

    function button_loadPartlist {
        // PRIVATE button_loadPartlist :: nothing -> nothing
        set loadPartlistTextfield:confirmed to true.
        local selectedPartlist is loadPartlistTextfield:text.
        if exists("dragProfile/DATA/Partlists/"+selectedPartlist) {
            local newPartList is readjson("dragProfile/DATA/Partlists/"+selectedPartlist).
            set vesselPartList to newPartList.
            set parametersCollection to vesselPartList["parametersCollection"].
            vesselPartList:remove("parametersCollection").
            set partlistMenuLabel3:text to selectedPartlist+"<color=red><b> loaded!</b></color>".
            set getGui("11-button-3"):visible to true.
            set getGui("11-button-4"):visible to true.
        } else {
            set partlistMenuLabel3:text to selectedPartlist+"<color=red><b> not found!</b></color>".
        }
    }

    function button_usePartList {
        // PRIVATE button_usePartList :: nothing -> nothing
        hideGui(11).
        showGui(3).
        set getGui("3-label-1"):text to "Creating Drag Object".
        createDragObject().
        hideGUI(3).
        showGUI(4).   
    }

    function button_reEditPartList {
        // PRIVATE button_reEditPartList :: nothing -> nothing
        hideGui(11).
        set parametersCollection["Original Scan"] to False.
        manualEdit().
        set getGui("10-button-1"):onclick to {hideGUI(10). removeManualEditObjects(). showGUI(11).}.
    }

    ///// MAIN EXECUTION FUNCTIONS /////

    function doAnalysis {
        // PRIVATE doAnalysis :: nothing -> nothing
        set vesselPartList to lib_getVesselAnalysis["executeAnalysis"](parametersCollection, getGui("3-label-1")).
        set getGui("10-button-1"):onclick to {hideGUI(10). removeManualEditObjects(). showGUI(8).}.
        set parametersCollection["Original Scan"] to True.
        if parametersCollection:haskey("Special Parts") {
            if parametersCollection["Special Parts"] = "True" {
                hideGUI(3).
                button(8, "8-button-2", "Part Exclusion", {partExclusion().}).
                button(8, "8-button-3", "Manual Edit", {manualEdit().}).
                showGUI(8). 
            }
        } else {
            set getGui("3-label-1"):text to "Creating Drag Object".
            createDragObject().
            hideGUI(3).
            showGUI(4).   
        }
    }

    function createDragObject {
        // PRIVATE createDragObject :: nothing -> nothing
        set dragProfile to lib_DragProfile["createProfile"](vesselPartList, parametersCollection).
    }

    function realtimeDrag {
        // PRIVATE realtimeDrag :: nothing -> nothing
        // Information requests
        local TAS is ship:velocity:surface:mag.
        local shipAltitude is ship:altitude.
        if hasAtm and (shipAltitude < heightAtm) {
            local flightData is lib_AtmosphericFlightData["getData"](TAS, shipAltitude).
            local rho is flightData["RHO"].
            local mn is flightData["MN"].
            local temp is flightData["SAT"].
            local dragInformation is dragProfile["getRealtimeDrag"](TAS,rho,mn).

            // Updating Labels
            set realTimeLabels["7-label-2"]:text to "Total Drag: "+round(dragInformation["Total Drag"],2):tostring + " N".
            set realTimeLabels["7-label-3"]:text to "Body Drag: "+round(dragInformation["Body Drag"],2):tostring  + " N".
            set realTimeLabels["7-label-27"]:text to "Body Tip Drag: "+round(dragInformation["Body Tip Drag"],2):tostring  + " N".
            set realTimeLabels["7-label-28"]:text to "Body Surface Drag: "+round(dragInformation["Body Surface Drag"],2):tostring  + " N".
            set realTimeLabels["7-label-29"]:text to "Body Tail Drag: "+round(dragInformation["Body Tail Drag"],2):tostring  + " N".
            set realTimeLabels["7-label-4"]:text to "Total Wing Drag: "+round(dragInformation["Total Wing Drag"],2):tostring  + " N".
            set realTimeLabels["7-label-5"]:text to "Wing Profile Drag: "+round(dragInformation["Wing Drag"],2):tostring  + " N".
            set realTimeLabels["7-label-6"]:text to "Wing Induced Drag: "+round(dragInformation["Wing Induced Drag"],2):tostring  + " N".
            set realTimeLabels["7-label-7"]:text to "Special Drag: "+round(dragInformation["Special Drag"],2):tostring  + " N".
            set realTimeLabels["7-label-8"]:text to "Body Lift Induced Drag: "+round(dragInformation["Body Lift Induced Drag"],2):tostring  + " N".
            set realTimeLabels["7-label-9"]:text to "Capsule Lift Induced Drag: "+round(dragInformation["Capsule Lift Induced Drag"],2):tostring  + " N".
            set realTimeLabels["7-label-10"]:text to "Wing Lift: "+round(dragInformation["Wing Lift"],2):tostring  + " N".
            set realTimeLabels["7-label-11"]:text to "True Air Speed: "+round(TAS,2):tostring  + " m/s".
            set realTimeLabels["7-label-12"]:text to "Altitude MSL: "+round(shipAltitude,2):tostring  + " m".
            set realTimeLabels["7-label-13"]:text to "Density: "+round(rho,5):tostring  + " kg/m^3".
            set realTimeLabels["7-label-14"]:text to "Temperature: "+round(temp,2):tostring  + " K".
            set realTimeLabels["7-label-15"]:text to "Mach Number: "+round(mn,3):tostring.
            set realTimeLabels["7-label-16"]:text to "Reynolds Number: "+round(dragInformation["Reynolds Number"],2):tostring.
            set realTimeLabels["7-label-17"]:text to "Dynamic Pressure: "+round(dragInformation["Dynamic Pressure"],2):tostring + " Pa".
            set realTimeLabels["7-label-18"]:text to "Overall Multiplier: "+round(dragInformation["Overall Multiplier"],5):tostring.
            set realTimeLabels["7-label-19"]:text to "Mach Multiplier: "+round(dragInformation["Mach Multiplier"],5):tostring.
            set realTimeLabels["7-label-20"]:text to "Reynolds Multiplier: "+round(dragInformation["Reynolds Multiplier"],5):tostring.
            set realTimeLabels["7-label-21"]:text to "Tip Multiplier: "+round(dragInformation["Tip Multiplier"],5):tostring.
            set realTimeLabels["7-label-22"]:text to "Surface Multiplier: "+round(dragInformation["Surface Multiplier"],5):tostring.
            set realTimeLabels["7-label-23"]:text to "Tail Multiplier: "+round(dragInformation["Tail Multiplier"],5):tostring.
            set realTimeLabels["7-label-24"]:text to "Wing Mach Multiplier: "+round(dragInformation["Wing Mach Multiplier"],5):tostring.
            set realTimeLabels["7-label-25"]:text to "Wing Lift Mach Multiplier: "+round(dragInformation["Wing Lift Mach Multiplier"],5):tostring.
            set realTimeLabels["7-label-26"]:text to "Body Lift Mach Multiplier: "+round(dragInformation["Body Lift Mach Multiplier"],5):tostring.
            set realTimeLabels["7-label-30"]:text to "Body Drag/Area/Velocity: "+round(dragInformation["Body Drag per Area"]/TAS,3):tostring + " N/m^3/m/s".
            set realTimeLabels["7-label-31"]:text to "Body Lift: "+round(dragInformation["Body Lift"],3):tostring + " N".
            set realTimeLabels["7-label-32"]:text to "Total Lift: "+round(dragInformation["Total Lift"],3):tostring + " N".
            set realTimeLabels["7-label-33"]:text to "Lift-to-Drag Ratio: "+round(dragInformation["Lift-to-Drag Ratio"],3):tostring.
            set realTimeLabels["7-label-34"]:text to "Information Latency: "+round((time:seconds-realTimeLabels["Time"])*1000,2):tostring+" ms".
            set realTimeLabels["Time"] to time:seconds.
            }
    }


    //////////////////////////////////////////
    // MENUS                                //
    //////////////////////////////////////////

    ///// MENU 1 /////
    // Instructions Menu
    mainGUI(1).
    local imageLabel1 is label(1,"1-label-image","",24,"Center").
    set imageLabel1:image to "dragProfile\GUI\Images\image1".
    label(1,"1-label-1",stringCollection["label1"],24,"Center").
    label(1,"1-label-2",stringCollection["label2"],16).
    label(1,"1-label-3",stringCollection["label3"],14).
    label(1,"1-label-4",stringCollection["label4"],14).
    label(1,"1-label-5",stringCollection["label5"],14).
    getGui(1):addspacing(20).
    button(1,"1-button-1", "Configure", {if checkForFiles {hideGUI(1).showGUI(2).}}).
    button(1,"1-button-5", "Load Partlist", {hideGui(1). showGui(11).}).
    button(1,"1-button-3", "Scan Partdatabase", {buttonRescan().}).
    getGui(1):addspacing(20).
    local warningLabel is label(1,"1-label-6",stringCollection["label8"],14).
    button(1,"1-button-2", "Analyze Now", {if checkForFiles {hideGUI(1). button_Create().}}).
    getGui(1):addspacing(10).
    label(1,"1-label-6",stringCollection["label11"],14).
    label(1,"1-label-7","IPU SELECTED = " +config:ipu:tostring,14, "LEFT").
    local IPUslider is slider(1,"1-slider-1", 50, 2000, {parameter value. slider_IPU("1-slider-1", value).}).
    set IPUslider:value to max(config:ipu,400).
    
    ///// MENU 2 /////
    // Part Configuration Menu
    mainGUI(2).
    label(2,"2-label-1",stringCollection["label6"],24,"Center").
    label(2,"2-label-2",stringCollection["label7"],16).
    guiBox(2,"2-box-5").
    label("2-box-5", "2-label-7", "Profile: ", 14, "LEFT", "Calibri", false, false, 200, 25).
    button("2-box-5","2-button-5", "Retrograde", {parameter buttonState. button_Profile("2-button-5", buttonState).}, True, false, false, 14, "Calibri", false, false, 200, 25).
    guiBox(2,"2-box-1").
    label("2-box-1", "2-label-3", "Landing Gears/Landing Legs: ", 14, "LEFT", "Calibri", false, false, 200, 25).
    button("2-box-1","2-button-1", "Up", {parameter buttonState. button_Gears("2-button-1", buttonState).}, True, false, false, 14, "Calibri", false, false, 200, 25).
    guiBox(2,"2-box-2").
    label("2-box-2", "2-label-4", "Airbrakes: ", 14, "LEFT", "Calibri", false, false, 200, 25).
    button("2-box-2","2-button-2", "Retracted", {parameter buttonState. button_Airbrake("2-button-2", buttonState).}, True, false, false, 14, "Calibri", false, false, 200, 25).
    guiBox(2,"2-box-3").
    label("2-box-3", "2-label-5", "Aero Control Surfaces: ", 14, "LEFT", "Calibri", false, false, 200, 25).
    button("2-box-3","2-button-3", "Retracted", {parameter buttonState. button_AeroSurfaces("2-button-3", buttonState).}, True, false, false, 14, "Calibri", false, false, 200, 25).
    guiBox(2,"2-box-4").
    label("2-box-4", "2-label-6", "Parachutes: ", 14, "LEFT", "Calibri", false, false, 200, 25).
    button("2-box-4","2-button-4", "Idle", {button_Parachutes("2-button-4").}, false, false, false, 14, "Calibri", false, false, 200, 25).
    guiBox(2,"2-box-6").
    label("2-box-6", "2-label-8", "Custom AoA (Pitch): ", 14, "LEFT", "Calibri", false, false, 200, 25).
    local AoATextfield is textfield("2-box-6", "2-textfield-1", "0", {parameter str. select_CustomAoA(str).}, "", false, false, 200, 25, "Left").
    guiBox(2,"2-box-7").
    label("2-box-7", "2-label-9", "Custom AoA (Yaw): ", 14, "LEFT", "Calibri", false, false, 200, 25).
    local AoATextfieldYaw is textfield("2-box-7", "2-textfield-2", "0", {parameter str. select_CustomAoAYaw(str).}, "", false, false, 200, 25, "Left").
    guiBox(2,"2-box-8").
    label("2-box-8", "2-label-10", "Special Menu: ", 14, "LEFT", "Calibri", false, false, 200, 25).
    button("2-box-8","2-button-6", "False", {button_OpenSpecialPartsMenu("2-button-6").}, false, false, false, 14, "Calibri", false, false, 200, 25).
    getGui(2):addspacing(20).
    button(2,"1-button-6", "Analyze selected configuration", {button_CreateScan().}, false, false, false, 16).
    button(2,"1-button-6", "Scan present configuration", {hideGUI(2). button_Create().}, false, false, false, 16).

    ///// MENU 3 /////
    // Loading Menu
    mainGUI(3, 5, 400, 200).
    label(3,"3-label-2","<color=#1e3fa4>Analyzing Ship - Status</color>",24,"Center").
    getGUI(3):addspacing(20).
    label(3,"3-label-1","STATUS",20,"Center").
  
    ///// MENU 4 /////
    // Options Selection
    mainGUI(4).
    local imageLabel2 is label(4,"4-label-image","",24,"Center").
    set imageLabel2:image to "dragProfile\GUI\Images\image2".
    label(4,"4-label-1","<color=#1e3fa4>Results</color>",24,"Center").
    getGUI(4):addspacing(10).
    label(4,"4-label-2",stringCollection["label9"],16,"Left").
    label(4,"4-label-3",stringCollection["label10"],16,"Left").
    getGUI(4):addspacing(20).
    button(4, "4-button-5", "Save Part List", {hideGUI(4). showGUI(12).}).
    button(4, "4-button-1", "Review Part List", {hideGUI(4). set labelPartList:text to vesselPartList:tostring. showGUI(5).}).
    button(4, "4-button-2", "Review Parameters", {hideGUI(4). set labelParametersCollection:text to parametersCollection:tostring. showGUI(6).}).
    button(4,"4-button-4", "dragGUI", {hideGUI(4). showGUI(7). set loopSelection["Realtime"] to True.}).
    getGUI(4):addspacing(20).
    button(4,"4-button-3", "Create Profile", {hideGUI(4). set loopSelection["End"] to True.}).

    ///// MENU 5 /////
    // Part List
    mainGUI(5).
    label(5,"5-label-1","<color=#1e3fa4>Part Information</color>",20,"Center").
    guiBox(5, "5-box-1", 400, 600).
    scrollbox("5-box-1", "5-scroll-1").
    local labelPartList is label("5-scroll-1","5-label-2",vesselPartList:tostring,14,"Left").
    getGUI(5):addspacing(20).
    button(5, "5-button-1", "Return", {hideGUI(5). showGUI(4).}).

    ///// MENU 6 /////
    // Parameters List
    mainGUI(6).
    label(6,"6-label-1","<color=#1e3fa4>Parameters Selected</color>",20,"Center").
    guiBox(6, "6-box-1", 400, 200).
    scrollbox("6-box-1", "6-scroll-1").
    local labelParametersCollection is label("6-scroll-1","6-label-2",parametersCollection:tostring,14,"Left").
    getGUI(6):addspacing(20).
    button(6, "6-button-1", "Return", {hideGUI(6). showGUI(4).}).

    ///// MENU 7 /////
    // dragGUI
    mainGUI(7).
    label(7,"7-label-1","<color=#1e3fa4>dragGUI</color>",24,"Center").
    getGUI(7):addspacing(20).
    for i in range(2,35) label(7, "7-label-"+i:tostring,"STANDBY",16,"Left").
    local realTimeLabels is lexicon("Time", time:seconds).
    for i in range(2,35) set realTimeLabels["7-label-"+i:tostring] to getGui("7-label-"+i:tostring).
    getGUI(7):addspacing(20).
    button(7, "7-button-1", "Return", {set loopSelection["Realtime"] to False. hideGUI(7). showGUI(4).}).

    ///// MENU 8 /////
    // Special Parts
    mainGUI(8).
    label(8,"8-label-1","<color=#1e3fa4>Special Menu</color>",24,"Center").
    label(8,"8-label-2",stringCollection["label12"],16).
    getGUI(8):addspacing(20).
    button(8, "8-button-1", "Continue", {button_Continue().}).
    getGUI(8):addspacing(20).

    ///// MENU 9 /////
    // Part Exclusion
    mainGUI(9, 5, 500, 600).
    label(9,"9-label-1","<color=#1e3fa4>Select Excluded Parts</color>",24,"Center").
    label(9,"9-label-2",stringCollection["label13"],16).
    getGUI(9):addspacing(20).
    button(9, "9-button-1", "Return", {hideGUI(9). removePositionVectors(). removeExlusionMenu(). showGUI(8).}, false, false, false, 20, "Calibri", false, false, 500, 30).
    getGUI(9):addspacing(20).
    scrollbox(9, "9-scrollbox-1").

    ///// MENU 10 /////
    // Manual Edit
    mainGUI(10, 5, 700, 600).
    label(10,"10-label-1","<color=#1e3fa4>Edit Part Values</color>",24,"Center").
    label(10,"10-label-2",stringCollection["label14"],16).
    label(10,"10-label-3",stringCollection["label15"],16).
    getGUI(10):addspacing(20).
    button(10, "10-button-1", "Return", {hideGUI(10). removeManualEditObjects(). showGUI(8).}, false, false, false, 20, "Calibri", false, false, 700, 30).
    getGUI(10):addspacing(20).
    scrollbox(10, "10-scrollbox-1").

     ///// MENU 11 /////
    // Load Partlist  
    mainGUI(11, 5, 500).
    label(11,"11-label-1","<color=#1e3fa4>Load Partlist</color>",24,"Center").
    label(11,"11-label-2",stringCollection["label16"],16).
    getGUI(11):addspacing(20).
    local partlistMenuLabel3 is label(11,"11-label-3","<b>Partlist Name - default is the current ship's name.</b>",16,"Center").
    local loadPartlistTextfield is textfield(11, "11-textfield-1", ship:name+"_partlist.json", {parameter str.}, "", false, false, 475, 25, "Left").
    button(11, "11-button-1", "Load", {button_loadPartlist().}).
    button(11, "11-button-2", "Cancel", {hideGUI(11). showGUI(1).}).
    getGui(1):addspacing(20).
    button(11, "11-button-4", "Edit", {button_reEditPartList().}).
    set getGui("11-button-4"):visible to False.
    button(11, "11-button-3", "Use", {button_usePartList().}).
    set getGui("11-button-3"):visible to False.

    ///// MENU 12 /////
    // Save Partlist  
    mainGUI(12, 5, 500).
    label(12,"12-label-1","<color=#1e3fa4>Save Partlist</color>",24,"Center").
    label(12,"12-label-2",stringCollection["label17"],16).
    getGUI(12):addspacing(20).
    local partlistSaveMenuLabel3 is label(12,"12-label-3","<b>Partlist Name - default is the current ship's name.</b>",16,"Center").
    local savePartlistTextfield is textfield(12, "12-textfield-1", ship:name+"_partlist.json", {parameter str.}, "", false, false, 475, 25, "Left").
    button(12, "11-button-1", "Save", {button_savePartlist().}).
    button(12, "11-button-2", "Return", {hideGUI(12). showGUI(4).}).

    ///// MENU 13 /////
    // Partdatabase Scan
    mainGUI(13).
    label(13,"13-label-1","<color=red>Initial Part Database Scan</color>",24,"Center").
    getGUI(13):addspacing(20).
    label(13,"13-label-2","<b>Please Wait</b>",20,"Center").  
    getGUI(13):addspacing(20).
    label(13,"13-label-3","Once the scan is complete, you do not have to scan again unless the part database has changed.",20,"Left").


    //////////////////////////////////////////
    // LOOP AND FINISH                      //
    //////////////////////////////////////////

    ///// PartDatabase Scan /////
    if (not exists("dragProfile/DATA/PartDatabase/PartDatabase.json")) and (exists("dragProfile/DATA/PartDatabase/PartDatabase.cfg")) {
        showGUI(13).
        buttonRescan().
        hideGUI(13).
    }

    ///// Main Loop /////
    showGUI(1).

    until loopSelection["End"] {
        if (loopSelection["Realtime"]) realtimeDrag().
    }

    ///// Return and End /////
    for object in getCollection():values object:dispose().
    getCollection():clear().

    set vesselPartList["parametersCollection"] to parametersCollection.
    set vesselPartList["dragProfile"] to dragProfile.

    return vesselPartList.
}



