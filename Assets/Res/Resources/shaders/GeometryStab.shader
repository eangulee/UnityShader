///尖刺效果
Shader "Custom/GeometryStab"
{
	Properties
	{
	    _Color("MianColor",color)=(1,1,1,1)
		_Length("Length", Range(0.01, 10)) = 0.02
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100 
		Pass
		{
		Cull Off
			CGPROGRAM
			#pragma target 4.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom			
			#include "UnityCG.cginc" 
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			}; 
			struct v2g
			{
				float4 vertex : POSITION;
				float3 nor:NORMAL;
			};
			struct g2f
			{
				float4 vertex : SV_POSITION;
				float3 norg:NORMAL;
			};
			float _Length;
			fixed4 _LightColor0;
			fixed4 _Color;
			v2g vert(appdata_base v)
			{
				v2g o;
				o.vertex = v.vertex;
				o.nor=v.normal;
				return o;
			}
 
			void ADD_VERT(float3 v,g2f o,inout TriangleStream<g2f> tristream)
			{
	           o.vertex = UnityObjectToClipPos(v); 
	           tristream.Append(o);
			}

	        void ADD_TRI(float3 p0,float3 p1,float3 p2,g2f o,inout TriangleStream<g2f> tristream)
			{
	            ADD_VERT(p0,o,tristream);
			    ADD_VERT(p1,o,tristream);
	            ADD_VERT(p2,o,tristream);
	            tristream.RestartStrip();
			}

			//指定一个面最多顶点数
			[maxvertexcount(9)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> tristream)
			{
				g2f o; 
				//--------计算原模型三角面的法线
				float3 edgeA = IN[1].vertex - IN[0].vertex;
				float3 edgeB = IN[2].vertex - IN[0].vertex;
				float3 normalFace = normalize(cross(edgeA, edgeB));//叉积计算法线方向
				//-------
	            o.norg=-normalFace;
				//根据模型三角面信息额外生成一个向外突出的锥体
				float3 v0 = IN[0].vertex;
				float3 v1 = IN[1].vertex;
				float3 v2 = IN[2].vertex;
				float3 v3 = (IN[0].vertex+IN[1].vertex+IN[2].vertex)/3 + normalFace * _Length;				
				ADD_TRI(v0,v3,v2,o,tristream);
				ADD_TRI(v0,v1,v3,o,tristream);
				ADD_TRI(v2,v3,v1,o,tristream);
			}

			fixed4 frag (g2f i) : SV_Target
			{
				//实现简单的Lambert光照
				float3 LightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseColor = _LightColor0 * max(dot(i.norg, LightDir), 0);
				return _Color * float4(diffuseColor,1);
				// return _Color;
			}
			ENDCG
		}
	}
}