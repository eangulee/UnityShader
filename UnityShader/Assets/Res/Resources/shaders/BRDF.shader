
Shader "Custom/BRDF"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SpecTex("SpecTex (RGB)", 2D) = "white" {}
		_SpecColor("SpecColor", Color) = (1,1,1,1)
 
		_Roughness("Roughness", Range(0.0, 10.0)) = 1
		_Albedo("Albedo (RGB)", 2D) = "white" {}
		_Metallic("Metallic", Range(0.0, 10.0)) = 1
 
		_GGX_V_Transition("GGX V Transition", Range(0.0001, 10.0)) = 0.0001
    }
	SubShader{
 
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent"}
		Pass
		{
			Tags{ "LightMode" = "ForwardBase"}//设置光照类型
			Blend SrcAlpha OneMinusSrcAlpha   //开启颜色混合模式
 
			CGPROGRAM
			#pragma vertex vert                  //vextex着色器阶段
			#pragma fragment frag                //fragment着色器阶段
			#include "UnityCG.cginc" 
 
			sampler2D _MainTex;
			float4 _MainTex_ST;
 
			fixed4 _Color;
 
			sampler2D _SpecTex;
			sampler2D _Albedo;
			fixed _Metallic;
 
			fixed4 _SpecColor;
 
			fixed _Roughness;
			half _GGX_V_Transition;
 
			//定义输入顶点着色器阶段的数据结构  
			struct Input
			{
				float4 vertex : POSITION;       //顶点位置
				float4 texcoord : TEXCOORD0;    //纹理坐标
				float4 normal : NORMAL;    
				float2 uv : TEXCOORD1;
			};
 
			//定义顶点着色器阶段输出的数据结构
			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float3 normalWorld : NORMAL;
				float4 posWorld : TEXCOORD1;
 
			};
 
			//输出v2f到下一渲染阶段
			v2f vert(Input v)
			{
				v2f o;
 
				o.pos = UnityObjectToClipPos(v.vertex);
				float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
 
				float3 normalWorld = normalize(UnityObjectToWorldNormal(v.normal));
 
				o.uv = v.uv;
				o.normalWorld = normalWorld;
				o.posWorld = posWorld;
 
				return o;
			}
 
			half doubleNumber(half num)
			{
				return num * num;
			}
 
			half fiveNumber(half num)
			{
				return num * num * num * num * num;
			}
 
			half GGX(half dotX)
			{
				half k = doubleNumber(_Roughness + 1) / 8;
				return dotX / (k + (1 - k) * dotX);
			}
 
			fixed4 frag(v2f i) :SV_TARGET
			{
 
				half3 lightDirWorld = normalize(_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
				half3 viewDirWorld = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);
 
				half3 halfDir = normalize(lightDirWorld + viewDirWorld);
				half NdotL = saturate(dot(i.normalWorld, lightDirWorld));
				half NdotH = saturate(dot(i.normalWorld, halfDir));
				half NdotV = saturate(dot(i.normalWorld, viewDirWorld));
 
				float4 mainTex = tex2D(_MainTex, i.uv) * _Color;
				float4 specTex = tex2D(_SpecTex, i.uv) * _SpecColor;
				float3 metalliTex = tex2D(_Albedo, i.uv).rgb;
 
				half pi = 3.1415926;
 
				half D = doubleNumber(_Roughness) / (pi * doubleNumber(doubleNumber(NdotH) * (doubleNumber(_Roughness) - 1) + 1));
				
				half3 F0 = metalliTex * _Metallic + (1 - _Metallic) * half3(0.04, 0.04, 0.04);
				
				half F = F0 + (1 - F0) * (1 - fiveNumber(NdotH));
 
				half lambertNL = NdotL * 0.5 + 0.5;
				half V = (GGX(NdotL) * GGX(NdotV)) / (4 * lambertNL * NdotV);
 
				half kdiff = F0;
				half kSpec = (1 - F0) * (1 - _Metallic);
 
				float3 brdf = (kdiff * mainTex.rgb / pi + kSpec * V * F * D);
				
				return fixed4(brdf.rgb, 1);
			}
			ENDCG
		}
	}
}