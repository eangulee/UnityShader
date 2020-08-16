Shader "GLSL basic shader" { // defines the name of the shader
SubShader { // Unity chooses the subshader that fits the GPU best
	Pass { // some shaders require multiple passes
		GLSLPROGRAM // here begins the part in Unity's GLSL
		#ifdef VERTEX // here begins the vertex shader
		void main() // all vertex shaders define a main() function
		{
			gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
			// this line transforms the predefined attribute
			// gl_Vertex of type vec4 with the predefined
			// uniform gl_ModelViewProjectionMatrix of type mat4
			// and stores the result in the predefined output
			// variable gl_Position of type vec4.
		}
		#endif // here ends the definition of the vertex shader
		#ifdef FRAGMENT // here begins the fragment shader
		void main() // all fragment shaders define a main() function
		{
			gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
			// this fragment shader just sets the output color
			// to opaque red (red = 1.0, green = 0.0, blue = 0.0,
			// alpha = 1.0)
		}
		#endif // here ends the definition of the fragment shader
		ENDGLSL // here ends the part in GLSL
		}
	}
	// FallBack "Diffuse"
}