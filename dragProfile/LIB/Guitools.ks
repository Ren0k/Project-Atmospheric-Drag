//////////////////////////////////////////
// GUI TOOLS                            //
//////////////////////////////////////////
@lazyGlobal off.

// Main Collection of Gui Objects
local guiCollection is lexicon().

//////////////////////
// CONTROL
//////////////////////

function getGui {
    // PUBLIC getGui :: string/int -> guiObject
    parameter       objectName.

    return guiCollection[objectName].
}

function showGUI {
    // PUBLIC showGUI :: string/int -> nothing
    parameter       windowName.
    
    if guiCollection[windowName]:tostring = "GUI" guiCollection[windowName]:show.
    else if guiCollection[windowName]:tostring = "SBOX" guiCollection[windowName]:parent:showonly(guiCollection[windowName]).
    else guiCollection[windowName]:show.
}

function hideGUI {
    // PUBLIC hideGUI :: string/int-> nothing
    parameter       windowName.
    
    guiCollection[windowName]:hide.
}

function editGUI {
    // PUBLIC editGUI :: string/int : string : string -> nothing
    parameter       guiName,
                    command,
                    input.

    if command = "text" set guiCollection[guiName]:text to input.
    else if command = "show" guiCollection[guiName]:show.
    else if command = "hide" guiCollection[guiName]:hide.
}

function getCollection {
    // PUBLIC getCollection :: nothing -> lexicon
    return guiCollection.
}

//////////////////////
// GUI FUNCTIONS
//////////////////////

function mainGUI {
    // PUBLIC mainGUI :: string/int : int : int : int : int : int -> guiObject
    parameter       guiName,
                    spacing is 5,
                    width is 400,
                    height is 0,
                    x is 100,
                    y is 200.

    set guiCollection[guiName] to gui(width, height).
    set guiCollection[guiName]:x to x. 
    set guiCollection[guiName]:y to y.
    guiCollection[guiName]:addspacing(spacing).
    return guiCollection[guiName].
}

function guiBox {
    // PUBLIC guiBox :: string/int : string/int : int : int : string -> guiObject
    parameter       guiName,
                    boxName,
                    width is 0,
                    height is 0,
                    boxType is "HBOX".

    if boxType = "HBOX" set guiCollection[boxName] to guiCollection[guiName]:addhbox().
    else if boxType = "HBOX2" set guiCollection[boxName] to guiCollection[guiName]:addhlayout().
    else if boxType = "VBOX" set guiCollection[boxName] to guiCollection[guiName]:addvbox().
    else if boxType = "VBOX2" set guiCollection[boxName] to guiCollection[guiName]:addvlayout().
    else if boxType = "STACK" set guiCollection[boxName] to guiCollection[guiName]:addstack().
    else set guiCollection[boxName] to guiCollection[guiName]:addhbox().
    if width > 0 set guiCollection[boxName]:style:width to width.
    if height > 0 set guiCollection[boxName]:style:height to height.
    return guiCollection[boxName].
}

function label {
    // PUBLIC label :: string/int : string/int : string : int : string : string : bool : bool : int : int : bool : rgba -> guiObject
    parameter       guiName,
                    labelName,
                    text is "",
                    fontsize is 20,
                    align is "LEFT",
                    font is "Calibri",
                    hstretch is true,
                    vstretch is true,
                    width is 0,
                    height is 0,
                    richtext is true,
                    color is rgba(1,1,1,1).

    set guiCollection[labelName] to guiCollection[guiName]:addlabel(text).
    set guiCollection[labelName]:style:align to align.
    set guiCollection[labelName]:style:hstretch to hstretch.
    set guiCollection[labelName]:style:vstretch to vstretch.
    set guiCollection[labelName]:style:font to font.
    set guiCollection[labelName]:style:fontsize to fontsize.
    set guiCollection[labelName]:style:richtext to richtext.
    set guiCollection[labelName]:style:textcolor to color.
    if width > 0 set guiCollection[labelName]:style:width to width.
    if height > 0 set guiCollection[labelName]:style:height to height.
    return guiCollection[labelName].
}

function button {
    // PUBLIC button :: string/int : string/int : string : kosDelegate : bool : bool : bool : int : string : bool : bool : int : int : string : rgba -> guiObject
    parameter       guiName,
                    buttonName,
                    text is "",
                    argument is standardArgument@,
                    toggle is false,
                    pressed is false,
                    exclusive is false,
                    fontsize is 20,
                    font is "Calibri",
                    hstretch is true,
                    vstretch is true,
                    width is 0,
                    height is 0,
                    tooltip is "",
                    buttoncolor is rgba(1,1,1,1).

    function standardArgument { print("Button pressed."). }

    set guiCollection[buttonName] to guiCollection[guiName]:addbutton(text).
    set guiCollection[buttonName]:style:font to font.
    set guiCollection[buttonName]:style:fontsize to fontsize.
    set guiCollection[buttonName]:style:hstretch to hstretch.
    set guiCollection[buttonName]:style:vstretch to vstretch.
    set guiCollection[buttonName]:tooltip to tooltip.
    if width > 0 set guiCollection[buttonName]:style:width to width.
    if height > 0 set guiCollection[buttonName]:style:height to height.
    set guiCollection[buttonName]:style:font to font.
    set guiCollection[buttonName]:style:textcolor to buttoncolor.
    set guiCollection[buttonName]:toggle to toggle.
    set guiCollection[buttonName]:exclusive to exclusive.
    if toggle { set guiCollection[buttonName]:ontoggle to argument@. set guiCollection[buttonName]:pressed to pressed. }
    else set guiCollection[buttonName]:onclick to argument@.
    return guiCollection[buttonName].
}

function textfield {
    // PUBLIC textfield :: string/int : string/int : string : kosDelegate : string : bool : bool : int : int : string : int : string -> guiObject
    parameter       guiName,
                    textfieldName,
                    textfieldText is "",
                    textfieldArgument is standardArgument@,
                    tooltip is "",
                    hstretch is true,
                    vstretch is true,
                    width is 0,
                    height is 0,
                    align is "Left",
                    fontsize is 20,
                    font is "Calibri".

    function standardArgument {parameter text. print(text).}

    set guiCollection[textfieldName] to guiCollection[guiName]:addtextfield(textfieldText).
    set guiCollection[textfieldName]:style:hstretch to hstretch.
    set guiCollection[textfieldName]:style:vstretch to vstretch.
    if width > 0 set guiCollection[textfieldName]:style:width to width.
    if height > 0 set guiCollection[textfieldName]:style:height to height.
    set guiCollection[textfieldName]:tooltip to tooltip. 
    set guiCollection[textfieldName]:style:align to align.
    set guiCollection[textfieldName]:style:fontsize to fontsize.
    set guiCollection[textfieldName]:style:font to font.
    set guiCollection[textfieldName]:onconfirm to textfieldArgument@.

    return guiCollection[textfieldName].

}

function popup {
    // PUBLIC popup :: string/int : string/int : list : kosDelegate : int : string : string -> guiObject
    parameter   guiName,
                popupName,
                popupList,
                popupArgument,
                maxVisible is 15,
                tooltip is "",
                popupText is "NAME".

    set guiCollection[popupName] to guiCollection[guiName]:addpopupmenu().
    set guiCollection[popupName]:optionsuffix to popupText.
    set guiCollection[popupName]:tooltip to tooltip.
    set guiCollection[popupName]:maxvisible to maxVisible.
    for entry in popupList { guiCollection[popupName]:addoption(entry).}
    set guiCollection[popupName]:onchange to popupArgument@.
    return guiCollection[popupName].
}

function slider {
    // PUBLIC slider :: string/int : string/int : int : int : kosDelegate : string : bool : bool : int : int -> guiObject
    parameter   guiName,
                sliderName,
                minVal,
                maxVal,
                argument,
                type is "HORIZONTAL",
                hstretch is true,
                vstretch is true,
                width is 0,
                height is 0.

        if type =  "HORIZONTAL" set guiCollection[sliderName] to guiCollection[guiName]:addhslider(minVal, minVal, maxVal).
        else if type = "VERTICAL" set guiCollection[sliderName] to guiCollection[guiName]:addvslider(minVal, minVal, maxVal).
        set guiCollection[sliderName]:style:hstretch to hstretch.
        set guiCollection[sliderName]:style:vstretch to vstretch.
        if width > 0 set guiCollection[sliderName]:style:width to width.
        if height > 0 set guiCollection[sliderName]:style:height to height.
        set guiCollection[sliderName]:onchange to argument@. 
        return guiCollection[sliderName].
}

function checkbox {
    // PUBLIC checkbox :: string/int : string/int : string : kosDelegate : bool : bool : bool : int : int : string -> guiObject
    parameter   guiName,
                checkboxName,
                checkboxText,
                argument,
                state is true,
                hstretch is true,
                vstretch is true,
                height is 0,
                width is 0,
                tooltip is "Tooltip".

        set guiCollection[checkboxName] to guiCollection[guiName]:addcheckbox(checkboxText, state).
        set guiCollection[checkboxName]:style:hstretch to hstretch.
        set guiCollection[checkboxName]:style:vstretch to vstretch.
        if height > 0 set guiCollection[checkboxName]:style:height to height.
        if width > 0 set guiCollection[checkboxName]:style:width to width.
        set guiCollection[checkboxName]:tooltip to tooltip.
        set guiCollection[checkboxName]:ontoggle to argument@.
        return guiCollection[checkboxName].
}

function radiobutton {
    // PUBLIC radiobutton :: string/int : string/int : string : kosDelegate : bool -> guiObject
    parameter   guiName,
                radiobuttonName,
                radiobuttonText,
                argument,
                state is false.

        set guiCollection[radiobuttonName] to guiCollection[guiName]:addradiobutton(radiobuttonText, state).
        set guiCollection[guiName]:onradiochange to argument@. 
        return guiCollection[radiobuttonName].
}


function scrollbox {
    // PUBLIC scrollbox :: string/int : string/int : bool : bool : int : int : bool : bool -> guiObject
    parameter   guiName,
                scrollboxName,
                hstretch is true,
                vstretch is true,
                width is 0,
                height is 0,
                valways is false,
                halways is false.

        set guiCollection[scrollboxName] to guiCollection[guiName]:addscrollbox().
        set guiCollection[scrollboxName]:style:hstretch to hstretch.
        set guiCollection[scrollboxName]:style:vstretch to vstretch.
        if width > 0 set guiCollection[scrollboxName]:style:width to width.
        if height > 0 set guiCollection[scrollboxName]:style:height to height.
        set guiCollection[scrollboxName]:valways to valways.
        set guiCollection[scrollboxName]:halways to halways.
        return guiCollection[scrollboxName].
}