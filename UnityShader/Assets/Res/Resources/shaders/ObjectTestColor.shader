// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ObjectTestColor"
{
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" 
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex object_vert
            #pragma fragment object_frag
        
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 clippos : TEXCOORD0;  
                float4 worldPos : TEXCOORD1;  
                float4 depth : TEXCOORD2;  
            };
            
            v2f object_vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.clippos = o.vertex;
                o.depth.x = COMPUTE_DEPTH_01;
                o.worldPos =  mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
            
            fixed4 object_frag (v2f i) : SV_Target
            {
                //NDC深度
                //fixed4 ndc = i.clippos / i.clippos.w ;
                //float d = ndc * 0.5 + 0.5 ;
                //return fixed4(d,d,d,1);

                //View空间深度
                //float viewdDepth = i.depth.x * 10;
                //return fixed4(viewdDepth,viewdDepth,viewdDepth,1)   ;

                //世界坐标
                float dis = length(i.worldPos.xyz);
                float3 worldPos2 = i.worldPos.xyz/dis;
                worldPos2 = worldPos2 * 0.5 + 0.5;
                return fixed4(worldPos2,1);
            }
            ENDCG
        }
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex object_vert
            #pragma fragment object_frag
        
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 clippos : TEXCOORD0;  
                float4 worldPos : TEXCOORD1;  
                float4 depth : TEXCOORD2;  
            };
            
            v2f object_vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.clippos = o.vertex ;
                o.depth.x = COMPUTE_DEPTH_01;
                o.worldPos =  mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
            
            fixed4 object_frag (v2f i) : SV_Target
            {
                //NDC深度
                //fixed4 ndc = i.clippos / i.clippos.w ;
                //float d = ndc * 0.5 + 0.5 ;
                //return fixed4(d,d,d,1);

                //View空间深度
                //float viewdDepth = i.depth.x * 10;
                //return fixed4(viewdDepth,viewdDepth,viewdDepth,1)   ;

                //世界坐标
                float dis = length(i.worldPos.xyz);
                float3 worldPos2 = i.worldPos.xyz/dis;
                worldPos2 = worldPos2 * 0.5 + 0.5;
                return fixed4(worldPos2,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}