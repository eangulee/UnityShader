// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Unlit shader. Simplest possible textured shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Custom/PolygonOutline" {
Properties {
    _Expand ("Thickness",Range(0,1.5)) = 0.1
    _OutlineCol ("Outline Color", Color) = (0,1,0,1)
}

SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 300
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
            float3 dir = v.vertex.xyz;
            dir = normalize(dir);
            float dis = 1;//length(v.vertex.xyz);
            v.vertex.xyz += dis * dir *_Expand;
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
