// Use configure.py to update parameters and all feedback texture dimensions.
const int GRID = 512;
const int RECORD = 7;
const float STEP = 0.001;
const int SUBSTEPS = 32;
const int MAX_MASS = 4;
const float EPS = 0.015;
float massRatio(int index) {
    return exp2(mix(0.0,log2(float(MAX_MASS)),float(index)/float(GRID-1)));
}
