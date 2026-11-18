// One 224 x 224 mass plane. Seven adjacent RGBA texels per experiment.
const int GRID = 224;
const int RECORD = 7;
const float STEP = 0.001;
const int SUBSTEPS = 64;
const int MASS_OCTAVES = 6; // maximum mass ratio = 2^MASS_OCTAVES
const float EPS = 0.015;
float massRatio(int index) {
    return exp2(mix(0.0,float(MASS_OCTAVES),float(index)/float(GRID-1)));
}
