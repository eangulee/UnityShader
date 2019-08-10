Shader "Custom/PostEffect/Depth2Pos" {
Properties {
    _MainTex ("Main Texture",2D) = "white" {}
}

SubShader {
    Tags { "RenderType"="Opaque" }
    Cull Off ZWrite Off

    Pass {
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"

        struct appdata_t {
            float4 vertex : POSITION;
            float2 uv: TEXCOORD0;
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float4 uv: TEXCOORD0;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        float4 _MainTex_TexelSize;
        uniform float4x4 _CurrentInverseVP;
        v2f vert (appdata_t v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = float4(v.uv, v.uv);
            #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0)
                    o.uv.xy = float2(v.uv.x, 1-v.uv.y);
            #endif
            return o;
        }

        fixed4 frag (v2f i) : COLOR
        {
            float4 col = tex2D(_MainTex, i.uv.xy);

            float depth = DecodeFloatRGBA(col);
            // 根据深度和当前uv坐标反推当前NDC坐标(注意这个坐标已经经过了齐次除法了)
            float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, depth * 2 - 1, 1); //NDC坐标
            // 根据NDC坐标及View-Projection的逆矩阵，将NDC坐标变换到世界坐标下
            float4 D = mul(_CurrentInverseVP, H);
            float4 W = D / D.w; //将齐次坐标w分量变1得到世界坐标
            // float dis = length(W.xyz);
            // float3 worldPos2 = W.xyz/dis;
            // worldPos2 = worldPos2 * 0.5 + 0.5;
            // return float4(worldPos2,1);
            return W;
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
            float2 uv: TEXCOORD0;
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float4 uv: TEXCOORD0;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        float4 _MainTex_TexelSize;
        uniform float4x4 _CurrentInverseVP;
        v2f vert (appdata_t v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = float4(v.uv, v.uv);
            #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0)
                    o.uv.xy = float2(v.uv.x, 1-v.uv.y);
            #endif
            return o;
        }

        fixed4 frag (v2f i) : COLOR
        {
            float4 col = tex2D(_MainTex, i.uv.xy);
            float depth = DecodeFloatRGBA(col);
            float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, depth * 2 - 1, 1); //NDC坐标
            float4 D = mul(_CurrentInverseVP, H);
            float4 W = D / D.w; //将齐次坐标w分量变1得到世界坐标
            float dis = length(W.xyz);
            float3 worldPos2 = W.xyz/dis;
            worldPos2 = worldPos2 * 0.5 + 0.5;
            return float4(worldPos2,1);
        }
        ENDCG
    }
}
}
