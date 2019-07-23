// /https://gamedev.stackexchange.com/questions/156902/how-can-i-create-an-outline-shader-for-a-plane
Shader "Custom/PlaneOutlineOnePass" {
Properties {
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _Color ("Color", Color) = (1,1,1,1)
    _Expand("Expand",Range(1,1.5)) = 1.2
    _Thickness ("Thickness",Range(1,10)) = 2
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
            float2 texcoord : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float2 texcoord : TEXCOORD0;
            UNITY_FOG_COORDS(1)
            UNITY_VERTEX_OUTPUT_STEREO
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        fixed4 _Color;
        float _Expand;
        float _Thickness;

        v2f vert (appdata v)
        {
            v2f o;
            // Slightly enlarge our quad, so we have a margin around it to draw the outline.
            // float expand = 1.1f;
            v.vertex.xyz *= _Expand;
            o.vertex = UnityObjectToClipPos(v.vertex);
            // If we want to get fancy, we could compute the expansion 
            // dynamically based on line thickness & view angle, but I'm lazy)

            // Expand the texture coordinate space by the same margin, symmetrically.
            o.texcoord = (v.texcoord - 0.5f) * _Expand + 0.5f;
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            // Texcoord distance from the center of the quad.
            float2 fromCenter = abs(i.texcoord - 0.5f);
            // Signed distance from the horizontal & vertical edges.
            float2 fromEdge = fromCenter - 0.5f;

            // Use screenspace derivatives to convert to pixel distances.
            fromEdge.x /= length(float2(ddx(i.texcoord.x), ddy(i.texcoord.x)));
            fromEdge.y /= length(float2(ddx(i.texcoord.y), ddy(i.texcoord.y)));

            // Compute a nicely rounded distance from the edge.
            float distance = abs(min(max(fromEdge.x,fromEdge.y), 0.0f) + length(max(fromEdge, 0.0f)));

            // Sample our texture for the interior.
            i.texcoord = (i.texcoord - 0.5f)/_Expand + 0.5f;
            i.texcoord /= _Expand;
            fixed4 col = tex2D(_MainTex, i.texcoord);
            // Clip out the part of the texture outside our original 0...1 UV space.
            col.a *= step(max(fromCenter.x, fromCenter.y), 0.5f);

            // Blend in our outline within a controllable thickness of the edge.
            col = lerp(col, _Color, saturate(_Thickness - distance));

            return col;
        }
        ENDCG
    }
}
}