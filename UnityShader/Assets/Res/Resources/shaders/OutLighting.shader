// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/OutLighting"  //Shader文件索引路径
{
    // 属性
    Properties
    {
        _MainTex("Texture(RGB)", 2D) = "grey" {} //表面贴图 默认灰色
        _Color("Color", Color) = (0, 0, 0, 1)    //为贴图附加的颜色 默认为白色
        _AtmoColor("Atmosphere Color", Color) = (0, 0.4, 1.0, 1)    //光晕颜色
        _Size("Size", Float) = 0.1 //光晕范围
        _OutLightPow("Falloff",Float) = 5 //光晕平方参数
        _OutLightStrength("Transparency", Float) = 15 //光晕强度
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
    }

    SubShader
    {
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        ZWrite On
        ZTest LEqual

        Pass //通道1 用于给物体贴图、填色
        {
            Name "PlaneBase"
            Tags{ "LightMode" = "Always" }
            Cull Back
            //CG程序开始
            CGPROGRAM
            //声明顶点着色器函数为vert
            #pragma vertex vert
            //声明片段着色器函数为frag
            #pragma fragment frag
            #include "UnityCG.cginc"
            //函数可能用到的参数
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float4 _Color;
            uniform float4 _AtmoColor;
            uniform float _Size;
            uniform float _OutLightPow;
            uniform float _OutLightStrength;
            //顶点着色器的输出
            struct vertexOutput
            {
                float4 pos:SV_POSITION;
                float3 normal:TEXCOORD0;
                float3 worldvertpos:TEXCOORD1;
                float2 texcoord:TEXCOORD2;
            };
            //顶点着色器函数
            vertexOutput vert(appdata_base v)
            {
                vertexOutput o;
                // 顶点位置
                o.pos = UnityObjectToClipPos(v.vertex);
                // 法线
                o.normal = v.normal;
                // 世界坐标顶点位置
                // o.worldvertpos = mul(unity_ObjectToWorld, v.vertex).xyz;
                // 纹理uv
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            //片段着色器函数
            float4 frag(vertexOutput i) :COLOR
            {   
                float4 color = tex2D(_MainTex, i.texcoord);
                //i.normal = normalize(i.normal);
                ////视角法线
                //float3 viewdir = normalize(i.worldvertpos.xyz - _worldspacecamerapos.xyz);// normalize(i.worldvertpos - _worldspacecamerepos);
                //float4 color0 = _atmocolor;
                ////视角法线与模型法线点积形成中间指为1向四周逐渐衰减为0的点积值，赋给透明通道，形成光晕效果
                //color0.a = _outlightpow*(1 - dot(viewdir, i.normal));
                //color.rgb = lerp(color.rgb, color0.rgb, color0.a);
                // 纹理贴图叠加颜色
                return color * _Color;
            }
            ENDCG
        }

        //通道2： 用于生成模型外部的光晕
        Pass
        {
            Name "AtmosphereBase"
            Tags{ "LightMode" = "Always" }
            Cull Front
            Blend SrcAlpha One 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            uniform float4 _Color;
            uniform float4 _AtmoColor;
            uniform float _Size;
            uniform float _OutLightPow;
            uniform float _OutLightStrength;

            struct vertexOutput
            {
                float4 pos:SV_POSITION;
                float3 normal:TEXCOORD0;
                float3 worldvertpos:TEXCOORD1;
            };

            vertexOutput vert(appdata_base v)
            {
                vertexOutput o;
                //顶点位置以法线方向向外延伸
                v.vertex.xyz += v.normal*_Size;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.worldvertpos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag(vertexOutput i):COLOR
            {
                i.normal = normalize(i.normal);
                //视角法线
                float3 viewdir = normalize(i.worldvertpos.xyz - _WorldSpaceCameraPos.xyz);// normalize(i.worldvertpos - _WorldSpaceCamerePos);
                float4 color = _AtmoColor;
                //视角法线与模型法线点积形成中间指为1向四周逐渐衰减为0的点积值，赋给透明通道，形成光晕效果
                color.a = pow(saturate(dot(viewdir, i.normal)), _OutLightPow);
                color.a *= _OutLightStrength*dot(viewdir, i.normal);
                return color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}