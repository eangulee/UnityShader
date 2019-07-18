// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Toon/Basic" {
    Properties {
        _Color ("Main Color", Color) = (.5,.5,.5,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _ToonShade ("ToonShader Cubemap(RGB)", CUBE) = "" { }
    }
    SubShader {
        Tags { "RenderType"="Opaque" } //渲染不透明物体
        Pass {
            Name "BASE" //pass的名字，这个后续的shader会用到
            Cull Off  //双面渲染
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog  //①编译多种雾效的类型
            #include "UnityCG.cginc"
            sampler2D _MainTex; 
            samplerCUBE _ToonShade;
            float4 _MainTex_ST;
            float4 _Color;
            struct appdata {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };
            struct v2f {
                float4 pos : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                float3 cubenormal : TEXCOORD1;
                UNITY_FOG_COORDS(2) //②获取fog的坐标
            };
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);  //③获取2d纹理坐标
                o.cubenormal = mul (UNITY_MATRIX_MV, float4(v.normal,0));
                UNITY_TRANSFER_FOG(o,o.pos); //④输出雾效的数据
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _Color * tex2D(_MainTex, i.texcoord);
                fixed4 cube = texCUBE(_ToonShade, i.cubenormal);
                fixed4 c = fixed4(2.0f * cube.rgb * col.rgb, col.a);
                UNITY_APPLY_FOG(i.fogCoord, c);  //⑤i.fogcoord是从顶点数据取出来的一个2维的纹理坐标
                return c;
            }
            ENDCG           
        }
    } 
    Fallback "VertexLit"
}