// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
Shader "Custom/PostEffect/ColorAdjustEffect"
{
	Properties 
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Brightness("Brightness", Float) = 1
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
	}

	SubShader
	{
		Pass
		{				
			ZTest Always Cull Off ZWrite Off
			
			CGPROGRAM
			sampler2D _MainTex;
			half _Brightness;
			half _Saturation;
			half _Contrast;

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			struct v2f
			{
				float4 pos : SV_POSITION; //顶点位置
				half2  uv : TEXCOORD0;	  //UV坐标
			};

			v2f vert(appdata_img v)
			{					
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 renderTex = tex2D(_MainTex, i.uv);
				//brigtness亮度直接乘以一个系数，也就是RGB整体缩放，调整亮度
				fixed3 finalColor = renderTex * _Brightness;
				//saturation饱和度：首先根据公式计算同等亮度情况下饱和度最低的值：
				fixed gray = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
				fixed3 grayColor = fixed3(gray, gray, gray);
				//根据Saturation在饱和度最低的图像和原图之间差值
				finalColor = lerp(grayColor, finalColor, _Saturation);
				//contrast对比度：首先计算对比度最低的值
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				//根据Contrast在对比度最低的图像和原图之间差值
				finalColor = lerp(avgColor, finalColor, _Contrast);
				return fixed4(finalColor, renderTex.a);
			}
			ENDCG
		}
	}
	//防止shader失效
	FallBack Off
}