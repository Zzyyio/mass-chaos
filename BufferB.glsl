// Rank each finite value within its row. Column index breaks ties.
void mainImage(out vec4 color,in vec2 pixel) {
    ivec2 cell=ivec2(pixel);
    float v=texelFetch(iChannel0,ivec2(cell.x*RECORD+6,cell.y),0).z;
    int rank=0, count=0;
    for(int x=0;x<GRID;++x) {
        float w=texelFetch(iChannel0,ivec2(x*RECORD+6,cell.y),0).z;
        if(isnan(w)||isinf(w)) continue;
        ++count;
        if(w<v || (w==v && x<cell.x)) ++rank;
    }
    color=vec4(v,float(isnan(v)||isinf(v)?-1:rank),float(count),1.);
}
