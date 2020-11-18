//////////////////////////////////////////
// Ship Analysis                        //
// By Ren0k                             //
//////////////////////////////////////////
@lazyGlobal off.

function getVesselAnalysis {
// PUBLIC getVesselAnalysis :: nothing -> lexicon

	function analyzePartDatabase {
		// PUBLIC analyzePartDatabase :: nothing -> json
		// Gets the partdatabase.cfg file and creates a json with the drag cube information per part
		if (not exists("dragProfile/DATA/PartDatabase/PartDatabase.json")) and (exists("dragProfile/DATA/PartDatabase/PartDatabase.cfg")) {
			local partDatabaseRaw is open("dragProfile/DATA/PartDatabase/PartDatabase.cfg"):readall.
			local partDatabaseLexicon is lexicon().
			local partname is "".
			local index is 0.
			for part in partDatabaseRaw {
				if part:contains("url = ") {
					set partname to part:split("/").
					set partname to partname[partname:length-1].
					set partname to partname:replace("_", ".").
					set index to 0.
				}
				if part:contains("cube = ") {
					local partcube is part:split("cube = ")[1].
					set partcube to partcube:split(", ").
					set partDatabaseLexicon[partname+" #" + index + " xp"] to "A: "+partcube[1]:split(",")[0]+" Cd: "+partcube[1]:split(",")[1].
					set partDatabaseLexicon[partname+" #" + index + " xn"] to "A: "+partcube[2]:split(",")[0]+" Cd: "+partcube[2]:split(",")[1].
					set partDatabaseLexicon[partname+" #" + index + " yp"] to "A: "+partcube[3]:split(",")[0]+" Cd: "+partcube[3]:split(",")[1].
					set partDatabaseLexicon[partname+" #" + index + " yn"] to "A: "+partcube[4]:split(",")[0]+" Cd: "+partcube[4]:split(",")[1].
					set partDatabaseLexicon[partname+" #" + index + " zp"] to "A: "+partcube[5]:split(",")[0]+" Cd: "+partcube[5]:split(",")[1].
					set partDatabaseLexicon[partname+" #" + index + " zn"] to "A: "+partcube[6]:split(",")[0]+" Cd: "+partcube[6]:split(",")[1].
					set index to index + 1.
				}
			}
			writejson(partDatabaseLexicon, "dragProfile/DATA/PartDatabase/PartDatabase.json"). } 
	}

	function rescanPartDatabase {
		// PUBLIC rescanPartDatabase :: nothing -> json
		// Skips checking for an existing JSON
		// Gets the partdatabase.cfg file and creates a json with the drag cube information per part
		if (exists("dragProfile/DATA/PartDatabase/PartDatabase.cfg")) {
			local partDatabaseRaw is open("dragProfile/DATA/PartDatabase/PartDatabase.cfg"):readall.
			local partDatabaseLexicon is lexicon().
			local partname is "".
			local index is 0.
			for part in partDatabaseRaw {
				if part:contains("url = ") {
					set partname to part:split("/").
					set partname to partname[partname:length-1].
					set partname to partname:replace("_", ".").
					set index to 0.
				}
				if part:contains("cube = ") {
					local partcube is part:split("cube = ")[1].
					set partcube to partcube:split(", ").
					set partDatabaseLexicon[partname+" #" + index + " xp"] to "A: "+partcube[1]:split(",")[0]+" Cd: "+partcube[1]:split(",")[1].
					set partDatabaseLexicon[partname+" #" + index + " xn"] to "A: "+partcube[2]:split(",")[0]+" Cd: "+partcube[2]:split(",")[1].
					set partDatabaseLexicon[partname+" #" + index + " yp"] to "A: "+partcube[3]:split(",")[0]+" Cd: "+partcube[3]:split(",")[1].
					set partDatabaseLexicon[partname+" #" + index + " yn"] to "A: "+partcube[4]:split(",")[0]+" Cd: "+partcube[4]:split(",")[1].
					set partDatabaseLexicon[partname+" #" + index + " zp"] to "A: "+partcube[5]:split(",")[0]+" Cd: "+partcube[5]:split(",")[1].
					set partDatabaseLexicon[partname+" #" + index + " zn"] to "A: "+partcube[6]:split(",")[0]+" Cd: "+partcube[6]:split(",")[1].
					set partDatabaseLexicon[partname+" NrCubes"] to index.
					set index to index + 1.
				}
			}
			writejson(partDatabaseLexicon, "dragProfile/DATA/PartDatabase/PartDatabase.json"). } 
	}

	function analyzeCraftFile {
		// PRIVATE analyzeCraftFile :: labelObject : string -> 2D Associative Array
		// Gets the .craft file of the vessel and create a lexicon of part lexicons with attachments and some additional information
		parameter       statusLabel,
						craftName is (ship:name+".craft").

		local craftInfoLexicon is lexicon().

		///// HELPER FUNCTIONS /////
		function getNumbersFromString {
			// PRIVATE getNumbersFromString :: string -> int
			// Function to find the numbers in a string
			parameter       Str.
			local number is "".
			for letter in Str {
				if letter:matchespattern("\d+") set number to number+letter.
			}
			return number:toscalar().
		}

		function changeNodeName {
			// PRIVATE changeNodeName :: string -> string
			// This function changes the name of the occupied node to the corresponding dragcube
			parameter		nodeName.

			local rawNodeName is nodeName.
			if nodeName:contains("top") set nodeName to "YP".
			else if nodeName:contains("bottom") set nodeName to "YN".
			else if nodeName:contains("right") set nodeName to "XP".
			else if nodeName:contains("left") set nodeName to "XN".
			else if nodeName:contains("back") set nodeName to "ZP".
			else if nodeName:contains("front") set nodeName to "ZN".
			else if nodeName:contains("direct") set nodeName to "YN0Direct".
			else if nodeName:contains("interstage") set nodeName to "Fairing".
			else set nodeName to "Special".
			// Check for a regex pattern to identify numbers; i.e. parts with multiple facing nodes
			if (rawNodeName:matchespattern("\d+")) {
				local nodeNumber is getNumbersFromString(rawNodeName).
				set nodeName to nodeName+"0"+nodeNumber:tostring.
			}
			return nodeName.
		}

		///// MAIN EXECUTION /////
		// Now we are going to scan through the .Craft file and get the information we want
		if exists("dragProfile/DATA/Vessels/"+craftName) {
			local craftFileRaw is open("dragProfile/DATA/Vessels/"+craftName):readall.
			local index is 0.
			local partSelected is "".
			local specialCheck is False.
			for line in craftFileRaw {
				set index to index+1.
				if statusLabel <> "" set statusLabel:text to "Analyzing Craft File - Line: "+index:tostring.
				if line:contains("part = ") {
					set partSelected to line:split("part = ")[1].
					if partSelected:contains("_") set partSelected to partSelected:replace("_", " ").
					local singlePartLexicon is lexicon().
					set craftInfoLexicon[partSelected] to singlePartLexicon.
				}
				if line:contains("attN") {
					local nodeSection is line.
					set nodeSection to nodeSection:split("attN = ")[1].
					local attachedPart is nodeSection:split(",")[1]:split("_").
					set attachedPart to attachedPart[0]+" " + attachedPart[1].
					if attachedPart:contains("Null") set attachedPart to "Null".
					set nodeSection to nodeSection:split(",")[0].
					set nodeSection to changeNodeName(nodeSection).
					set craftInfoLexicon[partSelected]["node " + nodeSection] to attachedPart.
				}
				if line:contains("isJettisoned") {
					// This variable is used to check for shrouds; shrouds change the dragcube used
					set craftInfoLexicon[partSelected]["Shroud Removed"] to line:split(" = ")[1].
				}
				if line:contains("CModuleStrut") {
					// Variable used to check if the part is a strut
					set craftInfoLexicon[partSelected]["Strut"] to True.
				}
				if line:contains("ModulePartVariants") {
					// Variable used to check for part variants
					set craftInfoLexicon[partSelected]["ModulePartVariants"] to "True".
					// This determines the 'order' of drag cubes used
					//  the order of the modules (ModuleJettison / ModulePartVariants) determine the order of dragcubes
					if not craftInfoLexicon[partSelected]:haskey("Shroud Removed") set craftInfoLexicon[partSelected]["ModulePartVariants"] to "Reversed".
				}
				if line:contains("selectedVariant = ") {
					// Indicated if a variant is used, and the name of that variant
					set craftInfoLexicon[partSelected]["selectedVariant"] to line:split(" = ")[1].
				}
				if line:contains("XSECTION") {
					// Variable used to check if a fairing section is coming up
					set specialCheck to True.
				}
				if line:contains("h = ") and specialCheck {
					// Get the fairing stage height
					if craftInfoLexicon[partSelected]:haskey("fairingHeight") {
						set craftInfoLexicon[partSelected]["fairingHeight"] to (
							craftInfoLexicon[partSelected]["fairingHeight"] + line:split(" = ")[1]:toscalar(0)).
					}
					else set craftInfoLexicon[partSelected]["fairingHeight"] to line:split(" = ")[1]:toscalar(0).
				}
				if line:contains("r = ") and specialCheck {
					// Get the fairing stage radius
					set specialCheck to False.
					if craftInfoLexicon[partSelected]:haskey("fairingCd") {
						set craftInfoLexicon[partSelected]["fairingCd"] to (
							craftInfoLexicon[partSelected]["fairingCd"] + line:split(" = ")[1]:toscalar(0)).
					}
					else set craftInfoLexicon[partSelected]["fairingCd"] to line:split(" = ")[1]:toscalar(0).
				}
			}
		} else {
			print("ERROR! No .Craft file found!").
		}
		return craftInfoLexicon.
	}

	function getVesselPartList {
		// PRIVATE getVesselPartList :: 2D Associative Array : lexicon : labelObject -> 2D Associative Array
		// Returns a lexicon of part-lexicons containing useful part info
		parameter		craftInfo,
						parameterCollection,
						statusLabel.

		// Creation of initial lists and lexicons
		local partlist is list().
		list parts in  partlist.
		local vesselPartInformation is lexicon().
		// Collections of specific part info from the ExtraDatabase file
		local liftCoeffCollection is getDeflectionLiftCoeff().
		local capsuleBottomList is getCapsuleBottomList().
		local dragModifierList is getDragModifierList().
		// Determining prograde or retrograde flight, and correcting for custom AoA's with the var flightOrientation
		local flightOrientation is ship:facing:forevector.
		///// STEP 1 /////
		// Creating the full partlist
		for part in partlist {
			if statusLabel <> "" set statusLabel:text to "Creating Part List - Part: "+part:tostring.
			local singlePartInformation is lexicon().
			local partName is part:tostring.
			set flightOrientation to ship:facing:forevector.
			if parameterCollection["Profile"] = "Retrograde" set flightOrientation to -ship:facing:forevector.
			if parameterCollection["Custom AoA"] <> 0 set flightOrientation to lib_VesselOrientation["rotateQuaternion"](flightOrientation, parameterCollection["Custom AoA"]*-1, 0 ,0).
			if parameterCollection["Custom AoA Yaw"] <> 0 set flightOrientation to lib_VesselOrientation["rotateQuaternion"](flightOrientation, 0, parameterCollection["Custom AoA Yaw"]*-1, 0).
			set partName to partName:replace("PART(", "").
			set partName to partName:split(",")[0].
			if partName:contains("(") set partName to partName:split("(")[0].
			set partName to partName:replace(" ", "").
			set singlePartInformation["partname"] to partName.
			set singlePartInformation["cid"] to part:cid.
			set singlePartInformation["uid"] to part:uid.
			set singlePartInformation["object"] to part.
			set singlePartInformation["vdotX"] to max(min(round(vdot(part:facing:starvector,flightOrientation),14),1),-1).
			set singlePartInformation["vdotY"] to max(min(round(vdot(part:facing:forevector,flightOrientation),14),1),-1).
			set singlePartInformation["vdotZ"] to max(min(round(vdot(-part:facing:topvector,flightOrientation),14),1),-1).
			set singlePartInformation["Offset"] to round(vang(part:facing:forevector, flightOrientation),5).
			set singlePartInformation["stage"] to part:stage.
			set singlePartInformation["mass"] to part:mass*1000.
			set singlePartInformation["type"] to "Body".
			set singlePartInformation["Excluded"] to "False".
			// Checking for special parts
			if liftCoeffCollection:haskey(partName) set singlePartInformation["deflectionLiftCoeff"] to liftCoeffCollection[partName].
			if capsuleBottomList:haskey(partName) set singlePartInformation["type"] to "CapsuleLift".

			///// STEP 2 /////
			// Getting part types and states for the different types of parts
			for module in part:modules {
				if module:tostring:contains("ModuleDragModifier") {
					set singlePartInformation["ModuleDragModifier"] to True.
				}
				if module:tostring:contains("ModuleAeroSurface") {
					set singlePartInformation["ModuleAeroSurface"] to True.
					set singlePartInformation["type"] to "Airbrake".
					set singlePartInformation["deploy angle"] to part:getmodule("ModuleAeroSurface"):getfield("deploy angle").
					set singlePartInformation["Extended"] to part:getmodule("ModuleAeroSurface"):getfield("deploy"):tostring.
					if not singlePartInformation:haskey("deflectionLiftCoeff") set singlePartInformation["deflectionLiftCoeff"] to 0.38.
					if not parameterCollection["Scan"] {
						if parameterCollection["Airbrakes"] = "Retracted" set singlePartInformation["Extended"] to "False".
						else set singlePartInformation["Extended"] to "True".
					}
				} 
				if module:tostring:contains("ModuleLiftingSurface") {
					set singlePartInformation["ModuleLiftingSurface"] to True.
					set singlePartInformation["type"] to "Bodylift".
					for field in part:getmodule("ModuleLiftingSurface"):allfields {
						if field:tostring:contains("drag") {
							set singlePartInformation["type"] to "Wing".
							if not singlePartInformation:haskey("deflectionLiftCoeff") set singlePartInformation["deflectionLiftCoeff"] to round((part:drymass * 10),3).
						}
					} 
					if not singlePartInformation:haskey("deflectionLiftCoeff") set singlePartInformation["deflectionLiftCoeff"] to round((part:wetmass / 5),3).
				}
				if module:tostring:contains("ModuleControlSurface") {
					set singlePartInformation["ModuleControlSurface"] to True.
					set singlePartInformation["type"] to "AeroSurface".
					set singlePartInformation["Extended"] to part:getmodule("ModuleControlSurface"):getfield("deploy"):tostring.
					if not singlePartInformation:haskey("deflectionLiftCoeff") set singlePartInformation["deflectionLiftCoeff"] to round((part:mass * 4.5),3).
					set singlePartInformation["deploy angle"] to part:getmodule("ModuleControlSurface"):getfield("deploy angle").
					if not parameterCollection["Scan"] {
						if parameterCollection["AeroSurfaces"] = "Retracted" set singlePartInformation["Extended"] to "False".
						else set singlePartInformation["Extended"] to "True".
					}
				}
				if module:tostring:contains("ModuleAnimateGeneric") {
					set singlePartInformation["ModuleAnimateGeneric"] to True.
					local aniModule is part:getmodule("ModuleAnimateGeneric").
					for field in aniModule:allevents {
						if field:tostring:contains("open shield") set singlePartInformation["Open"] to "True".
						else if field:tostring:contains("open") set singlePartInformation["Open"] to "False".
						else if field:tostring:contains("close") set singlePartInformation["Open"] to "True".
					}
				}
				if module:tostring:contains("ModuleWheelDeployment") {
					set singlePartInformation["ModuleWheelDeployment"] to True.
					local newMod is part:getmodule("ModuleWheelDeployment").
					for field in newMod:allevents {
						if field:tostring:contains("retract") set singlePartInformation["Extended"] to "True".
						else if field:tostring:contains("extend") set singlePartInformation["Extended"] to "False".
					}
					if not parameterCollection["Scan"] {
						if parameterCollection["Gears"] = "Up" set singlePartInformation["Extended"] to "False".
						else set singlePartInformation["Extended"] to "True".
					}
					if dragModifierList:haskey(partName) {
						set singlePartInformation["Dragmodifier Deployed"] to dragModifierList[partName]["Deployed"].
						set singlePartInformation["Dragmodifier Retracted"] to dragModifierList[partName]["Retracted"].
					} else if singlePartInformation:haskey("ModuleDragModifier") and singlePartInformation["ModuleDragModifier"]  {
						set singlePartInformation["Dragmodifier Deployed"] to 2.
						set singlePartInformation["Dragmodifier Retracted"] to 0.5.					
					}
				}
				if module:tostring:contains("RetractableLadder") {
					set singlePartInformation["RetractableLadder"] to True.
					local newMod is part:getmodule("RetractableLadder").
					for field in newMod:allevents {
						if field:tostring:contains("retract") set singlePartInformation["Ladder Extended"] to "True".
						else if field:tostring:contains("extend") set singlePartInformation["Ladder Extended"] to "False".
					}
				}
				if module:tostring:contains("ModuleCommand") {
					set singlePartInformation["ModuleCommand"] to True.
				}
				if module:tostring:contains("ModuleCargoBay") {
					set singlePartInformation["ModuleCargoBay"] to True.
				}
				if module:tostring:contains("ModuleProceduralFairing") {
					set singlePartInformation["ModuleProceduralFairing"] to True.
					set parameterCollection["Special Parts"] to "True".
				}
				if module:tostring:contains("ModuleDeployableAntenna") {
					set singlePartInformation["ModuleDeployableAntenna"] to True.
					local newMod is part:getmodule("ModuleDeployableAntenna").
					if newMod:hasevent("extend antenna") set singlePartInformation["Open"] to "False".
					else set singlePartInformation["Open"] to "True".
				}
				if module:tostring:contains("ModuleParachute") {
					set singlePartInformation["ModuleParachute"] to True.
					local newMod is part:getmodule("ModuleParachute").
					if newMod:hasevent("deploy chute") set singlePartInformation["Parachute Deployed"] to "Idle".
					else set singlePartInformation["Parachute Deployed"] to "Deployed".
					if dragModifierList:haskey(partName) {
						set singlePartInformation["Dragmodifier Chute Semideployed"] to dragModifierList[partName]["Semideployed"].
						set singlePartInformation["Dragmodifier Chute Deployed"] to dragModifierList[partName]["Deployed"].
					} else if singlePartInformation:haskey("ModuleDragModifier") and singlePartInformation["ModuleDragModifier"]  {
						set singlePartInformation["Dragmodifier Chute Semideployed"] to 1.
						set singlePartInformation["Dragmodifier Chute Deployed"] to 10.					
					}
					if not parameterCollection["Scan"] {
						if parameterCollection["Parachutes"] = "Idle" set singlePartInformation["Parachute Deployed"] to "Idle".
						else if parameterCollection["Parachutes"] = "Semideployed" set singlePartInformation["Parachute Deployed"] to "Semideployed".
						else set singlePartInformation["Parachute Deployed"] to "Deployed".
					}
				}
			}
			set vesselPartInformation[partname+" "+part:cid] to singlePartInformation.
		}
		///// STEP 3 /////
		///// Merging with Craft Info
		for part in craftInfo:keys {
			for entry in craftInfo[part]:keys {
				set vesselPartInformation[part][entry] to craftInfo[part][entry].
			}
		}	
		return vesselPartInformation.
	}

	function addDragCubes {
		// PRIVATE addDragCubes :: 2D Associative Array -> 2D Associative Array
		parameter		partlist.

		// Returns the same lexicon as in 'getVesselPartList' but with uncorrected drag cube information added from 'analyzeCraftFile'
		local partDatabaseJson is readjson("dragProfile/DATA/PartDatabase/PartDatabase.json").
		local partVariantList is getPartVariantList().
		///// Helper Functions /////
		// With this function we are going to decide what dragcube we are going to include
		function checkExtensionState {
			// PRIVATE checkExtensionState :: lexicon -> string
			parameter		selectedPart.
			local extensionState is " #0".
			if selectedPart:haskey("Shroud Removed") {
				// ENGINE PART
				if selectedPart["Shroud Removed"]:contains("True") {
					// IF NO SHROUD is fitted
					if selectedPart:haskey("ModulePartVariants") {
						// IF there are multiple variants
						if selectedPart["ModulePartVariants"]:contains("Reversed") {
							// Reversed: The last 2 dragcubes are the fairing/no-fairing cubes
							if selectedPart:haskey("selectedVariant") set extensionState to " #1".
							// IF this key is available, the extensionState is at least 1
							// IF no key were available, it would be 0
							else set extensionState to " #0".
						}
						else {
							// NOT Reversed: The first 2 dragcubes are the fairing/no-fairing cubes
							if selectedPart:haskey("selectedVariant") set extensionState to " #3".
							// IF this key is available, it will be the 2nd of the variant ones
							// Meaning: 2 (For fairing/non-fairing) + 2 = 3 (-1 for 0 entry)
							else set extensionState to " #2".
							// Otherwise it will be 1 higher than the first 2 for the fairings = 2
						}
					}
					else set extensionState to " #1".
				} else {
					// Meaning that it does have a SHROUD fitted
					if selectedPart:haskey("ModulePartVariants") {
						// IF it is Reversed, it means that the last 2 dragcubes are the fairing/no-fairing ones
						if selectedPart["ModulePartVariants"]:contains("Reversed") set extensionState to (" #"+(selectedPart["NrCubes"]-1):tostring).
						else set extensionState to " #0".
					}
					else set extensionState to " #0".
				}
			}	
			if selectedPart:haskey("ModulePartVariants") {
				// IF the part has this module
				if (selectedPart:haskey("Shroud Removed")) {
					// IF the part is an engine, as indicated by the Shroud Removed key
					if partVariantList:haskey(selectedPart["partname"]) and (selectedPart["Shroud Removed"]:contains("True")) {
						// IF the engine is in the variantList and it has NO shroud
						if selectedPart:haskey("selectedVariant") {
							local variantName is selectedPart["selectedVariant"].
							if partVariantList[selectedPart["partname"]]:haskey(variantName) {
								// IF the variant name is in the variant list
								local extensionNumber is partVariantList[selectedPart["partname"]][variantName].
								set extensionState to " #"+extensionNumber:tostring.
							}
						}
					}
				} else {
					// IF the part is NOT an engine
					if partVariantList:haskey(selectedPart["partname"]) {
						// IF the part is in the variantList
						if selectedPart:haskey("selectedVariant") {
							local variantName is selectedPart["selectedVariant"].
							if partVariantList[selectedPart["partname"]]:haskey(variantName) {
								// IF the variant name is in the variant list
								local extensionNumber is partVariantList[selectedPart["partname"]][variantName].
								set extensionState to " #"+extensionNumber:tostring.
							}
						}
					}
				}
			}
			if selectedPart:haskey("Open") {
				if selectedPart["Open"]:contains("True") set extensionState to " #1".
			}
			if selectedPart:haskey("Extended") {
				if selectedPart["Extended"]:contains("False") set extensionState to " #1".
			}		
			if selectedPart:haskey("Ladder Extended") {
				if selectedPart["Ladder Extended"]:contains("True") set extensionState to " #1".
			}		
			if selectedPart:haskey("Parachute Deployed") {
				if selectedPart["Parachute Deployed"] = "Idle" set extensionState to " #0".
				else if selectedPart["Parachute Deployed"] = "Semideployed" set extensionState to " #1".
				else if selectedPart["Parachute Deployed"] = "Deployed" set extensionState to " #2".
			}	
			set selectedPart["Extension State"] to extensionState.
			return extensionState.
		}

		///// Dragcube Selection /////
		for part in partlist:keys {
			local partInfo is partlist[part].
			set partInfo["NrCubes"] to partDatabaseJson[part:split(" ")[0]+" NrCubes"].
			local extensionState is checkExtensionState(partInfo).
			set partlist[part]["XP Default"] to partDatabaseJson[part:split(" ")[0]+extensionState+" xp"].
			set partlist[part]["XN Default"] to partDatabaseJson[part:split(" ")[0]+extensionState+" xn"].
			set partlist[part]["YP Default"] to partDatabaseJson[part:split(" ")[0]+extensionState+" yp"].
			set partlist[part]["YN Default"] to partDatabaseJson[part:split(" ")[0]+extensionState+" yn"].
			set partlist[part]["ZP Default"] to partDatabaseJson[part:split(" ")[0]+extensionState+" zp"].
			set partlist[part]["ZN Default"] to partDatabaseJson[part:split(" ")[0]+extensionState+" zn"].
			// Guesstimating Procedural Fairing Dragcubes
			if partlist[part]:haskey("ModuleProceduralFairing") {
				for entry in partlist[part]:keys {
					if partlist[part][entry]:tostring:contains("Cd: ") {
						local acdValue is partlist[part][entry].
						local aValue is acdValue:split("Cd:")[0]:split("A: ")[1]:toscalar().
						local cdValue is acdValue:split("Cd:")[1]:toscalar().	
						local totalAValue is partlist[part]["fairingHeight"].
						local totalCdValue is partlist[part]["fairingCd"].
						if entry:contains("YP Default") {
							set cdValue to (totalCdValue/totalAValue)*0.7.
						}
						else if entry:contains("YN Default") donothing.
						else set aValue to aValue+totalAValue.
						local newEntry is "A: "+aValue+" Cd: "+cdValue.	
						set partlist[part][entry] to newEntry.		
					}
				}
			}
		}
		return partList.
	}

	function analyzeNodes {
		// PRIVATE analyzeNodes :: 2D Associative Array  : labelObject -> 2D Associative Array
		parameter		partList,
						statusLabel.	

		local newPartList is lexicon().						// Making a copy of the partlist, so we can edit it safely; see below
		local attachedPartList is lexicon().				// Creating a list of parts the have nodes; see below
		///// STEP 1 /////
		// Here we make a copy of each individual part lexicon, and put it in the newPartList.
		// We leave struts out as they dont have drag applied
		// Additionally, while iterating over the values we create the attachedPartList; a lexicon of the nodes and what part occupies them
		if statusLabel <> "" set statusLabel:text to "Analyzing Nodes - Copying Partlist".
		for part in partList:keys {
			if not (partList[part]:haskey("Strut")) {
				set newPartList[part] to partList[part]:copy.
				for key in partlist[part]:keys {
					if key:contains("node") set attachedPartList[part+" "+key] to partlist[part][key].
				}
			}
		}
		///// STEP 2 /////
		// Now, we are going to further modify the attachedPartList, by also specifying what nodes are occupied on the attached part i.e. the value of each key
		if statusLabel<> "" set statusLabel:text to "Analyzing Nodes - Checking for attached parts".
		for part in attachedPartList:keys {
			local partName is part:split(" node ")[0].
			local attachedPart is attachedPartList[part].
			for partToFind in attachedPartList:keys {
				if (partToFind:contains(attachedPart)) and (attachedPartList[partToFind]:contains(partName)) {
					local attachedPartNode is partToFind:split(" node ")[1].
					set attachedPartList[part] to (attachedPartList[part]+" node "+attachedPartNode).
			}	}	}
		///// STEP 3 /////
		// Now we have a list of all parts with nodes, and what parts occupy those nodes. We can now correct the dragcube values for occupied nodes.
		for part in attachedPartList:keys {
			// Selection of root part values
			if statusLabel <> "" set statusLabel:text to "Analyzing Nodes - Part: " + part:tostring.
			local rootPart is part:split(" node ")[0]. 
			local rootPartInfo is newPartList[rootPart].
			local rootNode is part:split(" node ")[1]. 
			if rootNode:contains("0") set rootNode to rootNode:split("0")[0].
			local rootCdValue is 0.
			local rootAValue is 0.
			// Selection of attached part values
			local attachedPart is attachedPartList[part]. 
			if not (attachedPart = "Null") {
				local attachedPartInfo is partList[attachedPart:split(" node ")[0]].
				local attachedNode is attachedPart:split(" node ")[1]. 
				if attachedNode:contains("0") set attachedNode to attachedNode:split("0")[0].
				local attachedAValue is 0.
				// Finding the rootPart Cd/A values
				for rootPartKey in rootPartInfo:keys {
					if rootPartKey:contains(rootNode) and (rootPartKey:contains("Default")) {
						local dragCubeValue is rootPartInfo[rootPartKey].
						set dragCubeValue to dragCubeValue:split(" Cd: ").
						set rootAValue to dragCubeValue[0]:split("A: ")[1]:toscalar().
						set rootCdValue to dragCubeValue[1]:toscalar().
				}	}
				// Finding the attachedPart Cd/A values
				for attachedPartKey in attachedPartInfo:keys {
					if attachedPartKey:contains(attachedNode) and (attachedPartKey:contains("Default")) {
						local dragCubeValue is attachedPartInfo[attachedPartKey].
						set dragCubeValue to dragCubeValue:split(" Cd: ").
						set attachedAValue to dragCubeValue[0]:split("A: ")[1]:toscalar().
				}	}
				// Now we are going to calculate the new Cd/A Values of the root part node
				// New Area: nA = (rA-aA)
				// New Cd: nCd = ((rCd*rA)-aA)/nA
				local newRootAValue is round(max(rootAValue-attachedAValue,0),14).
				local newRootCdValue is 1.
				if (newRootAValue = 0) set newRootCdValue to 0.
				else set newRootCdValue to round(max(((rootCdValue*rootAValue)-attachedAValue)/newRootAValue,0),14).
				local newDragCubeEntry is "A: "+newRootAValue+" Cd: "+newRootCdValue.
				set newPartList[rootPart][rootNode+" Default"] to newDragCubeEntry.
			}
		}
		///// STEP 4 /////
		// Returning the newlist
		return newPartList.
	}

	function executeAnalysis {
		// PUBLIC executeAnalysis :: lexicon : labelObject -> 2D Associative Array
		parameter		parametersCollection,
						statusLabel is "".

		///// STEP 1 /////
		// PartDatabase Analysis
		if statusLabel <> "" set statusLabel:text to "Analyzing Part Database".
		analyzePartDatabase().
		///// STEP 2 /////
		// .CraftFile Analysis
		if statusLabel <> "" set statusLabel:text to "Analyzing Craft File".
		local craftFile is analyzeCraftFile(statusLabel).
		///// STEP 3 /////
		// PartList Creation; inputting the created craftFile
		if statusLabel <> "" set statusLabel:text to "Creating Part List".
		local craftPartList is getVesselPartList(craftFile, parametersCollection, statusLabel).
		///// STEP 4 /////
		// Adding dragcube information
		if statusLabel <> "" set statusLabel:text to "Adding Drag Cubes".
		set craftPartList to addDragCubes(craftPartList).
		///// STEP 5 /////
		// Node Analysis and Modifications
		if statusLabel <> "" set statusLabel:text to "Analyzing Nodes".
		set craftPartList to analyzeNodes(craftPartList, statusLabel).

		return craftPartList.
	}

	return lexicon(
		"rescanPartDatabase", rescanPartDatabase@,
		"executeAnalysis", executeAnalysis@
	).
}

global lib_getVesselAnalysis is getVesselAnalysis().