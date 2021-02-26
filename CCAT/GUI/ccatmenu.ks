////////////////////////////////////////////////////////
// CCAT Menu                                          //
// By Ren0k                                           //
////////////////////////////////////////////////////////
@lazyGlobal off.

runpath("Library/GUItools.ks").  

function CCATGUI {
    // PUBLIC CCATGUI :: lexicon -> nothing
    parameter       parameterLexicon,
                    variableLexicon,
                    finalPositionLexicon,
                    vectorLexicon,
                    masterManager.

    ///////////////
    // Locations //
    ///////////////

    local locationDatabase is lexicon(
        "KSC Launchpad", {return Kerbin:GEOPOSITIONLATLNG(-0.0972080295142096,-74.5576703035923).},
        "KSC VAB", {return Kerbin:GEOPOSITIONLATLNG(-0.096745829325074,-74.618763742299).},
        "KSC Runway", {return Kerbin:GEOPOSITIONLATLNG(-0.0493288578298832,-74.6175905071407).},
        "Island Runway", {return Kerbin:GEOPOSITIONLATLNG(-1.51732232758978,-71.9001433473269).},
        "Desert Runway", {return Kerbin:GEOPOSITIONLATLNG(-6.51657692967789,-144.039339359303).},
        "Current Geolocation", {return ship:geoposition.}
    ).

    ///////////////
    // Functions //
    ///////////////
    function slider_IPU {
        // PRIVATE slider_IPU :: string : float -> nothing
        parameter sliderName, labelName, Value.

        set getGui(labelName):text to "IPU SELECTED = "+round(Value,0):tostring.
        set config:ipu to round(Value,0).
    }

    function create_Tooltips {
        set getGui("Target-Popup-1"):tooltip to "Change the impact target to a location from this list - updated on next simulation.".
        set getGui("Target-Button-1"):tooltip to "Confirm the selected target - updated on next simulation.".
        set getGui("5-textfield-1"):tooltip to "Change the Delta-T to a new value - updated on next simulation.".
        set getGui("5-button-1"):tooltip to "Confirm the selected Delta-T - updated on next simulation.".
        set getGui("5-popup-1"):tooltip to "Change the Solver to a new solver in this list - updated on next simulation.".
        set getGui("5-button-2"):tooltip to "Confirm the selected Solver - updated on next simulation.".
        set getGui("5-popup-2"):tooltip to "Change how drag is interpolated from a drag profile. Linear is faster, polynomial more precise.".
        set getGui("5-button-5"):tooltip to "Confirm the selected interpolator.".
        set getGui("5-button-3"):tooltip to "The ODE will try to maintain a constant error per step, changing the Delta-T in the process.".
        set getGui("5-button-4"):tooltip to "If after moving through an atmospheric the predicted position is in space, stop the simulation.".
        set getGui("5-button-6"):tooltip to "Update GeoLocation and Time every ODE iteration.".
        set getGui("5-button-7"):tooltip to "Confirm the selected ODE target error.".
    }

    function stopGUI {
        for g in getCollection():values g:dispose().
        set masterManager["UseGUI"] to False. 
        set parameterLexicon["UseGUI"] to "False".
    }

    function stopVDRAW {
        for vd in vectorLexicon:values {
            set vd:show to False.
        }
        for vdn in vectorLexicon:keys {
            vectorLexicon:remove(vdn).
        }
        set masterManager["useGUI"] to False.
    }

    ///////////////
    // Main Menu //
    ///////////////
    mainGUI(1).
    label(1,"1-label-1","<b>CCAT Data Menu</b>",24,"Center").   
    getGui(1):addspacing(20).
    label(1,"1-label-2","<b>Information Display</b>",20,"Center").  
    guiBox(1, "1-hbox-1", 390, 0, "HBOX").
    button("1-hbox-1", "1-button-1", "Parameters", {hideGUI(1). set masterManager["updateVAR"] to True. showGUI(2).}, false, false, false, 16, "Calibri", false, true, 125).
    button("1-hbox-1", "1-button-2", "Variables", {hideGUI(1). set masterManager["updateVAR"] to True. showGUI(3).}, false, false, false, 16, "Calibri", false, true, 125).
    button("1-hbox-1", "1-button-3", "Final Position", {hideGUI(1). set masterManager["updateVAR"] to True. showGUI(4).}, false, false, false, 16, "Calibri", false, true, 125).
    getGui(1):addspacing(30).
    button(1, "1-button-4", "Config", {hideGUI(1). showGUI(5).}).
    button(1, "1-button-5", "Show Vecdraws", {parameter vp. for vd in range(vectorLexicon:values:length) set vectorLexicon[vd]:SHOW to vp. 
    set parameterLexicon["Vecdraws"] to vp:tostring. set masterManager["vectorVis"] to vp.}, true, masterManager["vectorVis"]).
    getGui(1):addspacing(30).
    guiBox(1, "1-hbox-2", 390, 0, "HBOX").
    button("1-hbox-2", "1-button-8", "Hide GUI", {stopGUI().}, false, false, false, 16, "Calibri", false, true, 190).
    button("1-hbox-2", "1-button-9", "<color=red>Stop CCAT</color>", {stopGUI(). stopVDRAW(). set masterManager["MasterSwitch"] to True.}, false, false, false, 16, "Calibri", false, true, 190).

    //////////
    // Submenu 1
    //////////
    mainGUI(2).
    label(2,"2-label-1","Parameters",24,"Center").          
    for i in range(parameterLexicon:length) {
        guiBox(2, ("HBOXPAR"+i):tostring, 390, 0, "HBOX").
        guiBox(("HBOXPAR"+i):tostring, ("VBOXPAR"+i):tostring, 190, 0, "VBOX").
        guiBox(("HBOXPAR"+i):tostring, ("VBOXPAR"+i+i):tostring, 190, 0, "VBOX").
        label(("VBOXPAR"+i):tostring,("labelPAR"+i):tostring, parameterLexicon:keys[i],12,"Left"). 
        label(("VBOXPAR"+i+i):tostring,("labelPAR"+i+"val"):tostring, parameterLexicon:values[i],12,"Left"). 
    }
    button(2, "2-button-1", "Return", {hideGUI(2). set masterManager["updateVAR"] to False. showGUI(1).}).

    //////////
    // Submenu 2
    //////////
    mainGUI(3).
    label(3,"3-label-1","Variables",24,"Center").          
    for i in range(variableLexicon:length) {
        guiBox(3, ("HBOXVAR"+i):tostring, 390, 0, "HBOX").
        guiBox(("HBOXVAR"+i):tostring, ("VBOXVAR"+i):tostring, 190, 0, "VBOX").
        guiBox(("HBOXVAR"+i):tostring, ("VBOXVAR"+i+i):tostring, 190, 0, "VBOX").
        label(("VBOXVAR"+i):tostring,("labelVAR"+i):tostring, variableLexicon:keys[i],12,"Left"). 
        label(("VBOXVAR"+i+i):tostring,("labelVAR"+i+"val"):tostring, variableLexicon:values[i],12,"Left"). 
    }
    button(3, "3-button-1", "Return", {hideGUI(3). set masterManager["updateVAR"] to False. showGUI(1).}).

    //////////
    // Submenu 3
    //////////
    mainGUI(4).
    label(4,"4-label-1","Final Position",24,"Center").          
    for i in range(finalPositionLexicon:length) {
        guiBox(4, ("HBOXFIN"+i):tostring, 390, 0, "HBOX").
        guiBox(("HBOXFIN"+i):tostring, ("VBOXFIN"+i):tostring, 190, 0, "VBOX").
        guiBox(("HBOXFIN"+i):tostring, ("VBOXFIN"+i+i):tostring, 190, 0, "VBOX").
        label(("VBOXFIN"+i):tostring,("labelFIN"+i):tostring, finalPositionLexicon:keys[i],12,"Left"). 
        label(("VBOXFIN"+i+i):tostring,("labelFIN"+i+"val"):tostring, finalPositionLexicon:values[i],12,"Left"). 
    }
    button(4, "4-button-1", "Return", {hideGUI(4). set masterManager["updateVAR"] to False. showGUI(1).}).

    //////////
    // Submenu 4
    //////////
    mainGUI(5).
    label(5,"5-label-1","<color=#1e3fa4>Config</color>",24,"Center").  
    local tooltip5 is getGui(5):addtipdisplay().
    set tooltip5:style:width to 390.
    set tooltip5:style:height to 50.
    // Box 5
    guiBox(5, "Target-Box-1", 390, 0, "HBOX").   
    label("Target-Box-1","Target-Label-1","Select Target",18,"Center").
    guiBox(5, "Target-Box-2", 390, 0, "HBOX").     
    guiBox("Target-Box-2", "Target-Box-3", 190, 0, "VBOX").
    guiBox("Target-Box-2", "Target-Box-4", 190, 0, "VBOX").
    popup("Target-Box-3", "Target-Popup-1", locationDatabase:keys(), {parameter vp.}). 
    button("Target-Box-4", "Target-Button-1", "Change Target", {set masterManager["targetVector"] to locationDatabase[getGui("Target-Popup-1"):text]().}, false, false, false, 14).
    // Box 1  
    guiBox(5, "Label Box 1", 390, 0, "HBOX").      
    label("Label Box 1","5-label-2","Delta-T",18,"Center").      
    guiBox(5, "HBOX Config", 390, 0, "HBOX").
    guiBox("HBOX Config", "VBOX Config 1", 190, 0, "VBOX").
    guiBox("HBOX Config", "VBOX Config 2", 190, 0, "VBOX").
    textfield("VBOX Config 1", "5-textfield-1", masterManager["targetDT"]:tostring, {parameter vp.}).
    button("VBOX Config 2", "5-button-1", "Change Delta-T", {set masterManager["targetDT"] to getGui("5-textfield-1"):text:toscalar(masterManager["targetDT"]).}, false, false, false, 14).
    // Box 2   
    guiBox(5, "Label Box 2", 390, 0, "HBOX").   
    label("Label Box 2","5-label-3","ODE Solver",18,"Center").
    guiBox(5, "HBOX Config 2", 390, 0, "HBOX").     
    guiBox("HBOX Config 2", "VBOX Config 3", 190, 0, "VBOX").
    guiBox("HBOX Config 2", "VBOX Config 4", 190, 0, "VBOX").
    popup("VBOX Config 3", "5-popup-1", list("Euler", "BS3", "RK4", "RKF54", "RKCK54", "RKDP54", "TSIT54", "VERN9"), {parameter vp.}). 
    button("VBOX Config 4", "5-button-2", "Change Solver", {set masterManager["solver"] to getGui("5-popup-1"):text.}, false, false, false, 14).
    // Box 3
    guiBox(5, "Label Box 5", 390, 0, "HBOX").      
    label("Label Box 5","5-label-6","ODE Error",18,"Center").      
    guiBox(5, "HBOX Config 5", 390, 0, "HBOX").
    guiBox("HBOX Config 5", "VBOX Config 9", 190, 0, "VBOX").
    guiBox("HBOX Config 5", "VBOX Config 10", 190, 0, "VBOX").
    textfield("VBOX Config 9", "5-textfield-2", masterManager["targetError"]:tostring, {parameter vp.}).
    button("VBOX Config 10", "5-button-7", "Change Target Error", {set masterManager["targetError"] to getGui("5-textfield-2"):text:toscalar(masterManager["targetError"]).}, false, false, false, 14).
    // Box 4   
    guiBox(5, "Label Box 3", 390, 0, "HBOX").  
    label("Label Box 3","5-label-4","Interpolator",18,"Center").
    guiBox(5, "HBOX Config 4", 390, 0, "HBOX").     
    guiBox("HBOX Config 4", "VBOX Config 7", 190, 0, "VBOX").
    guiBox("HBOX Config 4", "VBOX Config 8", 190, 0, "VBOX").
    popup("VBOX Config 7", "5-popup-2", list("Polynomial", "Linear"), {parameter vp.}). 
    button("VBOX Config 8", "5-button-5", "Change Interpolator", {set masterManager["interpolateMethod"] to getGui("5-popup-2"):text.}, false, false, false, 14).
    // Box 5
    guiBox(5, "Label Box 4", 390, 0, "HBOX").  
    label("Label Box 4","5-label-5","Booleans",18,"Center").
    guiBox(5, "HBOX Config 3", 390, 0, "HBOX"). 
    guiBox("HBOX Config 3", "VBOX Config 5", 190, 0, "VBOX").
    guiBox("HBOX Config 3", "VBOX Config 6", 190, 0, "VBOX").
    button("VBOX Config 5", "5-button-3", "Use Adaptive Stepsize", {parameter ue. set masterManager["useError"] to ue.}, true, masterManager["useError"], false, 14).
    button("VBOX Config 6", "5-button-4", "End Simulation In Orbit", {parameter eo. set masterManager["endInObt"] to eo.}, true, masterManager["endInObt"], false, 14).
    guiBox(5, "HBOX Config 4", 390, 0, "HBOX"). 
    guiBox("HBOX Config 4", "VBOX Config 7", 190, 0, "VBOX").
    guiBox("HBOX Config 4", "VBOX Config 8", 190, 0, "VBOX").
    button("VBOX Config 7", "5-button-6", "Precise Atmo", {parameter ue. set masterManager["exactAtmo"] to ue.}, true, masterManager["exactAtmo"], false, 14).


    label(5,"5-label-ipu","IPU SELECTED = " +config:ipu:tostring,18, "Center").
    local IPUslider is slider(5,"1-slider-1", 50, 2000, {parameter value. slider_IPU("1-slider-1", "5-label-ipu", value).}, "HORIZONTAL", false, false, 390, 15).
    set IPUslider:value to max(config:ipu,400).
    
    getGui(5):addspacing(10).
    button(5, "5-button-return", "Return", {hideGUI(5). showGUI(1).}).
    
    create_Tooltips().
    showGUI(1).

}

function updateCCATGUI {
    // PUBLIC updateCCATGUI :: lexicon -> nothing
    parameter       parameterLexicon,
                    variableLexicon,
                    finalPositionLexicon,
                    updateVAR.

    if updateVAR {
        for i in range(parameterLexicon:length) {
            set getGui(("labelPAR"+i+"val"):tostring):text to parameterLexicon:values[i].
        }
        for i in range(variableLexicon:length) {
            set getGui(("labelVAR"+i+"val"):tostring):text to variableLexicon:values[i].
        }
        for i in range(finalPositionLexicon:length) {
            set getGui(("labelFIN"+i+"val"):tostring):text to finalPositionLexicon:values[i].
        }
    }
}