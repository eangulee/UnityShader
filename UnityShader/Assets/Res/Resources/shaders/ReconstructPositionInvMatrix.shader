//通过逆矩阵的方式从深度图构建世界坐标
Shader "Custom/PostEffect/ReconstructPositionInvMatrix" 
{
	CGINCLUDE
	#include "UnityCG.cginc"
	sampler2D _CameraDepthTexture;
	float4x4 _InverseVPMatrix;
	
	fixed4 frag_depth(v2f_img i) : SV_Target
	{
		float depthTextureValue = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
		//自己操作深度的时候，需要注意Reverse_Z的情况
		#if defined(UNITY_REVERSED_Z)
		depthTextureValue = 1 - depthTextureValue;
		#endif
		// 已知条件（M为VP矩阵，M^-1即为其逆矩阵，Clip为裁剪空间，ndc为标准设备空间，world为世界空间）：
		// ndc = Clip.xyzw / Clip.w = Clip / Clip.w
		// world = M^-1 * Clip
		// 二者结合得：
		// world = M ^-1 * ndc * Clip.w
		// 我们已知M和ndc，然而还是不知道Clip.w，但是有一个特殊情况，是world的w坐标，经过变换后应该是1，即
		// 1 = world.w = （M^-1 * ndc）.w * Clip.w
		// 进而得到Clip.w = 1 / （M^ -1 * ndc）.w
		// 带入上面等式得到：
		// world = （M ^ -1 * ndc） / （M ^ -1 * ndc）.w
		// 所以，世界坐标就等于ndc进行VP逆变换之后再除以自身的w。
		float4 ndc = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, depthTextureValue * 2 - 1, 1);
		float4 worldPos = mul(_InverseVPMatrix, ndc);
		worldPos /= worldPos.w;

		//世界坐标
        float dis = length(worldPos.xyz);
        float3 worldPos2 = worldPos.xyz/dis;
        worldPos2 = worldPos2 * 0.5 + 0.5;
        return float4(worldPos2,dis * 0.01);
		// return worldPos;
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