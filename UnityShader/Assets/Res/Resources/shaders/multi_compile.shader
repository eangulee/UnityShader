Shader "Custom/multi_compile"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AColor ("A Color", Color) = (1,1,1,1)
        _BColor ("B Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            // #pragma multi_compile __ TEST_1;
            #pragma multi_compile TEST_1 TEST_2;
            #pragma multi_compile_local TEST_3 TEST_4;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _AColor;
            float4 _BColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                #ifdef TEST_1
                col *= _AColor;
                #endif
                #ifdef TEST_3
                col *= _BColor;
                #endif
                return col;
            }
            ENDCG
        }
    }
}
