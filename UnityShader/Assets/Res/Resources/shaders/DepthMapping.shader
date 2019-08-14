Shader "Custom/PostEffect/DepthMapping"
{
Properties
{
	_MainTex ("Texture", 2D) = "white" {}
	_DepthTex("Texture", 2D) = "white" {}
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
	// make fog work
	#pragma multi_compile_fog

	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		UNITY_FOG_COORDS(1)
		float4 vertex : SV_POSITION;
		float4 scrPos: TEXCOORD2;
	};

	sampler2D _MainTex;
	sampler2D _DepthTex;
	uniform sampler2D _CameraDepthTexture;
	float4 _MainTex_ST;

	v2f vert (appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		o.scrPos = ComputeScreenPos(o.vertex);
		UNITY_TRANSFER_FOG(o,o.vertex);
		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		// sample the texture
		//fixed depth = Linear01Depth(tex2D(_DepthTex, i.uv).r);
		float depth;
		float3 normal;
		DecodeDepthNormal(tex2D(_DepthTex, i.uv), depth, normal); //该函数将深度纹理中的深度信息和法线信息存储到depth 和normal中
		half rDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);//正常对于非transparent取深度信息
		rDepth = Linear01Depth(rDepth);
		fixed4 col = fixed4(rDepth, rDepth, rDepth, 1);
		//col = tex2D(_CameraDepthTexture, i.uv);
		// apply fog
		UNITY_APPLY_FOG(i.fogCoord, col);
		return col;
	}
	ENDCG
	}
}
Fallback "Diffuse"
}