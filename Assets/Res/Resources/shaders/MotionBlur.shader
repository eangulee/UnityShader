Shader "Custom/PostEffect/MotionBlur"
{
   Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlurAmount ("Blur Amount", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        /*CGPROGRAM
        #include "UnityCG.cginc"
        sampler2D _MainTex;
        float4 _MainTex_ST;
        float _BlurAmount;

        struct appdata {
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
            // float3 normal : NORMAL;
        };

        struct v2f {
            float4 pos : POSITION;
            float2 uv : TEXCOORD0;
        };

        // v2f vert (appdata v){
        //     v2f o;
        //     o.pos = UnityObjectToClipPos(v.vertex);
        //     o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
        //     return o;
        // }


        // 更新RGB，当前图像。A通道设为模糊值，方便后面混合
        fixed4 fragRGB (v2f i) : SV_Target {
            return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
        }
        
        // 更新A，直接返回（保护纹理的A通道，不受混合时透明度影响）
        half4 fragA (v2f i) : SV_Target {
            return tex2D(_MainTex, i.uv);
        }
        ENDCG*/
        
        ZTest Always
        Cull Off
        ZWrite Off
        
        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            
            CGPROGRAM
            
            #include "UnityCG.cginc"
            #pragma vertex vert  
            #pragma fragment fragRGB  

            struct appdata {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            // float3 normal : NORMAL;
            };
            struct v2f {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _BlurAmount;
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);  //③获取2d纹理坐标
                // o.cubenormal = mul (UNITY_MATRIX_MV, float4(v.normal,0));
                // UNITY_TRANSFER_FOG(o,o.pos); //④输出雾效的数据
                return o;
            }

            // 更新RGB，当前图像。A通道设为模糊值，方便后面混合
            fixed4 fragRGB (v2f i) : SV_Target {
                return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
            }
            ENDCG
        }
            
        //该pass似乎没有什么用处，渲染了一个Alpha的值
        Pass {
            Blend One Zero//似乎等于自己 源颜色*1 + 目标颜色*0 = 源颜色
            ColorMask A

            CGPROGRAM
            #include "UnityCG.cginc"
            
            #pragma vertex vert  
            #pragma fragment fragA
            struct appdata {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            // float3 normal : NORMAL;
            };
            struct v2f {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);  //③获取2d纹理坐标
                // o.cubenormal = mul (UNITY_MATRIX_MV, float4(v.normal,0));
                // UNITY_TRANSFER_FOG(o,o.pos); //④输出雾效的数据
                return o;
            }

            // 更新A，直接返回（保护纹理的A通道，不受混合时透明度影响）
            half4 fragA (v2f i) : SV_Target {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
