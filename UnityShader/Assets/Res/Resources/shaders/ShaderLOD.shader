Shader "Custom/LODShader" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    // 每次只会根据情况来选择一个可执行的SubShader
    // 找到第一个<= Shader.maximumLOD 这个subShader执行;
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 600 // LOD-----------------这里设置为600
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o) {
            o.Albedo = fixed3(1.0, 0.0, 0.0);
        }
        ENDCG
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 500 // LOD-----------------这里设置为500
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o) {
            o.Albedo = fixed3(0.0, 1.0, 0.0);
        }
        ENDCG
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD -10 // LOD-----------------这里设置为任意值，负数都可以，找到第一个<= Shader.maximumLOD 这个subShader执行;
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o) {
            o.Albedo = fixed3(0.0, 0.0, 1.0);
        }
        ENDCG
    }
    FallBack "Diffuse"
}