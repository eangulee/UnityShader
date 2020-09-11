// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Custom/UI/Flowlight-Texture"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _FlowLightTex ("Flow Light Texture", 2D) = "white" {}
        _XOffset ("X Offset", Range(-1,1)) = 0
        _Speed ("_Speed", Float) = 1
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                // float2 flowLightUV : TEXCOORD2;
                // float2 maskUV : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;

            // sampler2D _FlowLightTex;
            // float4 _FlowLightTex_ST;
            // sampler2D _MaskTex;
            // float4 _MaskTex_ST;
            // float _Speed;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                // OUT.flowLightUV = TRANSFORM_TEX(v.texcoord, _FlowLightTex);
                // OUT.maskUV = TRANSFORM_TEX(v.texcoord, _MaskTex);
                // //mask uv 流动
                // OUT.flowLightUV = OUT.flowLightUV - float2(_Speed,0) * _Time.x + float2(_Speed,0);

                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                //流动UV采样
                // half4 flowLightColor = tex2D(_FlowLightTex, IN.flowLightUV);
                // half4 mask = tex2D(_MaskTex, IN.maskUV);
                // flowLightColor.a *= mask.r;
                // if(flowLightColor.a > 0)
                // {
                //     color.rgb *= flowLightColor.rgb;
                // }
                return color;
            }
        ENDCG
        }

        Pass
        {
            Name "FlowLight"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                float2 uv  : TEXCOORD2;
            };

            sampler2D _FlowLightTex;
            float4 _FlowLightTex_ST;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;

            float _Speed;
            float _XOffset;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _FlowLightTex);
                OUT.uv = TRANSFORM_TEX(v.texcoord, _MaskTex);
                OUT.texcoord = OUT.texcoord - float2(_Speed,0) * _Time.x + float2(_Speed,0);
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_FlowLightTex, IN.texcoord));
                half4 mask = (tex2D(_MaskTex, IN.uv));
                color *= mask.r;
                return color;
            }
        ENDCG
        }
    }
}
