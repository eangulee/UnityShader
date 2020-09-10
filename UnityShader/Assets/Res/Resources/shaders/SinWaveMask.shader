Shader "Custom/SinWave"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _MaskColor ("Mask Color", Color) = (0.5,0.5,0.5,0.5)
    }
    SubShader
    {
        Tags { "RenderType"="Transprent" "Queue"="Transparent"}
        
        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float4 _MaskColor;
            float _Offset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // 振幅（控制波浪顶端和底端的高度）
                float amplitude = 0.05;
                
                // 角速度（控制波浪的周期）
                float angularVelocity = 10.0;
                
                // 频率（控制波浪移动的速度）
                float frequency = 10.0;
                
                // 偏距（设为 0.5 使得波浪垂直居中于屏幕）
                float offset = _Offset;
                
                // 初相位（正值表现为向左移动，负值则表现为向右移动）
                float initialPhase = frequency * _Time.y;
                
                // 代入正弦曲线公式计算 y 值
                // y = Asin(ωx ± φt) + k
                float y = amplitude * sin((angularVelocity * i.uv.x) + initialPhase) + offset;
                
                // 大于y的叠加mask color
                if (i.uv.y > y) {
                    col *= _MaskColor;
                }

                return col;
            }
            ENDCG
        }
    }
}
