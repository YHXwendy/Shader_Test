Shader "Custom/DynamicSDF" {
    Properties {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _BorderColor ("Border Color", Color) = (0,0,0,1)
        _BorderWidth ("Border Width", Range(0,0.1)) = 0.02
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed4 _MainColor;
            fixed4 _BorderColor;
            float _BorderWidth;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // 圆形SDF
            float circleSDF(float2 p, float2 center, float radius) {
                return length(p - center) - radius;
            }

            // 矩形SDF
            float rectSDF(float2 p, float2 size) {
                float2 d = abs(p) - size;
                return length(max(d, 0)) + min(max(d.x, d.y), 0);
            }

            // 平滑并集操作
            float smoothUnion(float d1, float d2, float k) {
                float h = clamp(0.5 + 0.5*(d2-d1)/k, 0.0, 1.0);
                return lerp(d2, d1, h) - k*h*(1.0-h);
            }

            // 旋转函数
            float2 rotate(float2 p, float angle) {
                float s = sin(angle);
                float c = cos(angle);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
            }
            
            float triangleSDF(float2 p, float size) {
            float2 q = abs(p);
            return max(q.x*0.866025 + p.y*0.5, -p.y) - size*0.5;
            }
            fixed4 frag (v2f i) : SV_Target {
                float2 uv = i.uv * 2 - 1; // 转换到[-1,1]坐标系

                // 动态参数
                float time = _Time.y;
                
                // 创建动态形状1（旋转矩形）
                float2 pos1 = rotate(uv - float2(0.3, 0), time);
                float rect = rectSDF(pos1, float2(0.2, 0.1));

                // 创建动态形状2（移动圆形）
                float2 circlePos = float2(
                    sin(time) * 0.3,
                    cos(time * 0.8) * 0.2
                );
                float circle = circleSDF(uv, circlePos, 0.2);
                
                // 组合形状
                float finalSDF = smoothUnion(rect, circle, 0.1);

                // 基础颜色
                fixed4 col = _MainColor;

                // 添加边框效果
                float border = smoothstep(_BorderWidth, 0.0, abs(finalSDF));
                col = lerp(col, _BorderColor, border);

                // 添加距离场可视化（可选）
                // col.rgb *= 1 - saturate(finalSDF * 2);

                return col;
            }
            ENDCG
        }
    }
}