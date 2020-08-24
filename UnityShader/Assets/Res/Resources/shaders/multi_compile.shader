Shader "Custom/multi_compile"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AColor ("A Color", Color) = (1,1,1,1)
        _BColor ("B Color", Color) = (1,1,1,1)
        _TEST_2 ("TEST_2", Range(0,1)) = 1
        _TEST_4 ("TEST_4", Range(0,1)) = 1
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
                float4 color : TEXCOORD1;
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
                o.color = float4(1,1,1,1);
                #ifdef TEST_2
                o.color *= _AColor;
                #endif
                #ifdef TEST_4
                o.color *= _BColor;
                #endif
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                #ifdef TEST_2
                col *= i.color;
                #endif
                #ifdef TEST_4
                col *= i.color;
                #endif
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "Multi_compileEditor"
}
