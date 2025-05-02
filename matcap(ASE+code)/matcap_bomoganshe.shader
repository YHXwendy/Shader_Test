Shader "textshader/matcap" //matcap全称 material capture（材质捕捉/映射） 用于提供材质质感——薄膜干涉等 
{
    Properties
    {
        _matcap_materials ("matcap_materials", 2D) = "dump" {}
        _matcap_add("matcap_add",2D) = "dump"{}
        _Tex("_Tex",2D) = "dump"{}
        _matcap_intensity ("matcap_intensity",Range(0,5)) = 1  
        _add_intensity("add_intensity",Range(0,5)) = 1  
        _Tex_intensity("Tex_intensity",Range(0,5)) = 1
        _Ramp_intensity("Ramp_intensity",Range(0,5)) = 1
        _ramp_Tex("ramp_Tex",2D) = "dump"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
         Pass //该pass决定物体是否能被看到内部
        {
            Cull Off
            ZWrite On
            ColorMask 0 //通过ZWrite只写入深度而不写入颜色
            CGPROGRAM
            float4 YHX_Color;
            #pragma vertex verte_YHX;
            #pragma fragment frag_YHX;

            float4 verte_YHX(float4 vertex_position : POSITION):SV_POSITION
            {
                return UnityObjectToClipPos(vertex_position);
            }

            float4 frag_YHX(void): COLOR
            {
                return YHX_Color;
            }
            ENDCG

        }
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal_world : TEXCOORD1;
                float3 pos_world : TEXCOORD2;
            };

            sampler2D _matcap_materials;
            sampler2D _matcap_add;
            sampler2D _Tex;
            sampler2D _ramp_Tex;
            float4 _matcap_materials_ST;
            float _matcap_intensity;
            float _add_intensity;
            float _Tex_intensity;
            float _Ramp_intensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _matcap_materials);
                float3 normal_world = mul(float4(v.normal,0.0),unity_WorldToObject);   
                o.pos_world = mul(unity_ObjectToWorld,v.vertex);
                o.normal_world = normal_world;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal_world = normalize(i.normal_world);
                float3 normal_viewspace = mul(UNITY_MATRIX_V,float4(normal_world,0.0));

                float2 uv_matcap = (normal_viewspace.xy + float2(1.0,1.0)) * 0.5 ;
                half4 matcap_materials = tex2D(_matcap_materials, uv_matcap);
                half4 matcap_add = tex2D(_matcap_add , uv_matcap);
                half4 Main_Tex = tex2D(_Tex , i.uv ) * _Tex_intensity;
                half4 matcap = matcap_materials * _matcap_intensity + matcap_add * _add_intensity ;

                half3 view_dir = _WorldSpaceCameraPos.xyz - i.pos_world;
                half3 NdotV = saturate(dot(normal_world,view_dir));
                float2 uv_ramp = saturate(1 - NdotV).xy;
                half4 ramp_Tex = tex2D(_ramp_Tex,uv_ramp) * _Ramp_intensity;

                half4 col = matcap * Main_Tex * ramp_Tex;
                return col;
            }
            ENDCG
        }
    }
}
