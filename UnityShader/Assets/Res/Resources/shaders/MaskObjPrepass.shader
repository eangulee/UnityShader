// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//mask shader
Shader "Custom/MaskObjPrepass"
{
	//子着色器	
	SubShader
	{
		Pass
		{	
			Cull Off
			CGPROGRAM
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos : SV_POSITION;
			};
			
			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				//这个Pass直接输出颜色
				return fixed4(1,1,1,1);
			}
			
			//使用vert函数和frag函数
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}