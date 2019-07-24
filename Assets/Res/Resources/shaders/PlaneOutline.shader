// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Unlit shader. Simplest possible textured shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Custom/PlaneOutline" {
Properties {
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _Color ("Color", Color) = (1,1,1,1)
    //------------关键代码---------
    _Expand ("Thickness",Range(1,1.5)) = 1.1
    _OutlineCol ("Outline Color", Color) = (0,1,0,1)
    //------------关键代码---------
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

    //------------关键代码---------
    Pass {
        //模板缓存区的值与1比较，不相同即测试失败，并保持缓存区的值不变
        Stencil
        {
            Ref 1
            Comp notequal
            Pass decrWrap
            Fail keep
            ZFail keep
        }

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #pragma target 2.0

        #include "UnityCG.cginc"

        struct appdata {
            float4 vertex : POSITION;
        };

        struct v2f {
            float4 vertex : SV_POSITION;
        };

        fixed4 _OutlineCol;
        float _Expand;
        //https://gamedev.stackexchange.com/questions/156902/how-can-i-create-an-outline-shader-for-a-plane
        v2f vert (appdata v)
        {
            v2f o;
            v.vertex.xyz *= _Expand;
            o.vertex = UnityObjectToClipPos(v.vertex);
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            return _OutlineCol;
        }
    ENDCG
    }
    //------------关键代码---------
}
}
