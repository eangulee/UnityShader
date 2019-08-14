//通过深度图重建世界坐标，视口射线插值方式
Shader "Custom/PostEffect/ReconstructPositionViewPortRay" 
{
	CGINCLUDE
	#include "UnityCG.cginc"
	#pragma enable_d3d11_debug_symbols  //需要断点调试的Shader加上的
	sampler2D _CameraDepthTexture;
	float4x4 _ViewPortRay;
	
	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float4 rayDir : TEXCOORD1;
		float3 depth: TEXCOORD2;
	};
	
	v2f vertex_depth(appdata_base v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		//该点的深度信息:-(UnityObjectToViewPos( v.vertex ).z * _ProjectionParams.w)
		//_ProjectionParams.w = 1 / far
		o.depth.x = COMPUTE_DEPTH_01;
		//用texcoord区分四个角，就四个点，if无所谓吧
		int index = 0;
		if (v.texcoord.x < 0.5 && v.texcoord.y > 0.5)
			index = 0;
		else if (v.texcoord.x > 0.5 && v.texcoord.y > 0.5)
			index = 1;
		else if (v.texcoord.x < 0.5 && v.texcoord.y < 0.5)
			index = 2;
		else
			index = 3;
		
		o.rayDir = _ViewPortRay[index];
		return o;
	}
	
	fixed4 frag_depth(v2f i) : SV_Target
	{
		// float depthTextureValue = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
		// float linear01Depth = Linear01Depth(depthTextureValue);
		i.depth.y = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
		i.depth.z = Linear01Depth(i.depth.y);
		// i.depth.x = Linear01Depth(i.depth.x);
		#if defined(UNITY_REVERSED_Z)
		i.depth.x = 1 - i.depth.x;
		#endif
		//worldpos = campos + 射线方向 * depth
		float3 worldPos = _WorldSpaceCameraPos + i.depth.x * normalize(i.rayDir.xyz);
		// worldPos = float3(i.depth.x,i.depth.x,i.depth.x);
		//世界坐标
        float dis = length(worldPos.xyz);
        float3 worldPos2 = worldPos.xyz/dis;
        worldPos2 = worldPos2 * 0.5 + 0.5;
        return float4(worldPos2,dis * 0.01);
		// return fixed4(worldPos, 1.0);
	}
	ENDCG
 
	SubShader
	{
		Tags {"RenderType" = "Opaque"}
		Pass
		{
			ZTest Off
			Cull Off
			ZWrite Off
			Fog{ Mode Off }
 
			CGPROGRAM
			#pragma vertex vertex_depth
			#pragma fragment frag_depth
			ENDCG
		}
	}
	SubShader
	{
		Tags {"RenderType" = "Transparent"}
		Pass
		{
			ZTest Off
			Cull Off
			ZWrite Off
			Fog{ Mode Off }
 
			CGPROGRAM
			#pragma vertex vertex_depth
			#pragma fragment frag_depth
			ENDCG
		}
	}
}