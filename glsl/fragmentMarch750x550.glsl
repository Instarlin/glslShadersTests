#version 460
out vec4 fragColor;
uniform float time;
uniform int width;
uniform int height;

float smoothUnion(float d1, float d2, float k) {
  float h = clamp(0.5 + 0.5*(d2-d1)/k, 0.0, 1.0);
  return mix(d2, d1, h) - k*h*(1.0-h);
};

float smoothSubstraction(float d1, float d2, float k) {
  float h = clamp(0.5 - 0.5*(d2+d1)/k, 0.0, 1.0);
  return mix(d2, -d1, h) + k*h*(1.0-h);
};

float smoothIntersection(float d1, float d2, float k) {
  float h = clamp(0.5 - 0.5*(d2-d1)/k, 0.0, 1.0);
  return mix(d2, d1, h) + k*h*(1.0-h);
};

float sdSphere(vec3 p, float r) {
  return length(p) - r;
};

float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
};

float sdCrosscube(vec3 p, vec3 s) {
  vec3 v = vec3(1./3., 1./3., 4./3.);

  float d1 = sdBox(p, s*v.xyz);
  float d2 = sdBox(p, s*v.yzx);
  float d3 = sdBox(p, s*v.zxy);
  
  return min(min(d1, d2), d3);
};

float rand(vec2 p) {
  return fract(sin(dot(p.xy,vec2(12.9898,78.233))) * 43758.5453);
};

mat2 rot(float r) {
  return mat2(cos(r), sin(r), -sin(r), cos(r));
};

float map(vec3 p) {
  p.xz *= rot(time/12);
  p.yz *= rot(time/12);

  vec3 size = vec3(1.);
  float d = sdBox(p, size);
  float cd = sdCrosscube(p, size);
  d = max(d, -cd);

  for (int i = 0; i < 6; i++) {
    size *= 1./3.;
    float m = size.x*2.;
    p = mod(p-0.5*m, m)-0.5*m;
    cd = sdCrosscube(p, size);
    d = max(d, -cd);
  };

  return d;
};

// float map(vec3 p) {
//   vec3 size = vec3(.15);
//   vec3 spherePosition = vec3(-1.5*sin(time/4), 0.25, -1.5*cos(time/4));
//   float sphere = sdSphere(p - spherePosition, .5);

//   vec3 q = p;

//   q.yz += time/4;
//   q = fract(q) - .5;

//   // vec3 boxPosition = vec3(0, 0, 0);
//   // float box = sdBox(q, vec3(.15));
//   float box = sdBox(q, size);
//   float cb = sdCrosscube(q, size);
//   box = max(-cb, box);

//   for (int i = 0; i < 4; i++) {
//     size *= 1./3.;
//     float m = size.x*2.;
//     q = mod(q-0.5*m, m)-0.5*m;
//     cb = sdCrosscube(q, size);
//     box = max(box, -cb);
//   };

//   float ground = p.y + .75;

//   return smoothUnion(ground, smoothUnion(box, sphere, .4), .2);
//   //* rough operations
//   // min(d1, d2) Union
//   // max(d1, d2) Intersection
//   // max(-d1, d2) Substraction
// };

// float map(vec3 p) {
//   vec3 q = p;

//   q.xy += .5;
//   q.yz += .15 * time;
//   q.x += .1 * time;
//   q = fract(q) - .5;

//   vec3 spherePosition = vec3(-1.5, 0.25, -1.5);
//   float sphere = sdSphere(q, 0.65);

//   vec3 boxPosition = vec3(0, 0, 0);
//   float box = sdBox(q, vec3(.5));

//   return max(-sphere, box);
// };

void main(void) {
  vec2 uv = vec2((gl_FragCoord.x*2.0-width)/height, (gl_FragCoord.y*2.0-height)/height);

  vec3 ro = vec3(0, 0, -3);       // origin
  vec3 rd = normalize(vec3(uv, 1)); // direction
  vec3 col = vec3(0);               // final color

  float t = 0.;

  for (int i = 0; i < 80; i++) {
    vec3 p = ro + rd * t;

    float d = map(p);

    t += d;

    col = vec3(i)/80.;

    if (d < .0001 || t > 100.) break;
  };

  fragColor = vec4(col, 1);
};

// float map(vec3 p) {
// vec3 spherePosition = vec3(-1.5*sin(time/4), 0.25, -1.5*cos(time/4));
//   float sphere = sdSphere(p - spherePosition, .5);

//   vec3 q = p;

//   q.yz += time/4;
//   q = fract(q) - .5;

//   vec3 boxPosition = vec3(0, 0, 0);
//   float box = sdBox(q, vec3(.15));

//   float ground = p.y + .75;

//   return smoothUnion(ground, smoothUnion(box, sphere, .6), .2);
// };

// float map(vec3 p) {
//   vec3 q = p;

//   q.xy += .5;
//   q.yz += .15 * time;
//   q.x += .1 * time;
//   q = fract(q) - .5;

//   vec3 spherePosition = vec3(-1.5, 0.25, -1.5);
//   float sphere = sdSphere(q, 0.65);

//   vec3 boxPosition = vec3(0, 0, 0);
//   float box = sdBox(q, vec3(.5));

//   return max(-sphere, box);
// };