//1. Transparent
//2. Rim
//3. Intersection Highlight
Shader "Kaima/Depth/ForceField"
{
	Properties
	{
		_MainColor("Main Color", Color) = (1,1,1,1)
		_RimPower("Rim Power", Range(0, 1)) = 1
		_IntersectionPower("Intersect Power", Range(0, 1)) = 0
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldViewDir : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				float eyeZ : TEXCOORD3;
				float2 uv : TEXCOORD4;
			};

			sampler2D _CameraDepthTexture;
			fixed4 _MainColor;
			float _RimPower;
			float _IntersectionPower;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldDir(v.normal);//对象空间的法线转换到世界空间的法线
				o.worldViewDir = UnityWorldSpaceViewDir(worldPos);//世界空间的视方向（worldPos - cameraPos）
				o.screenPos = ComputeScreenPos(o.vertex);//得到屏幕空间坐标
				COMPUTE_EYEDEPTH(o.eyeZ);//深度值
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldViewDir = normalize(i.worldViewDir);
				//法线与视方向的夹角计算边缘光强度
				float rim = 1 - saturate(dot(worldNormal, worldViewDir)) * _RimPower;

				float screenZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));	
				//计算相交，越靠近，值越大
				float intersect = (1 - (screenZ - i.eyeZ)) * _IntersectionPower;
				float v = max (rim, intersect);

				return _MainColor * v;
			}
			ENDCG
		}
	}
}
