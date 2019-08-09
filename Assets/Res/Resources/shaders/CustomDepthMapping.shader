//定制自己的 Depth Texture
Shader "Custom/PostEffect/CustomDepthMapping"{

SubShader {
	Tags{ "RenderType" = "Transparent" }
	Cull Off
	Pass{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		struct appdata{
			float4 vertex : POSITION;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			float depth : TEXCOORD0;
		};
		//代码中标记为错误的原因是，在投影空间中计算深度的，但是投影空间中的z值不是线性变化的。
		//修改以后的正确版本，是在摄像机空间计算深度，0为眼睛位置的深度，1为远平面的深度。这样就和UnityCG中的效果一致了。
		v2f vert(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			// o.depth = o.pos.z; // 这是错误的
			o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z; // 这是正确的
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			// 这是错误的
		    // float n = _ProjectionParams.y;
		    // float f = _ProjectionParams.z;
		    // float c = (i.depth - n) / f;
		    // return c;
			// 这是正确的
		    float f = _ProjectionParams.z;
		    float c = i.depth / f;
		    // return float4(c,c,c,1.0);
		    return EncodeFloatRGBA(c);
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
		struct appdata{
			float4 vertex : POSITION;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			float depth : TEXCOORD0;
		};

		v2f vert(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			// o.depth = o.pos.z; // 这是错误的
			o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z; // 这是正确的
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			// 这是错误的
		    // float n = _ProjectionParams.y;
		    // float f = _ProjectionParams.z;
		    // float c = (i.depth - n) / f;
		    // return c;
			// 这是正确的
		    float f = _ProjectionParams.z;
		    float c = i.depth / f;
		    // return float4(c,c,c,1.0);
		    return EncodeFloatRGBA(c);
		}
		ENDCG
		}
	}
//Fallback "Diffuse"
}