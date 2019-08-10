Shader "Custom/GeometryLearn"
{
	Properties
	{
		Height("SingleH",float)=0.01
	}
	SubShader
	{
		Pass
		{
			Tags
			{
				"RenderType"="Opaque"
			}
			
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS_Main
			#pragma geometry GS_Main
			#pragma fragment FS_Main
			#include "UnityCG.cginc"			
			float Height;
			struct GS_INPUT
			{
				float4 pos:POSITION;
			};			
			struct FS_INPUT
			{
				float4 pos:SV_POSITION;
			};			
			
			GS_INPUT VS_Main(appdata_base v)
			{
				GS_INPUT output;
				output.pos = v.vertex;
				return output;
			};

			//vs的输出作为gs的输入
			[maxvertexcount(3)]
			//输入 point line triangle lineadj triangleadj----输出: PointStream只显示点，
			//LineStream只显示线，TriangleStream全显
			void GS_Main(triangle GS_INPUT p[3],inout LineStream<FS_INPUT> triStream)
			{
				for(int i=0;i<3;i++)
				{
					FS_INPUT output;
					//读取原来的点，这里不做改变
					float4 pos = float4(p[i].pos.x,p[i].pos.y,p[i].pos.z,p[i].pos.w);								
					output.pos = UnityObjectToClipPos(pos);
					if(pos.y < Height)
					{
					  triStream.Append(output);
					}
				}
				triStream.RestartStrip();
			}

			//gs的输出作为fs的输入
			float4 FS_Main(FS_INPUT i):COLOR
			{
				return fixed4(1,1,1,1);
			}			
			ENDCG
		}
	}
}