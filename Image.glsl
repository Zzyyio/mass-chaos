// Grid coordinates run from 1 to 64 on both log2 axes.
vec3 palette(float y) {
    vec3 c=mix(vec3(.026,.037,.085),vec3(.07,.19,.40),smoothstep(0.,2.,y));
    c=mix(c,vec3(.05,.66,.69),smoothstep(2.,4.,y));
    c=mix(c,vec3(.98,.84,.30),smoothstep(4.,8.,y));
    return mix(c,vec3(1.,.32,.10),smoothstep(8.,12.,y));
}
// 3 x 5 pixel numerals used for axis ticks, color key and elapsed tau.
float digit(vec2 p,int n) {
    const int glyph[10]=int[10](31599,11415,29671,29647,23497,31183,31215,29257,31727,31695);
    ivec2 q=ivec2(floor(p));
    if(any(lessThan(q,ivec2(0))) || q.x>=3 || q.y>=5) return 0.;
    return float((glyph[n]>>(3*q.y+2-q.x))&1);
}
void mainImage(out vec4 color,in vec2 pixel) {
    float size=min(iResolution.x/1.25,iResolution.y/1.28);
    vec2 p=(pixel-0.5*iResolution.xy)/size+vec2(.48,.49);
    vec3 c=vec3(.018,.024,.043);
    float ink=0.;
    if(all(greaterThanEqual(p,vec2(0))) && all(lessThan(p,vec2(1)))) {
        ivec2 bin=ivec2(p*float(GRID));
        vec4 m=texelFetch(iChannel0,ivec2(bin.x*RECORD+6,bin.y),0);
        c=mix(vec3(.065,.077,.11),palette(m.z),smoothstep(0.,2.,m.x));
    }
    for(int i=0;i<=MASS_OCTAVES;++i) {
        float tick=(float(i)/float(MASS_OCTAVES)*float(GRID-1)+.5)/float(GRID);
        int mass=1<<i;
        float width=mass<10?3.:7.;
        vec2 xLabel=(p-vec2(tick,-.045))*220.+vec2(width*.5,0);
        vec2 yLabel=(p-vec2(-.014,tick))*220.+vec2(width,2.5);
        if(mass>=10) {
            ink=max(ink,max(digit(xLabel,mass/10),digit(yLabel,mass/10)));
            xLabel.x-=4.; yLabel.x-=4.;
        }
        ink=max(ink,max(digit(xLabel,mass%10),digit(yLabel,mass%10)));
    }
    if(p.y<-.061 && p.y>-.078 && p.x>=0. && p.x<1.) c=palette(12.*p.x);
    for(int i=0;i<=6;++i) {
        vec2 q=(p-vec2(float(i)/6.,-.111))*220.;
        int n=2*i;
        ink=max(ink,n<10?digit(q+vec2(1.,0),n):max(digit(q+vec2(3.,0),1),digit(q-vec2(1.,0),n-10)));
    }
    // tau at top left, in tenths of a dynamical time.
    int clock10=int(mod(texelFetch(iChannel0,ivec2(6,0),0).x*10.,100000.));
    vec2 q=(p-vec2(0,1.026))*220.;
    ink=max(ink,float(q.x>=0. && q.x<4. && q.y>=4. && q.y<5. || q.x>=1. && q.x<2. && q.y>=0. && q.y<4.));
    for(int i=0;i<5;++i) {
        float x=8.+float(4-i)*4.+(i==0?2.:0.);
        ink=max(ink,digit(q-vec2(x,0),clock10%10));
        clock10/=10;
    }
    ink=max(ink,float(q.x>=24. && q.x<25. && q.y>=0. && q.y<1.));
    color=vec4(mix(c,vec3(.80,.85,.92),ink),1);
}
