// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader"textshader/rim"
{
    Properties
    {
        YHX_Float("Emiss",Float)=1.0
        //YHX_Range("范围",Range(0.0,1.0))=0.0
        //YHX_Vector("向量",Vector)=(1,1,1,1)
        YHX_Color("颜色",Color)=(1,1,1,1) 
        YHX_Texture("贴图",2D)="white"{}
        Rim_Power("RimPower",Float)=1.0
        [Enum(UnityEngine.Rendering.CullMode)]YHX_culledit("CullMode",float)=2
    }
    Subshader
    {
        Tags { 
        "Queue"="Transparent" 
        "RenderType"="Transparent" 
            } 
        
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
            ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha
            Blend SrcAlpha One
            Cull [YHX_culledit]
            CGPROGRAM
            #pragma vertex verte_YHX
            #pragma fragment frag_YHX
            #include "UnityCG.cginc"

            float4 YHX_Color;
            sampler2D YHX_Texture;
            float4 YHX_Texture_ST;
            float YHX_Float;
            float Rim_Power;

            struct appdata
            {
                float4 vertex_position :POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                // float2 uv2 : TEXCOORD1;
                // float2 uv3 : TEXCOORD2;
                // float2 uv4 : TEXCOORD3;//最多写四套uv
                // float3 normal : NORMAL;
                //color : COLOR;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal_world : TEXCOORD1; //通用的储存器or插值器 可放任何类型数据 TEXCOORD0~TEXCOORD15 共16条可用
                float3 normal_view : TEXCOORD2;
                // float3 normal :TEXCOORD1;
            };

            v2f verte_YHX(appdata v)
            {
                v2f _out;
                // float4 pos_world = mul(unity_ObjectToWorld,v.vertex_position);
                // float4 pos_view = mul(UNITY_MATRIX_V,pos_world);
                // float4 pos_projection = mul(UNITY_MATRIX_P,pos_view);
                _out.position = UnityObjectToClipPos(v.vertex_position);
                //_out.position = pos_projection;
                float3 pos_world = mul(unity_ObjectToWorld,v.vertex_position).xyz;
                _out.normal_world = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                _out.normal_view = normalize(_WorldSpaceCameraPos.xyz - pos_world);
                _out.uv = v.uv * YHX_Texture_ST.xy + YHX_Texture_ST.zw;
                return _out;  
            }
           
            float4 frag_YHX(v2f f,bool isFrontFace : SV_IsFrontFace):SV_Target //布尔型的 isFrontFace : SV_IsFrontFace 用于在下方通过判断正反，将反面法线转为正面，以此使得背面能够适用边缘光效果
            {
                float3 normal_world = normalize(f.normal_world);
                float3 normal_view = normalize(f.normal_view);
                if (!isFrontFace) {
                    normal_world = -normal_world;
                }
                float NdotV = saturate(dot(normal_world,normal_view));
                float rim = pow(saturate(1.0 - abs(NdotV)),Rim_Power);

                float3 col = YHX_Color.xyz * YHX_Float;
                half alpha = saturate(tex2D(YHX_Texture,f.uv).r * YHX_Color.a*YHX_Float);//saturate限制结果在0~1
                return float4(col,rim);
                 
            }
            //float 32位 坐标点
            //half 16位 UV、大部分向量
            //fixed 8位 颜色 （不常用）
            ENDCG
        }
    }
}