

Shader "Custom/VectorLine" {
Properties {
    // _MainTex ("Main Texture", 2D) = "white" {}    
    _LineWidth ("Line Width",Float) = 2
    _Color("Line Color", Color) = (1,0,0,1)
    _CameraDir ("Camera Direction", Vector) = (0,1,0,0)
}

SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 300
    Pass {
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #pragma target 2.0

        #include "UnityCG.cginc"

        struct appdata {
            float4 vertex : POSITION;
            float2 uv:TEXCOORD0;
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float2 uv:TEXCOORD0;
            float4 color: COLOR;
        };

        // sampler2D _MainTex;
        // float4 _MainTex_ST;
        float _LineWidth;
        fixed4 _Color;
        float4 _CameraDir;
        // float3 start;
        // float3 end;

        // float4 trimSegment(fixed4 start){
        //     // trim end segment so it terminates between the camera plane and the near plane

        //     // conservative estimate of the near plane
        //     float a = UNITY_MATRIX_P[2][2]; // 3nd entry in 3th column
        //     float b = UNITY_MATRIX_P[3][2]; // 3nd entry in 4th column
        //     float nearEstimate = - 0.5 * b / a;

        //     float alpha = ( nearEstimate - start.z ) /( end.z - start.z );

        //     end.xyz = lerp( start.xyz, end.xyz, alpha );
        //     return float4(end, 1.0);
        // }


        v2f vert (appdata v)
        {
            v2f o;

            // 计算相机空间坐标
            /*float4 cameraStart = mul(UNITY_MATRIX_M, float4( start.rgb, 1.0 ));
            float4 cameraEnd = mul(UNITY_MATRIX_M, float4( end.rgb, 1.0 ));

            if ( cameraStart.z < 0.0 && cameraEnd.z >= 0.0 ) {
               cameraEnd = trimSegment(cameraStart);
            } else if ( cameraEnd.z < 0.0 && cameraStart.z >= 0.0 ) {
               cameraStart = trimSegment(cameraEnd);
            }

            // 计算裁剪空间坐标
            float4 clipStart = mul(UNITY_MATRIX_P, cameraStart);
            float4 clipEnd = mul(UNITY_MATRIX_P, cameraEnd); 

            // 将裁剪空间坐标转换到标准设备空间
            float2 ndcStart = clipStart.xy / clipStart.w;
            float2 ndcEnd = clipEnd.xy / clipEnd.w;

            // 将标准设备空间坐标转换的屏幕空间
            float2 screenStart = float2( 0, 0 );
            screenStart.x = ( ndcStart.x + 1.0 ) * _ScreenParams.x * 0.5;
            screenStart.y = ( ndcStart.y + 1.0 ) * _ScreenParams.y * 0.5;

            float2 screenEnd = float2( 0, 0 );
            screenEnd.x = ( ndcEnd.x + 1.0 ) * _ScreenParams.x * 0.5;
            screenEnd.y = ( ndcEnd.y + 1.0 ) * _ScreenParams.y * 0.5;

            // 在屏幕空间扩展点
            float2 dir = screenEnd - screenStart;
            float l = length( dir );
            dir = normalize( dir ) * v.vertex.x;

            screenStart += float2( dir.y, -dir.x ) * v.vertex.y * _LineWidth * 0.5;

            // 将屏幕坐标转换到标准设备空间
            ndcStart.x = ( screenStart.x * 2.0 - _ScreenParams.x ) / _ScreenParams.x;
            ndcStart.y = ( screenStart.y * 2.0 - _ScreenParams.y ) / _ScreenParams.y;

            // 将标准设备空间坐标转换到裁剪空间
            clipStart.x = ndcStart.x * clipStart.w;
            clipStart.y = ndcStart.y * clipStart.w;*/

            // float4 world = float4(_WorldSpaceCameraPos + _CameraDir.xyz * (_ProjectionParams.y + 0.1),1.0);
            // float4 clipPos = mul(UNITY_MATRIX_VP, world);

            // float4 screenPos = v.vertex;//顶点xy即为屏幕空间的位置x=[0,width],y=[0,height]
            //将屏幕坐标转换到标准设备空间 x=[-1,1],y=[-1,1]
            // float2 ndcPos = float2(1.0,1.0);
            // ndcPos.xy = (screenPos.xy * 2.0 - _ScreenParams.xy) / _ScreenParams.xy;

            o.vertex = UnityObjectToClipPos(v.vertex);
            // 将标准设备空间坐标转换到裁剪空间
            // float4 screenPos = float4(0, 0, -(_ProjectionParams.y + _ProjectionParams.z) / 2,1.0);
            // clipPos.w = -clipPos.z;
            // clipPos.xy = ndcPos.xy * clipPos.w;
            // float4 modelPos = mul(clipPos, UNITY_MATRIX_IT_MV);

            // clipPos.xy = ndcPos.xy * clipPos.w;
            // pos.w = _LineWidth;// * _ProjectionParams.w * 1000 * pos.z;


            o.vertex.z = (_ProjectionParams.y + _ProjectionParams.z) / 4;
            // o.vertex.xyz *= _LineWidth;

            // o.vertex.w = -o.vertex.z;
            // o.vertex = clipPos;
            // o.vertex = UnityObjectToClipPos(v.vertex);
            // o.vertex.w = clipPos.w;

            o.uv = v.uv;
            o.color = v.vertex;
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            // fixed4 textureCol = tex2D(_MainTex,i.uv);
            // fixed4 col = fixed4(_Color.rgb,1.0);
            // col = lerp(textureCol,col,textureCol.a);
            // return _Color;
            return i.color;
        }
    ENDCG
    }
}
}
