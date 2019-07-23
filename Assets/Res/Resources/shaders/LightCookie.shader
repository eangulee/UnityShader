Shader "Custom/LightCookie"
{
    Properties
    {
        _Color ("Diffuse Material Color", Color) = (1,1,1,1)
        _SpecColor ("Specular Material Color", Color) = (1,1,1,1)
        _Shininess ("Shininess", Float) = 10
    }

    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            GLSLPROGRAM

            uniform vec4 _Color;
            uniform vec4 _SpecColor;
            uniform float _Shininess;

            uniform vec3 _WorldSpaceCameraPos;
            uniform mat4 _Object2World;
            uniform mat4 _World2Object;
            uniform vec4 _WorldSpaceLightPos0;
            uniform vec4 _LightColor0;

            #ifdef VERTEX
            //顶点着色器

            //world pos
            out vec4 position;
            out vec3 worldNormalDirection;

            void main()
            {
                mat4 modelMatrix = _Object2World;
                mat4 modelMatrixInverse = _World2Object;

                position = modelMatrix * gl_Vertex;
                worldNormalDirection = normalize(vec3(vec4(gl_Normal, 0.0) * modelMatrixInverse));

                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
            }

            #endif

            #ifdef FRAGMENT
            //片元着色器

            in vec4 position;
            in vec3 worldNormalDirection;

            void main()
            {
                vec3 normalDirection = normalize(worldNormalDirection);
                vec3 viewDirection = normalize(_WorldSpaceCameraPos - vec3(position));

                vec3 lightDirection = normalize(vec3(_WorldSpaceLightPos0));
                vec3 ambientLighting = vec3(gl_LightModel.ambient) * vec3(_Color);

                vec3 diffuseReflection = vec3(_LightColor0) * vec3(_Color) * max(0.0, dot(normalDirection, lightDirection));

                vec3 specularReflection;
                if (dot(normalDirection, lightDirection) < 0.0)
                {
                    specularReflection = vec3(0.0, 0.0, 0.0);
                }
                else
                {
                    specularReflection = vec3(_LightColor0) * vec3(_SpecColor)
                                        * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection))
                                        , _Shininess);
                }

                gl_FragColor = vec4(ambientLighting + diffuseReflection + specularReflection, 1.0);
            }

            #endif

            ENDGLSL
        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }

            Blend One one

            GLSLPROGRAM

            uniform vec4 _Color;
            uniform vec4 _SpecColor;
            uniform float _Shininess;

            uniform vec3 _WorldSpaceCameraPos;
            uniform mat4 _Object2World;
            uniform mat4 _World2Object;
            uniform vec4 _WorldSpaceLightPos0;

            uniform vec3 _LightColor0;
            uniform mat4 _LightMatrix0; //进入light坐标系
            uniform sampler2D _LightTexture0;

            #ifdef VERTEX

            out vec4 position;
            out vec4 positionInLightSpace;
            out vec3 worldNormalDirection;

            void main()
            {
                mat4 modelMatrix = _Object2World;
                mat4 modelMatrixInverse = _World2Object;

                position = modelMatrix * gl_Vertex;
                positionInLightSpace = _LightMatrix0 * position;
                worldNormalDirection = normalize(vec3(vec4(gl_Normal, 0.0) * modelMatrixInverse));

                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
            }

            #endif

            #ifdef FRAGMENT

            in vec4 position;
            in vec4 positionInLightSpace;
            in vec3 worldNormalDirection;

            void main()
            {
                vec3 normalDirection = normalize(worldNormalDirection);

                vec3 viewDirection = normalize(_WorldSpaceCameraPos - vec3(position));

                vec3 lightDirection;
                float attenuation;

                if (0.0 == _WorldSpaceLightPos0.w)
                {
                    attenuation = 1.0;
                    lightDirection = normalize(vec3(_WorldSpaceLightPos0));
                }
                else
                {
                    vec3 vertexToLightSource = vec3(_WorldSpaceLightPos0 - position);
                    float distance = length(vertexToLightSource);
                    attenuation = 1.0 / distance;
                    lightDirection = normalize(vertexToLightSource);
                }

                vec3 diffuseReflection = attenuation * vec3(_LightColor0) * vec3(_Color)
                                        * max(0.0, dot(normalDirection, lightDirection));

                vec3 specularReflection;
                if (dot(normalDirection, lightDirection) < 0.0)
                {
                    specularReflection = vec3(0.0, 0.0, 0.0);
                }
                else
                {
                    specularReflection = attenuation * vec3(_LightColor0) * vec3(_SpecColor)
                                        * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection))
                                        , _Shininess);
                }

                float cookieAttenuation = 1.0;
                if (0.0 == _WorldSpaceLightPos0.w)  //方向光
                {
                    cookieAttenuation = texture2D(_LightTexture0, vec2(positionInLightSpace)).a;
                }
                else if(1.0 != _LightMatrix0[3][3]) //聚光灯
                {
                    cookieAttenuation = texture2D(_LightTexture0, vec2(positionInLightSpace) / positionInLightSpace.w
                                                    + vec2(0.5)).a;
                }

                gl_FragColor = vec4(cookieAttenuation * (diffuseReflection + specularReflection), 1.0);
            }

            #endif

            ENDGLSL
        }
    }
}