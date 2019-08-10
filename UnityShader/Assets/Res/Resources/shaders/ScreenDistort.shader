
//全屏幕扭曲Shader
 
Shader "Custom/PostEffect/ScreenDistort"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_NoiseTex("Base (RGB)", 2D) = "black" {}//默认给黑色，也就是不会偏移
	}
 
	CGINCLUDE
	#include "UnityCG.cginc"
	uniform sampler2D _MainTex;
	uniform sampler2D _NoiseTex;
	uniform float _DistortTimeFactor;
	uniform float _DistortStrength;
 
	fixed4 frag(v2f_img i) : SV_Target
	{
		//根据时间改变采样噪声图获得随机的输出
		float4 noise = tex2D(_NoiseTex, i.uv - _Time.xy * _DistortTimeFactor);
		//以随机的输出*控制系数得到偏移值
		float2 offset = noise.xy * _DistortStrength;
		//像素采样时偏移offset
		float2 uv = offset + i.uv;
		return tex2D(_MainTex, uv);
	}
 
	ENDCG
 
	SubShader
	{
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off
			Fog{ Mode off }
 
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest 
			ENDCG
		}
	}
	Fallback off
}