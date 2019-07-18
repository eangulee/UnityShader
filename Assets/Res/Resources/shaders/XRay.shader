Shader "Custom/XRay"
{
    Properties
    {
        _MainTex("Base 2D", 2D) = "white" {}
        _XRayColor("XRay Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        CGINCLUDE // 写法二，使用 CGINCLUDE 写好 顶点、片段 着色器，然后各个 Pass 中 使用 CGPROGRAM 指定需要用到的 顶点、片段 着色器
        #include "UnityCG.cginc"
        fixed4 _XRayColor;
        struct v2f
        {
            float4 pos : SV_POSITION;
            float3 normal : NORMAL;
            float3 viewDir : TEXCOORD0;
            fixed4 clr : COLOR;
        };
        v2f vertXray(appdata_base v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.viewDir = ObjSpaceViewDir(v.vertex); // 在 模型空间 上计算夹角
            o.normal = v.normal;
            float3 normal = normalize(v.normal);
            float3 viewDir = normalize(o.viewDir);
            float rim = 1 - dot(normal, viewDir);
            o.clr = _XRayColor * rim;
            return o;
        }
        fixed4 fragXray(v2f i) : SV_TARGET
        {
            return i.clr;
        }
        sampler2D _MainTex;
        float4 _MainTex_ST;
        struct v2f2 
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };
        v2f2 vertNormal(appdata_base v)
        {
            v2f2 o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
            return o;
        }
        fixed4 fragNormal(v2f2 i) : SV_TARGET
        {
            return tex2D(_MainTex, i.uv);
        }
        ENDCG
        Pass // xRay 绘制
        {
            Tags{ "RenderType"="Transparent" "Queue"="Transparent"}
            Blend SrcAlpha One
            ZTest Greater
            ZWrite Off
            Cull Back
            CGPROGRAM
            #pragma vertex vertXray
            #pragma fragment fragXray
            ENDCG
        }
        Pass // 正常绘制
        {
            Tags{ "RenderType"="Opaque" }
            ZTest LEqual
            ZWrite On
            CGPROGRAM
            #pragma vertex vertNormal
            #pragma fragment fragNormal
            ENDCG
        }
    }
}