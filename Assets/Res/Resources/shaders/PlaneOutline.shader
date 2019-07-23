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
    _Outline ("Outline Width", Range(1,1.5)) = 1.2
    _OutlineCol ("Outline Color", Color) = (0,1,0,1)
}

SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 300

    Pass {

        //模板测试总是通过，并写入模板缓存区值为1
        Stencil
        {
            Ref 1
            Comp always
            Pass replace
            Fail keep
            ZFail keep
        }

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

        struct appdata_t {
            float4 vertex : POSITION;
        };

        struct v2f {
            float4 vertex : SV_POSITION;
        };

        float _Outline;
        fixed4 _OutlineCol;

        v2f vert (appdata_t v)
        {
            v2f o;
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            float4x4 model = unity_ObjectToWorld;
            //这里对原模型进行放大，放大的区域的模板值不为1，测试通过，原区域模板值为1，无法通常测试
            //这样就会只留下放大的区域，实现了外边框
            float4x4 world = UNITY_MATRIX_V;//对view matrix(视图矩阵)进行缩放
            world[0][0] = world[0][0] * _Outline;//对x轴缩放
            world[1][1] = world[1][1] * _Outline;//对y轴缩放
            world[2][2] = world[2][2] * _Outline;//对z轴缩放
            //将顶点转换到裁剪空间
            o.vertex = mul(UNITY_MATRIX_P,mul(world,mul(unity_ObjectToWorld,v.vertex)));
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            return _OutlineCol;
        }
    ENDCG
    }
}

}
