// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//用于深度摄像机替换透明和不透明的渲染shader，暂无用处
Shader "Custom/PostEffect/CopyDepth" {

SubShader{
	Tags{ "RenderType" = "Transparent" }//需要替换的渲染类型 可以将此类型设置为你需要获取深度纹理材质的类型 这里我用的是Transparent
	Cull Off
	Pass{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		struct v2f {
			float4 pos : SV_POSITION;
			float4 nz : TEXCOORD0;
		};
		v2f vert(appdata_base v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.nz.xyz = COMPUTE_VIEW_NORMAL;//该点的法线信息
			o.nz.w = COMPUTE_DEPTH_01;//该点的深度信息
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			//clip(_Color.a-0.01);
			return EncodeDepthNormal(i.nz.w, i.nz.xyz);
		}
		ENDCG
		}
	}

	SubShader{
	Tags{ "RenderType" = "Opaque" }
		Cull Off
		Pass{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		struct v2f {
			float4 pos : SV_POSITION;
			float4 nz : TEXCOORD0;
		};

		v2f vert(appdata_base v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.nz.xyz = COMPUTE_VIEW_NORMAL; //该点的法线信息
			o.nz.w = COMPUTE_DEPTH_01;//该点的深度信息
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			// return EncodeDepthNormal(i.nz.w, i.nz.xyz);
			return fixed4(1.0,0.0,0.0,1.0);
		}
		ENDCG
		}
	}
//Fallback "Diffuse"
}