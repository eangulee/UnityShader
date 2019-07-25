// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Unlit shader. Simplest possible textured shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Custom/PolygonBase" {
Properties {
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _Color ("Color", Color) = (1,1,1,1)
}

SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 300

    Pass {
        //------------关键代码---------
        //模板测试总是通过，并写入模板缓存区值为1
        Stencil
        {
            Ref 1
            Comp always
            Pass replace
            Fail keep
            ZFail keep
        }
        //------------关键代码---------

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #pragma target 2.0

        #include "UnityCG.cginc"

        struct appdata_t {
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float2 texcoord : TEXCOORD0;
            UNITY_FOG_COORDS(1)
            UNITY_VERTEX_OUTPUT_STEREO
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        fixed4 _Color;

        v2f vert (appdata_t v)
        {
            v2f o;
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.texcoord);
            col = col * _Color;
            UNITY_OPAQUE_ALPHA(col.a);
            return col;
        }
        ENDCG
    }
}
}
