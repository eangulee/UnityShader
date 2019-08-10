Shader "Custom/GPUInstance"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags{ "RenderType" = "Opaque" }
        LOD 300

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing //necessary
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID //necessary
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID // necessary only if you want to access instanced properties in fragment Shader.
            };

                UNITY_INSTANCING_BUFFER_START(Props)//necessary
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color)//necessary
                UNITY_INSTANCING_BUFFER_END(Props)//necessary

                v2f vert(appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);//necessary
                UNITY_TRANSFER_INSTANCE_ID(v, o); // necessary only if you want to access instanced properties in the fragment Shader.
                // 推荐使用UnityObjectToClipPos，替代 instead of mul(UNITY_MATRIX_MVP,v.vertex)
                // 官方UnityObjectToClipPos is the most efficient way to transform vertex positions from object space into clip space
                o.vertex = UnityObjectToClipPos(v.vertex); 
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i); // necessary only if any instanced properties are going to be accessed in the fragment Shader.
                return  UNITY_ACCESS_INSTANCED_PROP(Props, _Color);// necessary
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
