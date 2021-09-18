#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

#define PI 3.141597

float dist2(vec2 a, vec2 b)
{
	vec2 delta = b - a;	
	delta.x   *= resolution.x / resolution.y;
	return dot(delta, delta);
}

float nsin(float x) { return sin(x) * 0.5 + 0.5; }
float ncos(float x) { return cos(x) * 0.5 + 0.5; }

mat3 translate(vec2 pos)
{
   return mat3(
      1., 0., pos.x,
      0., 1., pos.y,
      0., 0., 1.
   );	
}

mat3 rotate(float angle)
{
   return mat3(
      cos(angle), -sin(angle), 0.,
      sin(angle),  cos(angle), 0.,
      0.,           0.,        1.
   );
}

float circle(vec2 st, float r)
{
    return (1. - step(r, dist2(st, vec2(0.)))) * 
                 step(r - r * 0.05, dist2(st, vec2(0.)));
}

float rline(vec2 st)
{
    return (1. - step(0.002, st.x)) *
	    	 step(0.,    st.x);
}

float trail(vec2 st)
{
    return smoothstep(0., -st.x, st.y / 10.) * 0.25;
}

float squarewave(float t)
{
    return t - floor(t);
}

float target(vec3 st, float t)
{
    mat3 transform = translate(vec2(0., -0.25));
	
    float dt = (1. - step(0.00001, dist2((st * transform).xy, vec2(0.))));
	
    return (dt + circle((st * transform).xy, squarewave(t / PI))) * (1. - squarewave(t / PI));
}

void main( void )
{
	vec3 st = vec3(gl_FragCoord.xy / resolution.xy, 1.);
	
	vec3 color;
	
	mat3 transform = translate(vec2(-0.5));
	mat3 rot       = rotate(time);
	//mat3 rot = rotate(0.);
	
	color  = vec3(circle((st * transform).xy, 0.025));
	color += vec3(circle((st * transform).xy, 0.125));
	color += vec3(circle((st * transform).xy, 0.275));
	color += vec3(circle((st * transform).xy, 0.555));
	color.g += rline((st * transform * rot).xy);
	color.g += trail((st * transform * rot).xy);
	color.r += target(st * transform, time);
	
	gl_FragColor = vec4(vec3(color), 1.0);
}
