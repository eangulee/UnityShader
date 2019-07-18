// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Toon/Basic Outline" {
    Properties {
        _Color ("Main Color", Color) = (.5,.5,.5,1)
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _Outline ("Outline width", Range (.002, 0.03)) = .005
        _MainTex ("Base (RGB)", 2D) = "white" { }
        _ToonShade ("ToonShader Cubemap(RGB)", CUBE) = "" { }
    }
    CGINCLUDE
    #include "UnityCG.cginc"
    struct appdata {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
    };
    struct v2f {
        float4 pos : SV_POSITION;
        UNITY_FOG_COORDS(0)
        fixed4 color : COLOR;
    };
    uniform float _Outline;
    uniform float4 _OutlineColor;
    v2f vert(appdata v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        float3 norm   = normalize(mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal));
        float2 offset = TransformViewToProjection(norm.xy);
        #ifdef UNITY_Z_0_FAR_FROM_CLIPSPACE //to handle recent standard asset package on older version of unity (before 5.5)
            o.pos.xy += offset * UNITY_Z_0_FAR_FROM_CLIPSPACE(o.pos.z) * _Outline;
        #else
            o.pos.xy += offset * o.pos.z * _Outline; //核心地方：在处理顶点的时候沿着视线垂直的地方进行向外拉升
        #endif
        o.color = _OutlineColor;
        UNITY_TRANSFER_FOG(o,o.pos);
        return o;
    }
    ENDCG
    SubShader {
        Tags { "RenderType"="Opaque" }
         UsePass "Toon/Basic/BASE"  //引用之前的base pass也就是先作色人物
        Pass {
            Name "OUTLINE"  //命名为outline
            Tags { "LightMode" = "Always" }
            Cull front //剔除正面
            ZWrite On  //打开写缓存
            ColorMask rgb //对rgb颜色值进行蒙板
            Blend SrcAlpha OneMinusSrcAlpha //混合
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_APPLY_FOG(i.fogCoord, i.color);
                return i.color;
            }
            ENDCG
        }
    }
    Fallback "Toon/Basic"
}