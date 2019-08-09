Shader "Custom/PostEffect/Color2Pos" {
// Properties {
//     _MainTex ("Main Texture",2D) = "white" {}
// }

SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 300

    Pass {
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #pragma target 2.0

        #include "UnityCG.cginc"

        struct appdata_t {
            float4 vertex : POSITION;
            float4 uv: TEXCOORD0;
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float2 uv: TEXCOORD0; 
            float4 worldPos : TEXCOORD1;
        };

        // sampler2D _MainTex;
        // float4 _MainTex_ST;
        float4 _MainTex_TexelSize;

        v2f vert (appdata_t v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            //当有多个RenderTarget时，需要自己处理UV翻转问题
        #if UNITY_UV_STARTS_AT_TOP //处于DX
            if(_MainTex_TexelSize.y < 0)
                o.uv = float2(v.uv.x, 1-v.uv.y);
            else
                o.uv = v.uv;
        #else
            o.uv = v.uv;
        #endif
            o.worldPos =  mul(unity_ObjectToWorld, v.vertex);
            // o.color = (mul(UNITY_MATRIX_M,v.vertex) * 0.1 + 1) * 0.5;
            return o;
        }

        float4 frag (v2f i) : SV_Target
        {
            //世界坐标
            float dis = length(i.worldPos.xyz);
            float3 worldPos2 = i.worldPos.xyz/dis;
            worldPos2 = worldPos2 * 0.5 + 0.5;
            return float4(worldPos2,dis * 0.01);
            // return i.color;
        }
        ENDCG
    }
}

SubShader {
    Tags { "RenderType"="TransparentCutout" }
    LOD 300

    Pass {
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #pragma target 2.0

        #include "UnityCG.cginc"

        struct appdata_t {
            float4 vertex : POSITION;
            float4 uv: TEXCOORD0;
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float2 uv: TEXCOORD0; 
            float4 worldPos : TEXCOORD1;
        };

        // sampler2D _MainTex;
        // float4 _MainTex_ST;
        float4 _MainTex_TexelSize;

        v2f vert (appdata_t v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            //当有多个RenderTarget时，需要自己处理UV翻转问题
        #if UNITY_UV_STARTS_AT_TOP //处于DX
            if(_MainTex_TexelSize.y < 0)
                o.uv = float2(v.uv.x, 1-v.uv.y);
            else
                o.uv = v.uv;
        #else
            o.uv = v.uv;
        #endif
            o.worldPos =  mul(unity_ObjectToWorld, v.vertex);
            // o.color = (mul(UNITY_MATRIX_M,v.vertex) * 0.1 + 1) * 0.5;
            return o;
        }

        float4 frag (v2f i) : SV_Target
        {
            //世界坐标
            float dis = length(i.worldPos.xyz);
            float3 worldPos2 = i.worldPos.xyz/dis;
            worldPos2 = worldPos2 * 0.5 + 0.5;
            return float4(worldPos2,dis * 0.01);
            // return i.color;
        }
        ENDCG
    }
}

SubShader {
    Tags { "RenderType"="Transparent" }
    LOD 300

    Pass {
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #pragma target 2.0

        #include "UnityCG.cginc"

        struct appdata_t {
            float4 vertex : POSITION;
            float4 uv: TEXCOORD0;
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float2 uv: TEXCOORD0;
            float4 worldPos : TEXCOORD1;
        };

        // sampler2D _MainTex;
        // float4 _MainTex_ST;
        float4 _MainTex_TexelSize;

        v2f vert (appdata_t v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            //当有多个RenderTarget时，需要自己处理UV翻转问题
        #if UNITY_UV_STARTS_AT_TOP //处于DX
            if(_MainTex_TexelSize.y < 0)
                o.uv = float2(v.uv.x, 1-v.uv.y);
            else
                o.uv = v.uv;
        #else
            o.uv = v.uv;
        #endif
            o.worldPos =  mul(unity_ObjectToWorld, v.vertex);
            // o.color = (mul(UNITY_MATRIX_M,v.vertex) * 0.1 + 1) * 0.5;
            return o;
        }

        float4 frag (v2f i) : SV_Target
        {
            // fixed4 col = tex2D(_MainTex,i.uv);
            //世界坐标
            float dis = length(i.worldPos.xyz);
            float3 worldPos2 = i.worldPos.xyz/dis;
            worldPos2 = worldPos2 * 0.5 + 0.5;
            return float4(worldPos2,dis * 0.01);
            // return i.color;
        }
        ENDCG
    }
}
}
