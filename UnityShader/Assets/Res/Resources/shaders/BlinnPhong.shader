Shader "Custom/Blinn_Phong"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SpecularTex("_SpecularTex", 2D) = "white" {}//控制哪一部分会有高光：脸蛋，布料上千万别有高光，金属，陶瓷，皮具，甲克可以有高光。
		_SpecularGloss("_SpecularGloss", range(0.001, 100)) = 30//光斑大小，和本值成反比

		[Toggle] _IsBlinn("_IsBlinn", int) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float2 uv : TEXCOORD0;
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;//裁剪空间下的顶点坐标
				float2 uv : TEXCOORD0;//纹理
				float3 worldNormal : TEXCOORD1;//世界空间下的法线
				float3 vertexWorldPos : TEXCOORD2;//世界空间下的顶点坐标
			};

			uniform sampler2D _MainTex;
			uniform sampler2D _SpecularTex;
			uniform float4 _MainTex_ST;
			uniform fixed _SpecularGloss;
			uniform int _IsBlinn;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.vertexWorldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.vertexWorldPos.xyz);
				fixed3 useDir;
				if (_IsBlinn)//实际代码中不能这么写，因为shader会执行流程控制语句中的每一行代码
				{
					//Blinn-Phong光照模型
					fixed3 halfDir = normalize(worldLight + viewDir);//单位矩阵相加的方向为两矩阵间的中心方向
					useDir = halfDir;
				}
				else
				{
					//Phong光照模型
					fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));//reflect函数求反射角方向
					useDir = reflectDir;
				}
				fixed3 specular = _LightColor0.rgb * pow(saturate(dot(worldNormal, useDir)), _SpecularGloss) * tex2D(_SpecularTex, i.uv).r;

				color.rgb += specular;
				return color;
			}
			ENDCG
		}
	}
}