// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/RimLightSurf"{  
Properties {  
    _MainTex ("Base (RGB)", 2D) = "white" {}  
    _Color("Main Color",Color) = (1,1,1,1)
    _InfoTex ("Info Texture (RGB)", 2D) = "white" {}  
    _RimColor("RimColor",Color) = (0,1,1,1)  
    _RimPower ("Rim Power", Range(0.1,8)) = 3.0  
	_LightPos("Light Position", Vector) = (1,1,1,1)
	_Mask ("Alpha Mask", Range(0,1)) = 0.5 
	_Hit ("Hit", Range(0,1)) = 0
	_YLowest ("Y axis lowest position", Range(-1,1)) = 0
	[HideInInspector]_IsBody ("IsBody", Range(0,1)) = 1
	[HideInInspector]_ClipPosition ("Clip Position", Range(0,1)) = 1
	[HideInInspector]_RimLight ("RimLight", Range(0,1)) = 1
}  
SubShader {  
    Tags {"RenderType"="Opaque" }  
    LOD 200  
    CGPROGRAM  
	#pragma multi_compile CLIP_POSITION_OFF CLIP_POSITION_ON
	#pragma multi_compile RIMLIGHT_OFF RIMLIGHT_ON
	#pragma multi_compile BODY_OFF BODY_ON
	#ifdef CLIP_POSITION_ON
		#pragma surface surf Lambert vertex:vert
	#else
		#pragma surface surf Lambert
	#endif
    #include "UnityCG.cginc"
    
    sampler2D _MainTex;
    sampler2D _InfoTex;
    float4 _RimColor;
	float4 _Color;
    float _RimPower;  
	fixed4 _LightPos;
	fixed _Mask;
	fixed _Hit;
	fixed _YLowest;
	
    struct Input {  
        float2 uv_MainTex; 
        fixed3 viewDir;
	#ifdef CLIP_POSITION_ON
		fixed y;
	#endif
	#ifdef RIMLIGHT_ON
		fixed3 viewN;
	#endif
    };
	
	void vert (inout appdata_base v,out Input o) {
		UNITY_INITIALIZE_OUTPUT(Input,o);
	#ifdef CLIP_POSITION_ON
		o.y = mul(unity_ObjectToWorld,v.vertex).y;
	#endif
	#ifdef RIMLIGHT_ON	
		o.viewN = normalize (mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal));
	#endif
	}
  
    void surf (Input IN, inout SurfaceOutput o) {
	#ifdef CLIP_POSITION_ON
		clip(IN.y - _YLowest);
	#endif
        fixed4 tex = tex2D(_MainTex,IN.uv_MainTex);
		fixed4 col = tex * (1-_Hit)* _Color + _Color * _Hit;
        o.Albedo = col;
       
		fixed info;
	#ifdef BODY_ON
			info = tex2D(_InfoTex, IN.uv_MainTex).g;
			//info = tex2D(_InfoTex, IN.uv_MainTex).g;
	#else
			info = tex2D(_InfoTex, IN.uv_MainTex).r;
			//info = tex2D(_InfoTex, IN.uv_MainTex).r;
	#endif
	    fixed m = info - _Mask;
		clip(m);
	#ifdef RIMLIGHT_ON
		if(m > 0){
			fixed3 lightDir = _LightPos.xyz;
			fixed lightDot = dot(lightDir,IN.viewN);
			fixed rim = lightDot > 0 ? (1.0 - saturate (dot (normalize(IN.viewDir), IN.viewN))) : 0;
			o.Emission = _RimColor.rgb * pow (rim, _RimPower);
		}
	#else
		o.Emission = col.rgb;
	#endif
}     
  
    ENDCG         
}   
	FallBack "Diffuse"
	CustomEditor "CharacterMaterialEditor"
}  