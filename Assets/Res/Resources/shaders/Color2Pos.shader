Shader "Custom/PostEffect/Color2Pos" {
Properties {
    _MainTex ("Main Texture",2D) = "white" {}
}

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
                float4 uv: TEXCOORD0;
                float4 color:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = (mul(UNITY_MATRIX_M,v.vertex) * 0.1 + 1) * 0.5;
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
                fixed4 col = tex2D(_MainTex,i.uv);
                return i.color;
            }
        ENDCG
    }
}

}
