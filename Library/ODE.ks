/////////////////////////////////////////////
// Ordinary Differential Equation Solvers  //
// By Ren0k                                //
/////////////////////////////////////////////
@lazyGlobal off.

function ODEsolver {
    // PUBLIC ODEsolver :: nothing -> lexicon
    // Returns an ODE Solver Function

    function Euler {
        // PUBLIC Euler :: nothing -> function
        // 1st Order Euler Method
        local bt is lexicon(
            "a1", 0, 
            "b11", 0,
            "c1", 1
        ).

        return {
            // PUBLIC FUNCTION :: function : list : float -> lexicon
            parameter       FX,
                            values,
                            dt.
            
            local numVars is values:length.
            local initValues is lexicon().
            local endValues is lexicon().
            local iterDT is 0.

            for i in range(numVars) {
                set initValues[i] to values[i].
            }

            local K1 is FX(values, iterDT).

            for i in range(numVars) {
                set endValues[i] to initValues[i] + (   bt["c1"] * K1[i]) * dt.
            }

            set endValues[numVars] to K1[0].
            return endValues.
        }.
    }

    function BS3 {
        // PUBLIC BS3 :: nothing -> function
        // Bogacki–Shampine 3rd Order Solver with adaptive step size
        local bt is lexicon(
            "a1", 0, "a2", 0.5, "a3", 0.75, "a4", 1,
            "b21", 0.5, "b32", 0.75,
            "b41", 2/9, "b42", 1/3, "b43", 4/9,
            "c1", 2/9, "c2", 1/3, "c3", 4/9, "c4", 0,
            "dc1", 7/24, "dc2", 1/4, "dc3", 1/3, "dc4", 1/8
        ).

        return {
            // PUBLIC FUNCTION :: function : list : float -> lexicon
            parameter       FX,
                            values,
                            dt.
            
            local numVars is values:length.
            local initValues is lexicon().
            local midPoint is lexicon().
            local endValues is lexicon().
            local altEndValues is lexicon().
            local error is 0.
            local iterDT is 0.

            for i in range(numVars) {
                set initValues[i] to values[i].
            }

            local K1 is FX(values, iterDT).
            set iterDT to bt["a2"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b21"] * K1[i]) * iterDT.
            }
            local K2 is FX(midPoint, iterDT).
            set iterDT to bt["a3"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b32"] * K2[i]) * iterDT.
            }
            local K3 is FX(midPoint, iterDT).
            set iterDT to bt["a4"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b41"] * K1[i] +
                                                    bt["b42"] * K2[i] +
                                                    bt["b43"] * K3[i]) * iterDT.
            }
            local K4 is FX(midPoint, iterDT).

            for i in range(numVars) {
                set endValues[i] to initValues[i] + (   bt["c1"] * K1[i] +
                                                        bt["c2"] * K2[i] +
                                                        bt["c3"] * K3[i] +
                                                        bt["c4"] * K4[i]) * dt.
                set altEndValues[i] to initValues[i] + (bt["dc1"] * K1[i] +
                                                        bt["dc2"] * K2[i] +
                                                        bt["dc3"] * K3[i] +
                                                        bt["dc4"] * K4[i]) * dt.     

                set error to error + (endValues[i]-altEndValues[i]):mag.  
            }

            set endValues[numVars] to K4[0].
            set endValues["Error"] to error.

            return endValues.
        }.
    }

    function RK4 {
        // PUBLIC RK4 :: nothing -> function
        // Classic 4th Order Runge Kutta Solver Method
        local bt is lexicon(
            "a1", 0, "a2", 0.5, "a3", 0.5, "a4", 1,
            "b21", 0.5, "b32", 0.5,
            "b43", 1,
            "c1", 1/6, "c2", 1/3, "c3", 1/3, "c4", 1/6
        ).

        return {
            // PUBLIC FUNCTION :: function : list : float -> lexicon
            parameter       FX,
                            values,
                            dt.
            
            local numVars is values:length.
            local initValues is lexicon().
            local midPoint is lexicon().
            local endValues is lexicon().
            local iterDT is 0.

            for i in range(numVars) {
                set initValues[i] to values[i].
            }

            local K1 is FX(values, iterDT).
            set iterDT to bt["a2"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b21"] * K1[i]) * iterDT.
            }
            local K2 is FX(midPoint, iterDT).
            set iterDT to bt["a3"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b32"] * K2[i]) * iterDT.
            }
            local K3 is FX(midPoint, iterDT).
            set iterDT to bt["a4"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b43"] * K3[i]) * iterDT.
            }
            local K4 is FX(midPoint, iterDT).

            for i in range(numVars) {
                set endValues[i] to initValues[i] + (   bt["c1"] * K1[i] +
                                                        bt["c2"] * K2[i] +
                                                        bt["c3"] * K3[i] +
                                                        bt["c4"] * K4[i]) * dt.
            }

            set endValues[numVars] to K4[0].
            return endValues.
        }.
    }

    function RKF54 {
        // PUBLIC RKF54 :: nothing -> function
        // 5th Order Runge Kutta Fehlberg Method with adaptive step size
        // Error calculation seem to fail (Floating point error?) hence no error output
        local bt is lexicon(
            "a1", 0, "a2", 1/4, "a3", 3/8, "a4", 12/13, "a5", 1, "a6", 1/2,
            "b21", 1/4, "b31", 3/32, "b32", 9/32,
            "b41", 1932/2197, "b42", -7200/2197, "b43", 7296/2197,
            "b51", 439/216, "b52", -8, "b53", 3680/513, "b54", -845/4104,
            "b61", -8/27, "b62", 2, "b63", -3544/2565, "b64", 1859/4104, "b65", -11/40,
            "c1", 16/135, "c2", 0, "c3", 6656/12825, "c4", 28561/56430, "c5", -9/50, "c6", 2/55,
            "dc1", (25/216), "dc2", 0, "dc3", (1408/2565),
            "dc4", (2197/4104), "dc5", -(1/5), "dc6", 0
        ).

        return {
            // PUBLIC FUNCTION :: function : list : float -> lexicon
            parameter       FX,
                            values,
                            dt.
            
            local numVars is values:length.
            local initValues is lexicon().
            local midPoint is lexicon().
            local endValues is lexicon().
            local altEndValues is lexicon().
            local error is 0.
            local iterDT is 0.

            for i in range(numVars) {
                set initValues[i] to values[i].
            }

            local K1 is FX(values, iterDT).
            set iterDT to bt["a2"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b21"] * K1[i]) * iterDT.
            }
            local K2 is FX(midPoint, iterDT).
            set iterDT to bt["a3"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b31"] * K1[i] + 
                                                    bt["b32"] * K2[i]) * iterDT.
            }
            local K3 is FX(midPoint, iterDT).
            set iterDT to bt["a4"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b41"] * K1[i] + 
                                                    bt["b42"] * K2[i] +
                                                    bt["b43"] * K3[i]) * iterDT.
            }
            local K4 is FX(midPoint, iterDT).
            set iterDT to bt["a5"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b51"] * K1[i] + 
                                                    bt["b52"] * K2[i] +
                                                    bt["b53"] * K3[i] +
                                                    bt["b54"] * K4[i]) * iterDT.
            }
            local K5 is FX(midPoint, iterDT).
            set iterDT to bt["a6"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b61"] * K1[i] + 
                                                    bt["b62"] * K2[i] +
                                                    bt["b63"] * K3[i] +
                                                    bt["b64"] * K4[i] +
                                                    bt["b65"] * K5[i]) * iterDT.
            }
            local K6 is FX(midPoint, iterDT).

            for i in range(numVars) {
                set endValues[i] to initValues[i] + (   bt["c1"] * K1[i] +
                                                        bt["c3"] * K3[i] +
                                                        bt["c4"] * K4[i] +
                                                        bt["c5"] * K5[i] +
                                                        bt["c6"] * K6[i]) * dt.
                set altEndValues[i] to initValues[i] + (bt["dc1"] * K1[i] +
                                                        bt["dc3"] * K3[i] +
                                                        bt["dc4"] * K4[i] +
                                                        bt["dc5"] * K5[i] +
                                                        bt["dc6"] * K6[i]) * dt.     

                set error to error + (endValues[i]-altEndValues[i]):mag.  
            }

            set endValues[numVars] to K6[0].
            set endValues["Error"] to error.

            return endValues.
        }.
    }

    function RKCK54 {
        // PUBLIC RKCK54 :: nothing -> function
        // 5th Order Runge Kutta Cash-Karp Method with adaptive step size
        local bt is lexicon(
            "a1", 0, "a2", 1/5, "a3", 3/10, "a4", 3/5, "a5", 1, "a6", 7/8,
            "b21", 1/5, "b31", 3/40, "b32", 9/40,
            "b41", 3/10, "b42", -9/10, "b43", 6/5,
            "b51", -11/54, "b52", 5/2, "b53", -70/27, "b54", 35/27,
            "b61", 1631/55296, "b62", 175/512, "b63", 575/13824, "b64", 44275/110592, "b65", 253/4096,
            "c1", 37/378, "c2", 0, "c3", 250/621, "c4", 125/594, "c5", 0, "c6", 512/1771,
            "dc1", (2825/27648), "dc2", 0, "dc3", (18575/48384),
            "dc4", (13525/55296), "dc5", 277/14336, "dc6", (1/4)
        ).

        return {
            // PUBLIC FUNCTION :: function : list : float -> lexicon
            parameter       FX,
                            values,
                            dt.
            
            local numVars is values:length.
            local initValues is lexicon().
            local midPoint is lexicon().
            local endValues is lexicon().
            local altEndValues is lexicon().
            local error is 0.
            local iterDT is 0.

            for i in range(numVars) {
                set initValues[i] to values[i].
            }

            local K1 is FX(values, iterDT).
            set iterDT to bt["a2"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b21"] * K1[i]) * iterDT.
            }
            local K2 is FX(midPoint, iterDT).
            set iterDT to bt["a3"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b31"] * K1[i] + 
                                                    bt["b32"] * K2[i]) * iterDT.
            }
            local K3 is FX(midPoint, iterDT).
            set iterDT to bt["a4"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b41"] * K1[i] + 
                                                    bt["b42"] * K2[i] +
                                                    bt["b43"] * K3[i]) * iterDT.
            }
            local K4 is FX(midPoint, iterDT).
            set iterDT to bt["a5"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b51"] * K1[i] + 
                                                    bt["b52"] * K2[i] +
                                                    bt["b53"] * K3[i] +
                                                    bt["b54"] * K4[i]) * iterDT.
            }
            local K5 is FX(midPoint, iterDT).
            set iterDT to bt["a6"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b61"] * K1[i] + 
                                                    bt["b62"] * K2[i] +
                                                    bt["b63"] * K3[i] +
                                                    bt["b64"] * K4[i] +
                                                    bt["b65"] * K5[i]) * iterDT.
            }
            local K6 is FX(midPoint, iterDT).

            for i in range(numVars) {
                set endValues[i] to initValues[i] + (   bt["c1"] * K1[i] +
                                                        bt["c3"] * K3[i] +
                                                        bt["c4"] * K4[i] +
                                                        bt["c6"] * K6[i]) * dt.
                set altEndValues[i] to initValues[i] + (bt["dc1"] * K1[i] +
                                                        bt["dc3"] * K3[i] +
                                                        bt["dc4"] * K4[i] +
                                                        bt["dc5"] * K5[i] +
                                                        bt["dc6"] * K6[i]) * dt.     

                set error to error + (endValues[i]-altEndValues[i]):mag.   
            }

            set endValues[numVars] to K6[0].
            set endValues["Error"] to error.

            return endValues.
        }.
    }

    function RKDP54 {
        // PUBLIC RKDP54 :: nothing -> function
        // 5th Order Runge Kutta Dormand-Prince Method with adaptive step size
        local bt is lexicon(
            "a1", 0, "a2", 0.2, "a3", 0.3, "a4", 0.8, "a5", 8/9, "a6", 1, "a7", 1,
            "b21", 0.2, "b31", 3/40, "b32", 9/40,
            "b41", 44/45, "b42", -56/15, "b43", 32/9,
            "b51", 19372/6561, "b52", -25360/2187, "b53", 64448/6561, "b54", -212/729,
            "b61", 9017/3168, "b62", -355/33, "b63", 46732/5247, "b64", 49/176, "b65", 5103/18656,
            "b71", 35/384, "b72", 0, "b73", 500/1113, "b74", 125/192, "b75", -2187/6784, "b76", 11/84,
            "c1", 35/384, "c2", 0, "c3", 500/1113, "c4", 125/192, "c5", -2187/6784, "c6", 11/84, "c7", 0,
            "dc1", (5179/57600), "dc2", 0, "dc3", (7571/16695),
            "dc4", (393/640), "dc5", -(92097/339200), "dc6", (187/2100), "dc7", 1/40 
        ).

        return {
            // PUBLIC FUNCTION :: function : list : float -> lexicon
            parameter       FX,
                            values,
                            dt.
            
            local numVars is values:length.
            local initValues is lexicon().
            local midPoint is lexicon().
            local endValues is lexicon().
            local altEndValues is lexicon().
            local error is 0.
            local iterDT is 0.

            for i in range(numVars) {
                set initValues[i] to values[i].
            }

            local K1 is FX(values, iterDT).
            set iterDT to bt["a2"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b21"] * K1[i]) * iterDT.
            }
            local K2 is FX(midPoint, iterDT).
            set iterDT to bt["a3"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b31"] * K1[i] + 
                                                    bt["b32"] * K2[i]) * iterDT.
            }
            local K3 is FX(midPoint, iterDT).
            set iterDT to bt["a4"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b41"] * K1[i] + 
                                                    bt["b42"] * K2[i] +
                                                    bt["b43"] * K3[i]) * iterDT.
            }
            local K4 is FX(midPoint, iterDT).
            set iterDT to bt["a5"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b51"] * K1[i] + 
                                                    bt["b52"] * K2[i] +
                                                    bt["b53"] * K3[i] +
                                                    bt["b54"] * K4[i]) * iterDT.
            }
            local K5 is FX(midPoint, iterDT).
            set iterDT to bt["a6"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b61"] * K1[i] + 
                                                    bt["b62"] * K2[i] +
                                                    bt["b63"] * K3[i] +
                                                    bt["b64"] * K4[i] +
                                                    bt["b65"] * K5[i]) * iterDT.
            }
            local K6 is FX(midPoint, iterDT).
            set iterDT to bt["a7"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b71"] * K1[i] + 
                                                    bt["b72"] * K2[i] +
                                                    bt["b73"] * K3[i] +
                                                    bt["b74"] * K4[i] +
                                                    bt["b75"] * K5[i] +
                                                    bt["b76"] * K6[i]) * iterDT.
            }
            local K7 is FX(midPoint, iterDT).

            for i in range(numVars) {
                set endValues[i] to initValues[i] + (   bt["c1"] * K1[i] +
                                                        bt["c3"] * K3[i] +
                                                        bt["c4"] * K4[i] +
                                                        bt["c5"] * K5[i] +
                                                        bt["c6"] * K6[i]) * dt.
                set altEndValues[i] to initValues[i] + (bt["dc1"] * K1[i] +
                                                        bt["dc3"] * K3[i] +
                                                        bt["dc4"] * K4[i] +
                                                        bt["dc5"] * K5[i] +
                                                        bt["dc6"] * K6[i] +
                                                        bt["dc7"] * K7[i]) * dt.     

                set error to error + (endValues[i]-altEndValues[i]):mag.                                                   

            }


            set endValues[numVars] to K6[0].
            set endValues["Error"] to error.

            return endValues.
        }.
    }

    function TSIT54 {
        // PUBLIC TSIT54 :: nothing -> function
        // Tsitouras 5/4 Runge-Kutta Method with adaptive step size
        local bt is lexicon(
            "a2", 0.161, "a3", 0.327, "a4", 0.9, "a5", 0.9800255409045097, "a6", 1, "a7", 1,
            "b21", 0.161, "b31", -0.00848065549235698854, "b32", 0.335480655492356989,
            "b41", 2.89715305710549343, "b42", -6.35944848997507484, "b43", 4.36229543286958141,
            "b51", 5.325864828439257, "b52", -11.748883564062828, "b53", 7.49553934288983621, "b54", -0.09249506636175525,
            "b61", 5.8614554429464200, "b62", -12.9209693178471093, "b63", 8.1593678985761586, "b64", -0.071584973281400997, "b65", -0.0282690503940683829,
            "b71", 0.0964607668180652295, "b72", 0.01, "b73", 0.479889650414499575, "b74", 1.37900857410374189, "b75", -3.2900695154360807, "b76", 2.32471052409977398,
            "c1", 0.0964607668180652295, "c2", 0.01, "c3", 0.479889650414499575, "c4", 1.37900857410374189, "c5", -3.2900695154360807, "c6", 2.32471052409977398, "c7", 0,
            "dc1", 0.001780011052226, "dc2", 0.000816434459657, "dc3", -0.007880878010262, "dc4", 0.144711007173263, "dc5", -0.582357165452555, "dc6", 0.458082105929187, "dc7", 1/66
        ).

        return {
            // PUBLIC FUNCTION :: function : list : float -> lexicon
            parameter       FX,
                            values,
                            dt.
            
            local numVars is values:length.
            local initValues is lexicon().
            local midPoint is lexicon().
            local endValues is lexicon().
            local altEndValues is lexicon().
            local error is 0.
            local iterDT is 0.

            for i in range(numVars) {
                set initValues[i] to values[i].
            }

            local K1 is FX(values, iterDT).
            set iterDT to bt["a2"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b21"] * K1[i]) * iterDT.
            }
            local K2 is FX(midPoint, iterDT).
            set iterDT to bt["a3"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b31"] * K1[i] + 
                                                    bt["b32"] * K2[i]) * iterDT.
            }
            local K3 is FX(midPoint, iterDT).
            set iterDT to bt["a4"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b41"] * K1[i] + 
                                                    bt["b42"] * K2[i] +
                                                    bt["b43"] * K3[i]) * iterDT.
            }
            local K4 is FX(midPoint, iterDT).
            set iterDT to bt["a5"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b51"] * K1[i] + 
                                                    bt["b52"] * K2[i] +
                                                    bt["b53"] * K3[i] +
                                                    bt["b54"] * K4[i]) * iterDT.
            }
            local K5 is FX(midPoint, iterDT).
            set iterDT to bt["a6"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b61"] * K1[i] + 
                                                    bt["b62"] * K2[i] +
                                                    bt["b63"] * K3[i] +
                                                    bt["b64"] * K4[i] +
                                                    bt["b65"] * K5[i]) * iterDT.
            }
            local K6 is FX(midPoint, iterDT).
            set iterDT to bt["a7"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b71"] * K1[i] + 
                                                    bt["b72"] * K2[i] +
                                                    bt["b73"] * K3[i] +
                                                    bt["b74"] * K4[i] +
                                                    bt["b75"] * K5[i] +
                                                    bt["b76"] * K6[i]) * iterDT.
            }
            local K7 is FX(midPoint, iterDT).

            for i in range(numVars) {
                set endValues[i] to initValues[i] + (   bt["c1"] * K1[i] +
                                                        bt["c2"] * K2[i] +
                                                        bt["c3"] * K3[i] +
                                                        bt["c4"] * K4[i] +
                                                        bt["c5"] * K5[i] +
                                                        bt["c6"] * K6[i]) * dt.
                set altEndValues[i] to initValues[i]+ ( bt["dc1"] * K1[i] +
                                                        bt["dc2"] * K2[i] +
                                                        bt["dc3"] * K3[i] +
                                                        bt["dc4"] * K4[i] +
                                                        bt["dc5"] * K5[i] +
                                                        bt["dc6"] * K6[i] +
                                                        bt["dc7"] * K7[i]) * dt.
                set error to error + (endValues[i] - altEndValues[i]):mag.
            }

            set endValues[numVars] to K7[0].
            set endValues["Error"] to error.

            return endValues.
        }.
    }

    function VERN9 {
        // PUBLIC VERN9 :: nothing -> function
        // A most efficient RK 9(8) Pair by Verner
        local bt is lexicon(
            "a2", .3462e-1, "a3", .9702435063878044594828361677100617517633e-1, "a4", .1455365259581706689224254251565092627645,
            "a5", .561, "a6", .2290079115904850126662751771814700052182, "a7", .5449920884095149873337248228185299947818,
            "a8", .645, "a9", .4837500000000000000000000000000000000000, "a10", .6757e-1, "a11", .2500,
            "a12", .6590650618730998549405331618649220295334, "a13", .8206, "a14", .9012, "a15", 1, "a16", 1,
            "b21", .3462e-1, "b31", -.389335438857287327017042687229284478532e-1, "b32", .1359578945245091786499878854939346230295,
            "b41", .3638413148954266723060635628912731569111e-1, "b42", 0, "b43", .1091523944686280016918190688673819470733,
            "b51", 2.025763914393969636805657604282571047511, "b52", 0, "b53", -7.638023836496292020387602153091964592952, "b54", 6.173259922102322383581944548809393545442,
            "b61", .5112275589406060872792270881648288397197e-1, "b62", 0, "b63", 0, "b64", .1770823794555021537929910813839068684087, "b65", .80277624092225014536138698108025283759e-3,
            "b71", .1316006357975216279279871693164256985334, "b72", 0, "b73", 0, "b74", -.2957276252669636417685183174672273730699, "b75", .878137803564295237421124704053886667082e-1, "b76", .6213052975225274774321435005639430026100,
            "b81", .7166666666666666666666666666666666666667e-1, "b82", 0, "b83", 0, "b84", 0, "b85", 0, "b86", .3305533578915319409260346730051472207728, "b87", .2427799754418013924072986603281861125606,
            "b91", .7180664062500000000000000000000000000000e-1, "b92", 0, "b93", 0, "b94", 0, "b95", 0, "b96", .3294380283228177160744825466257672816401, "b97", .1165190029271822839255174533742327183599,
            "b98", -.3401367187500000000000000000000000000000e-1,
            "b101", .4836757646340646986611287718844085773549e-1, "b102", 0, "b103", 0, "b104", 0, "b105", 0, "b106", .3928989925676163974333190042057047002852e-1, "b107", .1054740945890344608263649267140088017604,
            "b108", -.2143865284648312665982642293830533996214e-1, "b109", -.1041229174627194437759832813847147895623,
            "b111", -.2664561487201478635337289243849737340534e-1, "b112", 0, "b113", 0, "b114", 0, "b115", 0, "b116", .3333333333333333333333333333333333333333e-1, "b117", -.1631072244872467239162704487554706387141,
            "b118", .3396081684127761199487954930015522928244e-1, "b119", .1572319413814626097110769806810024118077, "b1110", .2152267478031879552303534778794770376960,
            "b121", .3689009248708622334786359863227633989718e-1, "b122", 0, "b123", 0, "b124", 0, "b125", 0, "b126", -.1465181576725542928653609891758501156785, "b127", .2242577768172024345345469822625833796001,
            "b128", .2294405717066072637090897902753790803034e-1, "b129", -.35850052905728761357394424889330334334e-2, "b1210", .8669223316444385506869203619044453906053e-1, "b1211", .4383840651968337846196219974168630120572,
            "b131", -.4866012215113340846662212357570395295088, "b132", 0, "b133", 0, "b134", 0, "b135", 0, "b136", -6.304602650282852990657772792012007122988, "b137", -.281245618289472564778284183790118418111,
            "b138", -2.679019236219849057687906597489223155566, "b139", .518815663924157511565311164615012522024, "b1310", 1.365353187603341710683633635235238678626, "b1311", 5.885091088503946585721274891680604830712,
            "b1312", 2.802808786272062889819965117517532194812,
            "b141", .4185367457753471441471025246471931649633, "b142", 0, "b143", 0, "b144", 0, "b145", 0, "b146", 6.724547581906459363100870806514855026676, "b147", -.425444280164611790606983409697113064616, 
            "b148", 3.343279153001265577811816947557982637749, "b149", .617081663117537759528421117507709784737, "b1410", -.929966123939932833937749523988800852013, "b1411", -6.099948804751010722472962837945508844846,
            "b1412", -3.002206187889399044804158084895173690015, "b1413", .2553202529443445472336424602988558373637,
            "b151", -.779374086122884664644623040843840506343, "b152", 0, "b153", 0, "b154", 0, "b155", 0, "b156", -13.93734253810777678786523664804936051203, "b157", 1.252048853379357320949735183924200895136, 
            "b158", -14.69150040801686878191527989293072091588, "b159", -.494705058533141685655191992136962873577, "b1510", 2.242974909146236657906984549543692874755, "b1511", 13.36789380382864375813864978592679139881,
            "b1512", 14.39665048665068644512236935340272139005, "b1513", -.7975813331776800379127866056663258667437, "b1514", .4409353709534277758753793068298041158235,
            "b161", 2.058051337466886442151242368989994043993, "b162", 0, "b163", 0, "b164", 0, "b165", 0, "b166", 22.35793772796803295519317565842520212899, "b167", .90949810997556332745009198137971890783,
            "b168", 35.89110098240264104710550686568482456493, "b169", -3.442515027624453437985000403608480262211, "b1610", -4.865481358036368826566013387928704014496, "b1611", -18.90980381354342625688427480879773032857,
            "b1612", -34.26354448030451782929251177395134170515, "b1613", 1.264756521695642578827783499806516664686, "b1614", 0, "b1615", 0,
            "c1", .1461197685842315252051541915018784713459e-1, "c2", 0, "c3", 0, "c4", 0, "c5", 0, "c6", 0, "c7", 0, "c8", -.3915211862331339089410228267288242030810, "c9", .2310932500289506415909675644868993669908,
            "c10", .1274766769992852382560589467488989175618, "c11", .2246434176204157731566981937082069688984, "c12", .5684352689748512932705226972873692126743, "c13", .5825871557215827200814768021863420902155e-1,
            "c14", .1364317403482215641609022744494239843327, "c15", .3057013983082797397721005067920369646664e-1, "c16", 0,
            "dc1", .1996996514886773085518508418098868756464e-1, "dc2", 0, "dc3", 0, "dc4", 0, "dc5", 0, "dc6", 0, "dc7", 0, "dc8", 2.191499304949330054530747099310837524864,
            "dc9", .8857071848208438030833722031786358862953e-1, "dc10", .1140560234865965622484956605091432032674, "dc11", .2533163805345107065564577734569651977347, "dc12", -2.056564386240941011158999594595981300493,
            "dc13", .3408096799013119935160094894224543812830, "dc14", 0, "dc15", 0, "dc16", .4834231373823958314376726739772871714902e-1
        ).

        return {
            // PUBLIC FUNCTION :: function : list : float -> lexicon
            parameter       FX,
                            values,
                            dt.
            
            local numVars is values:length.
            local initValues is lexicon().
            local midPoint is lexicon().
            local endValues is lexicon().
            local altEndValues is lexicon().
            local error is 0.
            local iterDT is 0.

            for i in range(numVars) {
                set initValues[i] to values[i].
            }

            local K1 is FX(values, iterDT).
            set iterDT to bt["a2"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b21"] * K1[i]) * iterDT.
            }
            local K2 is FX(midPoint, iterDT).
            set iterDT to bt["a3"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b31"] * K1[i] + 
                                                    bt["b32"] * K2[i]) * iterDT.
            }
            local K3 is FX(midPoint, iterDT).
            set iterDT to bt["a4"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b41"] * K1[i] + 
                                                    bt["b43"] * K3[i]) * iterDT.
            }
            local K4 is FX(midPoint, iterDT).
            set iterDT to bt["a5"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b51"] * K1[i] + 
                                                    bt["b53"] * K3[i] +
                                                    bt["b54"] * K4[i]) * iterDT.
            }
            local K5 is FX(midPoint, iterDT).
            set iterDT to bt["a6"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b61"] * K1[i] + 
                                                    bt["b64"] * K4[i] +
                                                    bt["b65"] * K5[i]) * iterDT.
            }
            local K6 is FX(midPoint, iterDT).
            set iterDT to bt["a7"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b71"] * K1[i] + 
                                                    bt["b74"] * K4[i] +
                                                    bt["b75"] * K5[i] +
                                                    bt["b76"] * K6[i]) * iterDT.
            }
            local K7 is FX(midPoint, iterDT).
            set iterDT to bt["a8"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b81"] * K1[i] + 
                                                    bt["b86"] * K6[i] +
                                                    bt["b87"] * K7[i]) * iterDT.
            }
            local K8 is FX(midPoint, iterDT).
            set iterDT to bt["a9"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b91"] * K1[i] + 
                                                    bt["b96"] * K6[i] +
                                                    bt["b97"] * K7[i] +
                                                    bt["b98"] * K8[i]) * iterDT.
            }
            local K9 is FX(midPoint, iterDT).
            set iterDT to bt["a10"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b101"] * K1[i] + 
                                                    bt["b106"] * K6[i] +
                                                    bt["b107"] * K7[i] +
                                                    bt["b108"] * K8[i] +
                                                    bt["b109"] * K9[i]) * iterDT.
            }
            local K10 is FX(midPoint, iterDT).
            set iterDT to bt["a11"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b111"] * K1[i] + 
                                                    bt["b116"] * K6[i] +
                                                    bt["b117"] * K7[i] +
                                                    bt["b118"] * K8[i] +
                                                    bt["b119"] * K9[i] +
                                                    bt["b1110"] * K10[i]) * iterDT.
            }
            local K11 is FX(midPoint, iterDT).
            set iterDT to bt["a12"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b121"] * K1[i] + 
                                                    bt["b126"] * K6[i] +
                                                    bt["b127"] * K7[i] +
                                                    bt["b128"] * K8[i] +
                                                    bt["b129"] * K9[i] +
                                                    bt["b1210"] * K10[i] +
                                                    bt["b1211"] * K11[i]) * iterDT.
            }
            local K12 is FX(midPoint, iterDT).
            set iterDT to bt["a13"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b131"] * K1[i] + 
                                                    bt["b136"] * K6[i] +
                                                    bt["b137"] * K7[i] +
                                                    bt["b138"] * K8[i] +
                                                    bt["b139"] * K9[i] +
                                                    bt["b1310"] * K10[i] +
                                                    bt["b1311"] * K11[i] +
                                                    bt["b1312"] * K12[i]) * iterDT.
            }
            local K13 is FX(midPoint, iterDT).
            set iterDT to bt["a14"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b141"] * K1[i] + 
                                                    bt["b146"] * K6[i] +
                                                    bt["b147"] * K7[i] +
                                                    bt["b148"] * K8[i] +
                                                    bt["b149"] * K9[i] +
                                                    bt["b1410"] * K10[i] +
                                                    bt["b1411"] * K11[i] +
                                                    bt["b1412"] * K12[i] +
                                                    bt["b1413"] * K13[i]) * iterDT.
            }
            local K14 is FX(midPoint, iterDT).
            set iterDT to bt["a15"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b151"] * K1[i] + 
                                                    bt["b156"] * K6[i] +
                                                    bt["b157"] * K7[i] +
                                                    bt["b158"] * K8[i] +
                                                    bt["b159"] * K9[i] +
                                                    bt["b1510"] * K10[i] +
                                                    bt["b1511"] * K11[i] +
                                                    bt["b1512"] * K12[i] +
                                                    bt["b1513"] * K13[i] +
                                                    bt["b1514"] * K14[i]) * iterDT.
            }
            local K15 is FX(midPoint, iterDT).
            set iterDT to bt["a16"]*dt.
            for i in range(numVars) {
                set midPoint[i] to initValues[i] + (bt["b161"] * K1[i] + 
                                                    bt["b166"] * K6[i] +
                                                    bt["b167"] * K7[i] +
                                                    bt["b168"] * K8[i] +
                                                    bt["b169"] * K9[i] +
                                                    bt["b1610"] * K10[i] +
                                                    bt["b1611"] * K11[i] +
                                                    bt["b1612"] * K12[i] +
                                                    bt["b1613"] * K13[i]) * iterDT.
            }
            local K16 is FX(midPoint, iterDT).


            for i in range(numVars) {
                set endValues[i] to initValues[i] + (   bt["c1"] * K1[i] +
                                                        bt["c8"] * K8[i] +
                                                        bt["c9"] * K9[i] +
                                                        bt["c10"] * K10[i] +
                                                        bt["c11"] * K11[i] +
                                                        bt["c12"] * K12[i] +
                                                        bt["c13"] * K13[i] +
                                                        bt["c14"] * K14[i] +
                                                        bt["c15"] * K15[i]) * dt.
                set altEndValues[i] to initValues[i]+ ( bt["dc1"] * K1[i] +
                                                        bt["dc8"] * K8[i] +
                                                        bt["dc9"] * K9[i] +
                                                        bt["dc10"] * K10[i] +
                                                        bt["dc11"] * K11[i] +
                                                        bt["dc12"] * K12[i] +
                                                        bt["dc13"] * K13[i] +
                                                        bt["dc16"] * K16[i]) * dt.
                set error to error + (endValues[i] - altEndValues[i]):mag.
            }

            set endValues[numVars] to K7[0].
            set endValues["Error"] to error.

            return endValues.
        }.
    }

    return lexicon(
        "Euler", Euler@,
        "BS3", BS3@,
        "RK4", RK4@,
        "RKF54", RKF54@,
        "RKCK54", RKCK54@,
        "RKDP54", RKDP54@,
        "TSIT54", TSIT54@,
        "VERN9", VERN9@
    ).
}

function ODEerror {
    // PUBLIC ODEerror :: nothing -> lexicon
    // Function that returns an ODE Solver Error Function

    local solverCorrectionLexicon is lexicon(
        "BS3", 1,
        "RKF54", 0.01,
        "RKCK54", 0.01,
        "RKDP54", 1,
        "TSIT54", 2000,
        "VERN9", 0.001
    ).

    local solverOrderLexicon is lexicon(
        "BS3", 2,
        "RKF54", 4,
        "RKCK54", 4,
        "RKDP54", 4,
        "TSIT54", 4,
        "VERN9", 8
    ).

    local scor is 1.        // Solver Correcion
    local sor is 4.         // Solver Order

    function calculateStepsize {
        // PRIVATE calculateStepsize :: float -> function
        // Tries to keep the ODE Error constant by updating Delta-T
        // Has a step limit that prevent dt from escalating
        parameter           selectedSolver.

        if solverCorrectionLexicon:haskey(selectedSolver) set scor to solverCorrectionLexicon[selectedSolver].
        if solverOrderLexicon:haskey(selectedSolver) set sor to solverOrderLexicon[selectedSolver].

        return {
            parameter       dt,
                            calcError,
                            targetError,
                            dtStepLimit is 2.

            return min(max(0.9 * dt * ((targetError*scor)/calcError)^(1/sor), 
            dt/dtStepLimit), dt*dtStepLimit).        
        }.
    }

    return calculateStepsize@.
}

global lib_ODEsolver is ODEsolver().
global lib_ODEerror is ODEerror().