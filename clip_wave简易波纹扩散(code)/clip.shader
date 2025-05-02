// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader"textshader/clipshader"
{
    Properties
    {
        YHX_Float("数量",Float)=0.0
        YHX_Range("范围",Range(0.0,1.0))=0.0
        YHX_Vector("向量",Vector)=(1,1,1,1)
        YHX_Color("颜色",Color)=(0.5,0.5,0.5,0.5) 
        YHX_Texture("贴图",2D)="red"{}
        _NoiseTex("_NoiseTex",2D)="white"{}
        CutOut("剪裁",Range(-1.1,1.1))=0.0
        Speed("旋转速度",Vector)=(1,1,0,0)
         [Enum(UnityEngine.Rendering.CullMode)]YHX_culledit("CullMode",float)=2
    }
    Subshader
    {

        Pass
        {
            Cull [YHX_culledit] 
            CGPROGRAM
            #pragma vertex verte_YHX
            #pragma fragment frag_YHX
            #include "UnityCG.cginc"

            float4 YHX_Color;
            sampler2D YHX_Texture;
            float4 YHX_Texture_ST;
            float CutOut;
            float4 Speed;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            struct appdata
            {
                float4 vertex_position :POSITION;
                float2 uv : TEXCOORD0;
                // float2 uv2 : TEXCOORD1;
                // float2 uv3 : TEXCOORD2;
                // float2 uv4 : TEXCOORD3;//最多写四套uv
                // float3 normal : NORMAL;
                //color : COLOR;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0; //通用的储存器or插值器 可放任何类型数据 TEXCOORD0~TEXCOORD15 共16条可用
                float2 pos_uv : TEXCOORD1;
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
                _out.uv = v.uv * YHX_Texture_ST.xy + YHX_Texture_ST.zw;
                _out.pos_uv = v.vertex_position.zy * YHX_Texture_ST.xy + YHX_Texture_ST.zw;
                return _out;  
            }
            float4 frag_YHX(v2f f):SV_Target
            {
                float4 gradient = tex2D(YHX_Texture,f.uv + _Time.y*Speed.xy).r;
                half noise = tex2D(_NoiseTex,f.uv + _Time.y*Speed.zw).r;
                clip(gradient-noise-CutOut);
                return YHX_Color  ; // gradient.xxxx = float4(gradient,gradient,gradient,gradient);
                //return float4(f.uv,0.0,0.0);
                 
            }
            //float 32位 坐标点
            //half 16位 UV、大部分向量
            //fixed 8位 颜色 （不常用）
            ENDCG
        }
    }
}