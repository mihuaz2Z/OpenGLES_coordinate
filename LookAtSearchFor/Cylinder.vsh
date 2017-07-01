#version 100

uniform mat4 cylinderMvp;
attribute vec3 v_Position;

void main()
{

    gl_Position = cylinderMvp * vec4(v_Position.x,v_Position.y,0.0,1.0);
}
