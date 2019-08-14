//基于深度的扫描效果
Shader "Custom/PostEffect/ScreenDepthScan" 
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
	sampler2D _CameraDepthTexture;
	sampler2D _MainTex;
	fixed4 _ScanLineColor;
	float _ScanValue;
	float _ScanLineWidth;
	float _ScanLightStrength;
	
	float4 frag_depth(v2f_img i) : SV_Target
	{
		float depthTextureValue = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);//非线性的值
		//Z（视空间01） = Z(视空间) / F = 1 /((N - F)/ N) * depth + F / N）
		//Z（视空间01） = 1 / (param1 * depth + param2)，param1 = (N - F)/ N = 1 - F/N，param2 = F / N
		// Z buffer to linear 0..1 depth
		//inline float Linear01Depth(float z)
		//{
		//		//_ZBufferParams	float4	Used to linearize Z buffer values. 
		//		//x is (1-far/near), y is (far/near), z is (x/far) and w is (y/far).
		//		return 1.0 / (_ZBufferParams.x * z + _ZBufferParams.y);
		//}
		float linear01EyeDepth = Linear01Depth(depthTextureValue);//转换到线性空间下[0,1]
		fixed4 screenTexture = tex2D(_MainTex, i.uv);
		
		if (linear01EyeDepth > _ScanValue && linear01EyeDepth < _ScanValue + _ScanLineWidth)
		{
			return screenTexture * _ScanLightStrength * _ScanLineColor;
		}
		return screenTexture;
	}
	ENDCG
 
	SubShader
	{
		Pass
		{
			ZTest Off
			Cull Off
			ZWrite Off
			Fog{ Mode Off }
 
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_depth
			ENDCG
		}
	}
}