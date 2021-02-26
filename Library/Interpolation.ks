/////////////////////////////////////////////
// Interpolation                           //
// By Ren0k                                //
/////////////////////////////////////////////
@lazyGlobal off.

function interpolationFunctions {
    // PUBLIC interpolationFunctions :: nothing -> function
    // Function that returns an interpolator function

    function hermiteInterpolator {
        // PRIVATE hermiteInterpolator :: float x7 -> float
        parameter       x0 is 0,
                        x1 is 1,
                        y0 is 0,
                        y1 is 1,
                        m0 is 0,
                        m1 is 0,
                        dataPoint is 1.

        // H(t)=(2t^3-3t^2+1)y0+(t^3-2t^2+t)m0+(-2t^3+3t^2)y1+(t^3-t^2)m1
        // This function returns the y value resulting from position t on the curve

        // x0 = start point
        // x1 = end point
        // y0 = start value
        // y1 = end value
        // m0 = start tangent
        // m1 = end tangent
        // dataPoint = float to get the y value

        local normFactor is (x1-x0).
        local t is (dataPoint-x0)/normFactor.
        set m0 to m0 * (normFactor).
        set m1 to m1 * (normFactor).
        return (2*t^3-3*t^2+1)*y0+(t^3-2*t^2+t)*m0+(-2*t^3+3*t^2)*y1+(t^3-t^2)*m1.
    }

    function interpolatePolynomial {
        // PUBLIC interpolatePolynomial :: list : list : float -> float
        // Uses a hermite interpolator to interpolate on a curve
        parameter       keyValues1, keyValues2, value.

        local x0 is keyValues1[0].
        local x1 is keyValues2[0].
        local y0 is keyValues1[1].
        local y1 is keyValues2[1].
        local m0 is keyValues1[3].
        local m1 is keyValues2[2].

        return hermiteInterpolator(x0, x1, y0, y1, m0, m1, value).
    }     

    function interpolateLinear {
        // PUBLIC interpolateLinear :: list : list : float -> float
        // Faster way to interpolate than a cubic method, but less accurate
        parameter       keyValues1, keyValues2, value.

        local x0 is keyValues1[0].
        local x1 is keyValues2[0].
        local y0 is keyValues1[1].
        local y1 is keyValues2[1].

        return ((value*(x1-x0))*(y1-y0))+y0.
    }  

    return lexicon(
        "polynomial", interpolatePolynomial@,
        "linear", interpolateLinear@
    ).
}

global lib_interpolationFunctions is interpolationFunctions().