// Self feedback, 1568 x 224. State: (position,velocity) x3,
// (tangent position,tangent velocity) x3, (time,Y,mean Y,initialized).
void mainImage(out vec4 color, in vec2 pixel) {
    ivec2 cell = ivec2(pixel);
    int slot = cell.x % RECORD;
    ivec2 base = cell-ivec2(slot,0);
    vec3 mass = vec3(massRatio(base.x/RECORD),massRatio(cell.y),1);
    float total = dot(mass,vec3(1));
    vec3 mu = mass/total; // tau = t / sqrt(L^3 / (G*M)); L=G=1.
    vec4 s[3], d[3];
    vec4 metric = texelFetch(iChannel0,base+ivec2(6,0),0);
    if (iFrame == 0 || metric.w != 1.0) {
        s[0]=vec4(0,.62,-.95,0);
        s[1]=vec4(-.54,-.31,.48,-.82);
        s[2]=vec4(.54,-.31,.48,.82);
        vec4 center = mu.x*s[0]+mu.y*s[1]+mu.z*s[2];
        // Internal perturbation, with the center-of-mass displacement removed.
        float norm0 = length(vec3(1.0-mu.x,-mu.x,-mu.x));
        for (int i=0;i<3;++i) {
            s[i]-=center;
            s[i].zw/=sqrt(total);
            d[i]=vec4(((i==0 ? 1.0 : 0.0)-mu.x)/norm0,0,0,0);
        }
        metric=vec4(0,0,0,1);
    } else {
        for (int i=0;i<3;++i) {
            s[i]=texelFetch(iChannel0,base+ivec2(i,0),0);
            d[i]=texelFetch(iChannel0,base+ivec2(i+3,0),0);
        }
        for (int k=0;k<SUBSTEPS;++k) {
            for (int i=0;i<3;++i) {
                s[i].xy+=0.5*STEP*s[i].zw;
                d[i].xy+=0.5*STEP*d[i].zw;
            }
            for (int i=0;i<2;++i) for (int j=i+1;j<3;++j) {
                vec2 r=s[j].xy-s[i].xy, dr=d[j].xy-d[i].xy;
                float inv=inversesqrt(dot(r,r)+EPS*EPS);
                float kick=STEP*inv*inv*inv;
                vec2 f=kick*r;
                vec2 df=kick*(dr-3.0*r*(dot(r,dr)*inv*inv));
                s[i].zw+=mu[j]*f; s[j].zw-=mu[i]*f;
                d[i].zw+=mu[j]*df; d[j].zw-=mu[i]*df;
            }
            float norm2=0.0;
            for (int i=0;i<3;++i) {
                s[i].xy+=0.5*STEP*s[i].zw;
                d[i].xy+=0.5*STEP*d[i].zw;
                norm2+=dot(d[i],d[i]);
            }
            float invNorm=inversesqrt(norm2);
            for (int i=0;i<3;++i) d[i]*=invNorm;
            // Integral of 2*t*d(log|delta|), then time-average Y.
            float t=metric.x, next=t+STEP;
            float y=(t*metric.y+(t+0.5*STEP)*log(norm2))/next;
            metric.z+=(0.5*(metric.y+y)-metric.z)*STEP/next;
            metric.xy=vec2(next,y);
        }
    }
    color=metric;
    if (slot<3) color=s[slot];
    else if (slot<6) color=d[slot-3];
}
