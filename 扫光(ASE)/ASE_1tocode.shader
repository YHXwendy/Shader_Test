Shader "testshader/ASE_1tocode"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RimMin("RimMin",Range(-1,1)) = 0
        _RimMax("RimMax",Range(0,2)) = 0
        _emiss_pow("EmissPow",Range(-5,5)) = 0
        _InnerColor("InnerColor",color) = (0,0,0,0)
        _RimColor("RimColor",color) = (0,0,0,0)
        _Rim_intensity("rimColor_intensity",Range(-2,10)) = 0 
        _scan_tilling("scan_tilling",Vector) = (1,1,0,0)
        _Scan_Speed("Scan_Speed",Vector) = (1,1,0,0)
        _Scan_Tex("Scan_Tex",2D) = "white"{}
        _scan_intensity("scan_intensity",Range(0,5)) = 0
        _InnerAlpha("InnerAlpha",Range(-5,5)) = 0
    }
    SubShader
    {
        Tags { "Queue"= "Transparent"}
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
            Zwrite Off
            Blend SrcAlpha One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 tex_uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 pos_world: TEXCOORD1;
                float3 normal_world : TEXCOORD2;
                float3 pivot : TEXCOORD3;
            };

            sampler2D _MainTex; 
            float4 _MainTex_ST;
            float _RimMin;
            float _RimMax;
            float _emiss_pow;
            float4 _InnerColor;
            float4 _RimColor;
            float _Rim_intensity;
            float4 _scan_tilling;
            float4 _Scan_Speed;
            sampler2D _Scan_Tex;
            float _scan_intensity;
            float _InnerAlpha;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 normal_world = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                float3 pos_world = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normal_world = normal_world;
                o.pos_world = pos_world;
                o.pivot = mul(unity_ObjectToWorld,float4( 0.0,0.0,0.0,1.0).xyz); 
                o.uv = v.tex_uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 normal_world = normalize(i.normal_world);
                half3 view_world = normalize(_WorldSpaceCameraPos.xyz - i.pos_world); 
                half3 NdotV = saturate(dot(normal_world,view_world));
                half3 fresnel = 1.0 - NdotV;
                fresnel = smoothstep(_RimMin,_RimMax,fresnel);
                half emiss = tex2D(_MainTex, i.uv).r; 
                emiss = pow(emiss,_emiss_pow);

                half3 final_fresnel = saturate(fresnel + emiss) ;

                half3 RimColor = lerp(_InnerColor.xyz * _Rim_intensity,_RimColor.xyz * _Rim_intensity,final_fresnel);
                half final_RimAlpha = final_fresnel;

                float uv_scan = (i.pos_world.yx - i.pivot.yx)*_scan_tilling.yx;
                uv_scan = uv_scan + _Time.y * _Scan_Speed.yx;
                float4  scan = tex2D(_Scan_Tex,uv_scan);
                float4 final_scan = scan * _scan_intensity;

                float3 col = saturate((final_scan.xyz + RimColor));
                float alpha = saturate(final_scan.a + final_RimAlpha + _InnerAlpha);
                return float4(col,alpha);
                //return float4(RimColor,final_RimAlpha);
            }
            ENDCG
        }
    }
}
