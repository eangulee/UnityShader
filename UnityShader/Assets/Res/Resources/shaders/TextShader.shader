Shader "Custom/UI/Text" 
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)

        //描边
        _OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineWidth ("Outline Width", Range(0, 1)) = 0

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
			Name "TextEffect"

            CGPROGRAM
            #pragma multi_compile __ GRAYED
            #pragma multi_compile __ GRAYBLEND
            // #pragma multi_compile __ OUTLINE
            #pragma vertex vert
            #pragma fragment frag

			sampler2D _MainTex;
			fixed4 _Color;
			fixed4 _TextureSampleAdd;
			float4 _MainTex_TexelSize;

			float4 _OutlineColor;
			float _OutlineWidth;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
                float2 uvOriginXY : TEXCOORD1;
                float2 uvOriginZW : TEXCOORD2;
				fixed4 color : COLOR;
			};

			v2f vert(appdata IN)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(IN.vertex);
				o.texcoord = IN.texcoord;
                o.uvOriginXY = IN.texcoord1;
                o.uvOriginZW = IN.texcoord2;
				o.color = IN.color * _Color;

				return o;
			}

			fixed IsInRect(float2 pPos, float2 pClipRectXY, float2 pClipRectZW)
			{
				pPos = step(pClipRectXY, pPos) * step(pPos, pClipRectZW);
				return pPos.x * pPos.y;
			}

            fixed SampleAlpha(int pIndex, v2f IN)
            {
                const fixed sinArray[12] = { 0, 0.5, 0.866, 1, 0.866, 0.5, 0, -0.5, -0.866, -1, -0.866, -0.5 };
                const fixed cosArray[12] = { 1, 0.866, 0.5, 0, -0.5, -0.866, -1, -0.866, -0.5, 0, 0.5, 0.866 };
                float2 pos = IN.texcoord + _MainTex_TexelSize.xy * float2(cosArray[pIndex], sinArray[pIndex]) * _OutlineWidth;
				return IsInRect(pos, IN.uvOriginXY, IN.uvOriginZW) * (tex2D(_MainTex, pos) + _TextureSampleAdd).w * _OutlineColor.w;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                
                #ifdef GRAYED
                fixed grey = fixed3(0.299, 0.587, 0.114);
                color.rgb = fixed3(grey, grey, grey);
                #endif
                
                #ifdef GRAYBLEND
                fixed grey = dot(color.rgb, fixed3(0.299, 0.587, 0.114));
                color.rgb = fixed3(grey, grey, grey);
                #endif

                // #ifdef OUTLINE
                if(_OutlineWidth > 0)
                {
                    color.w *= IsInRect(IN.texcoord, IN.uvOriginXY, IN.uvOriginZW);
                    half4 val = half4(_OutlineColor.x, _OutlineColor.y, _OutlineColor.z, 0);

                    val.w += SampleAlpha(0, IN);
                    val.w += SampleAlpha(1, IN);
                    val.w += SampleAlpha(2, IN);
                    val.w += SampleAlpha(3, IN);
                    val.w += SampleAlpha(4, IN);
                    val.w += SampleAlpha(5, IN);
                    val.w += SampleAlpha(6, IN);
                    val.w += SampleAlpha(7, IN);
                    val.w += SampleAlpha(8, IN);
                    val.w += SampleAlpha(9, IN);
                    val.w += SampleAlpha(10, IN);
                    val.w += SampleAlpha(11, IN);

                    val.w = clamp(val.w, 0, 1);
                    color = (val * (1.0 - color.a)) + (color * color.a);
                }
                // #endif
  
                return color;
            }
            ENDCG
        }
    }
}