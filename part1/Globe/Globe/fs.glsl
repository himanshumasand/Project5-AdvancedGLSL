//View-Space directional light
//A unit vector
uniform vec3 u_CameraSpaceDirLight;

//Diffuse texture map for the day
uniform sampler2D u_DayDiffuse;
//Ambient texture map for the night side
uniform sampler2D u_Night;
//Color map for the clouds
uniform sampler2D u_Cloud;
//Transparency map for the clouds.  Note that light areas are where clouds are NOT
//Dark areas are were clouds are present
uniform sampler2D u_CloudTrans;
//Mask of which areas of the earth have specularity
//Oceans are specular, landmasses are not
uniform sampler2D u_EarthSpec;
//Bump map
uniform sampler2D u_Bump;

uniform float u_time;
uniform mat4 u_InvTrans;

varying vec3 v_Normal;              // surface normal in camera coordinates
varying vec2 v_Texcoord;
varying vec3 v_Position;            // position in camera coordinates
varying vec3 v_positionMC;          // position in model coordinates

mat3 eastNorthUpToEyeCoordinates(vec3 positionMC, vec3 normalEC);

void main(void)
{
    vec3 normal = normalize(v_Normal);            // surface normal - normalized after rasterization
    vec3 eyeToPosition = normalize(v_Position);   // normalized eye-to-position vector in camera coordinates
	vec3 eyeToPositionMC = normalize(v_positionMC);

	float center = texture2D(u_Bump, v_Texcoord);
	float right = texture2D(u_Bump, vec2(v_Texcoord.s + 1/1000.0, v_Texcoord.t));
	float top = texture2D(u_Bump, vec2(v_Texcoord.s, v_Texcoord.t + 1/500.0));

	vec3 bumpNormal = normalize(vec3(center - right, center - top, 0.2));
	mat3 bumpMat = eastNorthUpToEyeCoordinates(eyeToPositionMC, bumpNormal);

    //float diffuse = max(dot(u_CameraSpaceDirLight, normal), 0.0);
	float diffuse = dot(u_CameraSpaceDirLight, normal);
	float bumpDiffuse = dot(u_CameraSpaceDirLight, vec3(bumpMat[2].xyz));

    vec3 toReflectedLight = reflect(-u_CameraSpaceDirLight, normal);
    float specular = max(dot(toReflectedLight, -eyeToPosition), 0.0);
    specular = pow(specular, 20.0);

    float gammaCorrect = 1/2.5; //gamma correct by 1/1.8

    vec4 dayColor = texture2D(u_DayDiffuse, v_Texcoord);
    vec4 nightColor = pow(texture2D(u_Night, v_Texcoord),gammaCorrect);    //apply gamma correction to nighttime texture

	vec4 earthSpec = texture2D(u_EarthSpec, v_Texcoord);
	vec4 cloud = texture2D(u_Cloud, vec2(v_Texcoord.s + u_time, v_Texcoord.t));
	vec4 cloudTrans = texture2D(u_CloudTrans, vec2(v_Texcoord.s + u_time, v_Texcoord.t));

<<<<<<< HEAD

=======
>>>>>>> Part 2 and 3
	if(diffuse >= 0.0)
	{
		if(earthSpec == vec4(1,1,1,1))
			gl_FragColor = mix(((0.6 * bumpDiffuse) + (0.4 * specular)) * dayColor, 0.6 * nightColor, 1 - diffuse);
		else
			gl_FragColor = mix((0.6 * bumpDiffuse) * dayColor, 0.6 * nightColor, 1 - diffuse);

		vec4 cloudColor = mix(cloud, vec4(0,0,0,0), 1 - diffuse);
		gl_FragColor = mix(gl_FragColor, cloudColor, vec4(1,1,1,1) - cloudTrans);
	}
	else
<<<<<<< HEAD
	{
		gl_FragColor = mix(0.6 * nightColor, vec4(0,0,0,0), vec4(1,1,1,1) - cloudTrans);
	}
=======
		gl_FragColor = mix(0.6 * nightColor, vec4(0,0,0,0), vec4(1,1,1,1) - cloudTrans);
>>>>>>> Part 2 and 3

	float rimFactor = dot(v_Normal, v_Position) + 1.0;
	if(rimFactor > 0.0)
		gl_FragColor += vec4(rimFactor/4, rimFactor/2, rimFactor/2, 1);
}

mat3 eastNorthUpToEyeCoordinates(vec3 positionMC, vec3 normalEC)
{
    vec3 tangentMC = normalize(vec3(-positionMC.y, positionMC.x, 0.0));  // normalized surface tangent in model coordinates
    vec3 tangentEC = normalize(mat3(u_InvTrans) * tangentMC);            // normalized surface tangent in eye coordiantes
    vec3 bitangentEC = normalize(cross(normalEC, tangentEC));            // normalized surface bitangent in eye coordinates

    return mat3(
        tangentEC.x,   tangentEC.y,   tangentEC.z,
        bitangentEC.x, bitangentEC.y, bitangentEC.z,
        normalEC.x,    normalEC.y,    normalEC.z);
}