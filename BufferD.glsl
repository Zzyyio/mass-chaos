// Each of two pixels finds one global nearest-rank quartile.
// The bit transform preserves float order, including negative values.
float fromKey(uint key) {
    return uintBitsToFloat((key&0x80000000u)!=0u ? key^0x80000000u : ~key);
}
void mainImage(out vec4 color,in vec2 pixel) {
    int counts[GRID], total=0;
    for(int y=0;y<GRID;++y) {
        counts[y]=int(texelFetch(iChannel0,ivec2(0,y),0).y);
        total+=counts[y];
    }
    color=vec4(0);
    if(total==0) return;
    int target=(total*(int(pixel.x)==0?1:3)+3)/4;
    uint lo=0x00800000u, hi=0xff7fffffu;
    for(int k=0;k<32 && lo<hi;++k) {
        uint mid=lo+((hi-lo)>>1u);
        float pivot=fromKey(mid);
        int cumulative=0;
        for(int y=0;y<GRID;++y) {
            int l=0,r=counts[y];
            while(l<r) {
                int x=(l+r)/2;
                if(texelFetch(iChannel0,ivec2(x,y),0).x<=pivot) l=x+1;
                else r=x;
            }
            cumulative+=l;
            if(cumulative>=target) break;
        }
        if(cumulative>=target) hi=mid;
        else lo=mid+1u;
    }
    color=vec4(fromKey(lo),0,0,1);
}
