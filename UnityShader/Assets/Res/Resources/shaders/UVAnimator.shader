Shader "Custom/UVAnimator"
{
	Properties
	{
		_Color("Base Color", Color) = (1,1,1,1)
		_MainTex("Base(RGB)", 2D) = "white" {}
	    _Speed("Speed",Float) = 10
		_SizeX("Col", Float) = 4
		_SizeY("Row",Float) = 4
	}

		SubShader
	{
	    
		Blend SrcAlpha OneMinusSrcAlpha
		Cull off
		LOD 100
	
		Pass
	{
		CGPROGRAM
#pragma vertex vert  
#pragma fragment frag  
#include "UnityCG.cginc"  

	float4 _Color;
	sampler2D _MainTex;
	fixed _Speed;
	fixed _SizeX;
	fixed _SizeY;

	struct v2f
	{
		float4 pos:POSITION;
		float4 uv:TEXCOORD0;
	};

	struct appdata {
		float4 vertex : POSITION;
		float4 texcoord : TEXCOORD;
	};

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;

		return o;
	}


	float2 AnimationUV(float2 uv) {

		float sX = 1.0 / _SizeX; // 每列的宽度
		float sY = 1.0 / _SizeY; // 每行的宽度

		// 把图片一行一列
		uv.x *= sX;
		uv.y *= sY;

		//  Column列    Row行   floor对参数向下取整   _Speed 每秒播放帧的次数
		float col = floor(_Time.y *_Speed / _SizeX);
		float row = floor(_Time.y *_Speed - col * _SizeX); // 转换到左上角为原点
		uv.x += row * sX;
		uv.y += col * sY;

		return uv;
	}

	half4 frag(v2f i) :COLOR
	{
		half4 c = tex2D(_MainTex , AnimationUV(i.uv.xy)) * _Color;
		return c;
	}

		ENDCG
	}
	}
}
