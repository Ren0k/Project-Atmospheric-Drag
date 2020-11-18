//////////////////////////////////////////
// Profile Menu                         //
//////////////////////////////////////////
// This is the script that creates the profile menu using the Guitools lib
@lazyGlobal off.

function profileMenu {
    // PUBLIC profileMenu :: 2D Associative Array -> 2D Associative Array
    parameter       vesselPartList.

    ///// LEXICONS /////
    local loopSelection is lexicon(
        "Continue", False,
        "Realtime", False,
        "End", False
    ).

    local stringCollection is lexicon(
        "label1", "<color=#1e3fa4>Drag Profile Creation</color>",
        "label2", "Select <b>create</b> if you want to create the profile for the selected range and dT, or manually configure the settings.",
        "label3", "This might take some time, depending on your settings. The minimum mach value is 0, the maximum mach value is 25.",
        "label4", "Drag profile created. Select review to review the created profile, or save it to a file",
        "label5", "Do not select complex values, with complex decimals. Ideally you should set the dT value to either 0.0001/0.001/0.01/0.1."
    ).

    local parametersCollection is vesselPartList["parametersCollection"]:copy.
    local dragProfileFunction is vesselPartList["dragProfile"]:copy.
    local dragProfile is lexicon().
    vesselPartList:remove("parametersCollection").
    vesselPartList:remove("dragProfile").
    set parametersCollection["Mach Start"] to 0.
    set parametersCollection["Mach End"] to 10.
    set parametersCollection["dT"] to 0.01.
    local fileName is shipName.

    //////////////////////////////////////////
    // GUI FUNCTIONS                        //
    //////////////////////////////////////////

    function selectMachStart {
        // PRIVATE selectMachStart :: string -> nothing
        parameter       inputString.
        local machStart is inputString:toscalar(0).
        if (machStart > 25) set machStart to 25.
        if (machStart < 0) set machStart to 0.
        if (machstart > (parametersCollection["Mach End"]-parametersCollection["dT"])) set machStart to (parametersCollection["Mach End"]-parametersCollection["dT"]).
        set machStartTextfield:text to machStart:tostring.
        set parametersCollection["Mach Start"] to machStart.
    }
    function selectMachEnd {
        // PRIVATE selectMachEnd :: string -> nothing
        parameter       inputString.
        local machEnd is inputString:toscalar(10).
        if (machEnd > 25) set machEnd to 25.
        if (machEnd < 0) set machEnd to 0.
        if (machEnd <= (parametersCollection["Mach Start"]+parametersCollection["dT"])) set machEnd to (parametersCollection["Mach Start"] + parametersCollection["dT"]).
        set machEndTextfield:text to machEnd:tostring.
        set parametersCollection["Mach End"] to machEnd.
    }
    function selectDeltaT {
        // PRIVATE selectDeltaT :: string -> nothing
        parameter       inputString.
        local dT is inputString:toscalar(0).
        if (dT > 1) set dT to 1.
        if (dT < 0.0001) set dT to 0.0001.
        set dTTextfield:text to dT:tostring.
        set parametersCollection["dT"] to dT.
    }
    function buttonCreateNow {
        // PRIVATE buttonCreateNow :: nothing -> nothing
        local startMach is parametersCollection["Mach Start"].
        local endMach is parametersCollection["Mach End"].
        local dT is parametersCollection["dT"].
        hideGui(1).
        showGui(4).
        set dragProfile to dragProfileFunction["getDragProfile"](startMach, endMach, dT, getGui("4-label-2")).
        hideGui(4).
        showGui(5).
    }
    function selectFilename {
        // PRIVATE selectFilename :: string -> nothing
        parameter       inputString.
        if inputString:length > 30 set inputString to shipName:tostring.
        set fileName to inputString.
        set getGui("5-button-2"):text to "Save as "+fileName:tostring+".json".
    }

    function saveToFile {
        // PRIVATE saveToFile :: nothing -> nothing
        set filenameTextfield:confirmed to True. 
        writejson(dragProfile, "dragProfile/DATA/Profiles/"+fileName).
        set getGui("5-label-3"):text to "<color=red><b>Saved as </b></color>"+fileName.
    }

    function buttonFinish {
        // PRIVATE buttonFinish :: nothing -> nothing
        hideGui(5).
        set loopSelection["End"] to True.
    }


    //////////////////////////////////////////
    // MENUS                                //
    //////////////////////////////////////////

    ///// MENU 1 /////
    // Instructions Menu
    mainGUI(1).
    local imageLabel2 is label(1,"1-label-image","",24,"Center").
    set imageLabel2:image to "dragProfile\GUI\Images\image4".
    label(1,"1-label-1",stringCollection["label1"],24,"Center").
    label(1,"1-label-2",stringCollection["label2"],16).
    label(1,"1-label-3",stringCollection["label3"],16).
    label(1,"1-label-7",stringCollection["label5"],16).
    getGui(1):addspacing(20).
    guiBox(1,"1-box-1").
    label("1-box-1", "1-label-4", "Mach Start: ", 14, "LEFT", "Calibri", false, false, 300, 25).
    local machStartTextfield is textfield("1-box-1", "1-textfield-1", "0", {parameter str. selectMachStart(str).}, "", false, false, 100, 25, "Left").
    guiBox(1,"1-box-2").
    label("1-box-2", "1-label-5", "Mach End: ", 14, "LEFT", "Calibri", false, false, 300, 25).
    local machEndTextfield is textfield("1-box-2", "1-textfield-2", "10", {parameter str. selectMachEnd(str).}, "", false, false, 100, 25, "Left").
    guiBox(1,"1-box-3").
    label("1-box-3", "1-label-6", "Delta-T: ", 14, "LEFT", "Calibri", false, false, 300, 25).
    local dTTextfield is textfield("1-box-3", "1-textfield-3", "0.01", {parameter str. selectDeltaT(str).}, "", false, false, 100, 25, "Left").
    getGui(1):addspacing(20).
    guiBox(1,"1-box-4").
    button("1-box-4", "1-button-1", "Review Part List", {hideGUI(1). set labelPartList:text to vesselPartList:tostring. showGUI(2).}, false, false, false, 20, "Calibri", false, false, 200, 25).
    button("1-box-4", "1-button-2", "Review Parameters", {hideGUI(1). set parameterLabel:text to parametersCollection:tostring. showGUI(3).}, false, false, false, 20, "Calibri", false, false, 200, 25).
    button(1, "1-button-3", "Create", {buttonCreateNow().}, false, false, false, 24).

    ///// MENU 2 /////
    // Part List
    mainGUI(2).
    label(2,"2-label-1","<color=#1e3fa4>Part Information</color>",20,"Center").
    guiBox(2, "2-box-1", 400, 400).
    scrollbox("2-box-1", "2-scroll-1").
    local labelPartList is label("2-scroll-1","2-label-2",vesselPartList:tostring,14,"Left").
    getGUI(2):addspacing(20).
    button(2, "2-button-1", "Return", {hideGUI(2). showGUI(1).}).

    ///// MENU 3 /////
    // Parameter List
    mainGUI(3).
    label(3,"3-label-1","<color=#1e3fa4>Parameters Selected</color>",20,"Center").
    guiBox(3, "3-box-1", 400, 200).
    scrollbox("3-box-1", "3-scroll-1").
    local parameterLabel is label("3-scroll-1","3-label-2",parametersCollection:tostring,14,"Left").
    getGUI(3):addspacing(20).
    button(3, "3-button-1", "Return", {hideGUI(3). showGUI(1).}).

    ///// MENU 4 /////
    // Loading Menu
    mainGUI(4).
    label(4,"4-label-1","<color=#1e3fa4>Creating Profile</color>",24,"Center").
    label(4,"4-label-2","Status",20,"Left").

    ///// MENU 5 /////
    // Review Menu
    mainGUI(5).
    local imageLabel1 is label(5,"5-label-image","",24,"Center").
    set imageLabel1:image to "dragProfile\GUI\Images\image3".
    label(5,"5-label-1","<color=#1e3fa4>Results</color>",24,"Center").
    label(5,"5-label-2",stringCollection["label4"],16).
    getGui(5):addspacing(20).
    button(5, "5-button-1", "Review Profile", {hideGUI(5). set profileResultLabel:text to dragProfile:tostring. showGUI(6).}, false, false, false, 20, "Calibri").
    getGui(5):addspacing(20).
    label(5,"5-label-3","Filename: ",16).
    local filenameTextfield is textfield(5, "5-textfield-1", fileName:tostring, {parameter str. selectFilename(str).}, "").
    button(5, "5-button-2", "Save as "+fileName:tostring+".json", {saveToFile().}, false, false, false, 20, "Calibri").
    getGui(5):addspacing(20).
    button(5, "5-button-3", "Finish", {buttonFinish().}, false, false, false, 20, "Calibri").

    ///// MENU 6 /////
    // Profile Review
    mainGUI(6).
    label(6,"6-label-1","<color=#1e3fa4>Drag Profile</color>",20,"Center").
    guiBox(6, "6-box-1", 400, 400).
    scrollbox("6-box-1", "6-scroll-1").
    local profileResultLabel is label("6-scroll-1","6-label-2","Standby",14,"Left").
    getGUI(6):addspacing(20).
    button(6, "6-button-1", "Return", {hideGUI(6). showGUI(5).}).


    //////////////////////////////////////////
    // LOOP AND FINISH                      //
    //////////////////////////////////////////

    // Main Loop
    showGUI(1).
    until loopSelection["End"] {
    }

    ///// Return and End /////
    for object in getCollection():values object:dispose().
    getCollection():clear().

    clearguis(). clearVecDraws(). clearscreen.
    return dragProfile.
}