Shader "Custom/WaterRipple" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _Color ("Water Color", Color) = (0.2, 0.6, 1, 0.5)
        _Speed ("Wave Speed", Range(0,5)) = 1.0
        _Distortion ("Distortion", Range(0,2)) = 0.3
        _Specular ("Specular", Range(0,10)) = 5
        _BumpScale ("Normal Scale", Range(0,3)) = 1.0
    }

    SubShader {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200
        Cull off
        GrabPass { "_BackgroundTexture" }

        CGPROGRAM
        #pragma surface surf SimpleSpecular alpha vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _BackgroundTexture;
        fixed4 _Color;
        float _Speed;
        float _Distortion;
        float _Specular;
        float _BumpScale;

        struct Input {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float4 screenPos;
        };

        struct SurfaceOutputCustom {
            fixed3 Albedo;
            fixed3 Normal;
            fixed3 Emission;
            fixed Alpha;
            fixed3 Specular;
        };

        void vert (inout appdata_full v) {
            // 添加基础顶点动画
            float wave = sin(_Time.y * _Speed + v.vertex.x * 2 + v.vertex.z * 3) * 0.1;
            v.vertex.y += wave;
        }

        void surf (Input IN, inout SurfaceOutputCustom o) {
            // 计算动画UV
            float2 uv = IN.uv_MainTex;
            float2 uv2 = IN.uv_BumpMap;
            uv.x += _Time.x * _Speed * 0.2;
            uv.y += _Time.x * _Speed * 0.3;
            uv2.x += _Time.x * _Speed * 0.1;
            uv2.y += _Time.x * _Speed * 0.4;

            // 混合两个法线贴图
            half3 normal = UnpackNormal(tex2D(_BumpMap, uv)) * _BumpScale;
            half3 normal2 = UnpackNormal(tex2D(_BumpMap, uv2)) * _BumpScale;
            o.Normal = normalize((normal + normal2) * 0.5);

            // 屏幕空间UV计算
            float2 screenUV = (IN.screenPos.xy / IN.screenPos.w);
            #if UNITY_UV_STARTS_AT_TOP
            screenUV.y = 1 - screenUV.y;
            #endif

            // 应用法线扰动
            float2 offset = o.Normal.xy * _Distortion * 0.1;
            fixed4 bgColor = tex2D(_BackgroundTexture, screenUV + offset);

            // 最终颜色混合
            o.Albedo = bgColor.rgb * _Color.rgb;
            o.Specular = _Specular;
            o.Alpha = _Color.a;
            o.Emission = bgColor.rgb * 0.2;
        }

        half4 LightingSimpleSpecular (SurfaceOutputCustom s, half3 lightDir, half3 viewDir, half atten) {
            half3 h = normalize (lightDir + viewDir);
            half diff = max (0, dot (s.Normal, lightDir));
            
            float nh = max (0, dot (s.Normal, h));
            float spec = pow (nh, 32.0) * s.Specular;
            
            half4 c;
            c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
            c.a = s.Alpha;
            return c;
        }
        ENDCG
    }
    FallBack "Diffuse"
}