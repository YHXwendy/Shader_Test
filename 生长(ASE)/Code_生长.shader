Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _Diffuse ("Diffuse", 2D) = "white" {}
        _Normal ("Normal", 2D) = "white" {}
        _Smoothness ("Smoothness", 2D) = "white" {}
        _grow("grow",float) = 0.0
        _grow_min("grow_min",Range(-2,2)) = 0
        _grow_max("grow_max",Range(-2,2)) = 0
        _end_min("end_min",Range(-2,2)) = 0
        _end_max("end_max",Range(-2,2)) = 0
        _Expand("Expand",float) = 0.0
        _Scale("Scale",float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 TEXCOORD : TEXCOORD0;
                float3 Normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 Pos : SV_POSITION;
            };

            sampler2D _Diffuse;
            float4 _Diffuse_ST;
            sampler2D _Normal;
            sampler2D _Smoothness;
            float _grow ;
            float _grow_min;
            float _grow_max;
            float _end_min;
            float _end_max;
            float _Expand;
            float _Scale;
 
            v2f vert (appdata v)
            {
                v2f o;
                float weight_expand =  smoothstep(_grow_min,_grow_max,(v.TEXCOORD.y - _grow));
                float weight_end = smoothstep(_end_min,_end_max,v.TEXCOORD.y);
                float weight_control = max(weight_expand,weight_end);
                float3 grow_offset = v.Normal * weight_control * _Expand * 0.01;
                float3 scale_offset = v.Normal * _Scale * 0.01;
                float3 vertex_offset = grow_offset + scale_offset;
                v.vertex.xyz = v.vertex.xyz + vertex_offset;

                o.Pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.TEXCOORD;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip((i.uv.y-_grow)); 
                fixed4 col = tex2D(_Diffuse, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
