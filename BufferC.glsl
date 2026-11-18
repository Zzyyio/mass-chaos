// Gather ranks into sorted rows for the global order-statistic lookup.
void mainImage(out vec4 color,in vec2 pixel) {
    ivec2 cell=ivec2(pixel);
    int count=int(texelFetch(iChannel0,ivec2(0,cell.y),0).z);
    color=vec4(0.,float(count),0.,1.);
    if(cell.x>=count) return;
    for(int x=0;x<GRID;++x) {
        vec4 item=texelFetch(iChannel0,ivec2(x,cell.y),0);
        if(int(item.y)==cell.x) { color.x=item.x; return; }
    }
}
