// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "New Amplify Shader"
{
	Properties
	{
		_YHX_TEX("YHX_TEX", 2D) = "white" {}
		_Rim_min("Rim_min", Range( -1 , 1)) = 0
		_Rim_max("Rim_max", Range( -1 , 1)) = 0
		_Rim("Rim", Color) = (0,0,0,0)
		_Inner("Inner", Color) = (0,0,0,0)
		_rim_intensity("rim_intensity", Range( 0 , 5)) = 0
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_speed("speed", Vector) = (0,0,0,0)
		_scan_intensity("scan_intensity", Range( 0 , 1)) = 0.5
		_tex_pow("tex_pow", Float) = 0
		_inner_Alpha("inner_Alpha", Range( -2 , 2)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha One
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 viewDir;
			float3 worldPos;
		};

		uniform float4 _Inner;
		uniform float4 _Rim;
		uniform float _rim_intensity;
		uniform sampler2D _YHX_TEX;
		uniform float4 _YHX_TEX_ST;
		uniform float _tex_pow;
		uniform float _Rim_min;
		uniform float _Rim_max;
		uniform sampler2D _TextureSample0;
		uniform float2 _speed;
		uniform float _scan_intensity;
		uniform float _inner_Alpha;

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_YHX_TEX = i.uv_texcoord * _YHX_TEX_ST.xy + _YHX_TEX_ST.zw;
			float3 ase_worldNormal = i.worldNormal;
			float dotResult23 = dot( ase_worldNormal , i.viewDir );
			float clampResult24 = clamp( dotResult23 , 0.0 , 1.0 );
			float smoothstepResult26 = smoothstep( _Rim_min , _Rim_max , ( 1.0 - clampResult24 ));
			float temp_output_65_0 = ( pow( tex2D( _YHX_TEX, uv_YHX_TEX ).r , _tex_pow ) + smoothstepResult26 );
			float4 lerpResult38 = lerp( _Inner , ( _Rim * _rim_intensity ) , temp_output_65_0);
			float4 rim_col79 = lerpResult38;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult49 = (float2(ase_worldPos.x , ase_worldPos.y));
			float3 objToWorld51 = mul( unity_ObjectToWorld, float4( float3(0,0,0), 1 ) ).xyz;
			float4 appendResult53 = (float4(objToWorld51.x , objToWorld51.y , objToWorld51.z , 0.0));
			float4 tex2DNode41 = tex2D( _TextureSample0, ( ( float4( appendResult49, 0.0 , 0.0 ) - appendResult53 ) + float4( ( _speed * _Time.y ), 0.0 , 0.0 ) ).xy );
			float4 scan_color72 = ( tex2DNode41 * _scan_intensity );
			o.Emission = ( rim_col79 + scan_color72 ).rgb;
			float rim_alpha81 = temp_output_65_0;
			float scan_alpha75 = ( tex2DNode41.a * _scan_intensity );
			float clampResult58 = clamp( ( rim_alpha81 + _inner_Alpha + scan_alpha75 ) , 0.0 , 1.0 );
			o.Alpha = clampResult58;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Lambert keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
7.333333;408.6667;1279.667;455;2028.592;382.5056;2.10271;True;False
Node;AmplifyShaderEditor.CommentaryNode;77;-1392.042,1067.798;Inherit;False;2203.885;785.1902;Comment;16;52;51;48;45;53;49;42;43;54;46;60;41;61;75;59;72;scan_扫描线流光效果;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;78;-1379.662,-578.5584;Inherit;False;1679.205;1484.157;Comment;19;22;21;23;24;25;64;28;27;1;26;39;37;63;40;65;36;38;79;81;边缘光;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;52;-1345.523,1392.902;Inherit;False;Constant;_Vector0;Vector 0;13;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;21;-1329.662,469.038;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;22;-1328.312,691.2387;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;51;-1124.522,1377.902;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;48;-1222.331,1206.497;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;53;-919.5211,1366.902;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;45;-1003.865,1741.352;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;49;-1021.294,1197.851;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;23;-1119.314,482.9877;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;42;-997.2853,1602.327;Inherit;False;Property;_speed;speed;8;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ClampOpNode;24;-961.3126,500.9877;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;54;-669.3013,1282.821;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-679.5379,1653.331;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-459.3288,1277.472;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;1;-892.4655,-528.5585;Inherit;True;Property;_YHX_TEX;YHX_TEX;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-789.3586,641.4103;Inherit;False;Property;_Rim_min;Rim_min;2;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-780.0342,790.5991;Inherit;False;Property;_Rim_max;Rim_max;3;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-768.8033,-298.6592;Inherit;False;Property;_tex_pow;tex_pow;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;25;-824.3126,528.9877;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-328.2108,1549.772;Inherit;False;Property;_scan_intensity;scan_intensity;9;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;41;-281.4,1249.773;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-944.3729,270.5186;Inherit;False;Property;_rim_intensity;rim_intensity;6;0;Create;True;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;37;-972.594,37.08967;Inherit;False;Property;_Rim;Rim;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;63;-434.7996,-476.2316;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;26;-469.0859,492.0597;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;339.5993,1464.915;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-243.8164,303.4551;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;36;-989.4453,-152.2952;Inherit;False;Property;_Inner;Inner;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-633.5591,132.8122;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;249.289,1346.238;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;81;-39.59077,305.0318;Inherit;False;rim_alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;83;809.5756,44.44851;Inherit;False;1249.494;812.1435;Comment;9;70;55;58;56;74;80;71;76;82;输出控制;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;560.5444,1482.438;Inherit;False;scan_alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;38;-60.28548,30.61343;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;566.2319,1326.628;Inherit;False;scan_color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;82;876.3669,419.4802;Inherit;False;81;rim_alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;981.6058,739.1639;Inherit;False;75;scan_alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;847.4343,568.507;Inherit;False;Property;_inner_Alpha;inner_Alpha;11;0;Create;True;0;0;0;False;0;False;0;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;100.1054,-9.556459;Inherit;False;rim_col;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;954.3326,94.44852;Inherit;False;79;rim_col;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;968.0059,284.9052;Inherit;False;72;scan_color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;1253.996,411.8849;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;58;1462.669,422.6372;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;1204.771,145.6986;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;70;1801.736,95.14953;Float;False;True;-1;2;ASEMaterialInspector;0;0;Lambert;New Amplify Shader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;8;5;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;51;0;52;0
WireConnection;53;0;51;1
WireConnection;53;1;51;2
WireConnection;53;2;51;3
WireConnection;49;0;48;1
WireConnection;49;1;48;2
WireConnection;23;0;21;0
WireConnection;23;1;22;0
WireConnection;24;0;23;0
WireConnection;54;0;49;0
WireConnection;54;1;53;0
WireConnection;43;0;42;0
WireConnection;43;1;45;0
WireConnection;46;0;54;0
WireConnection;46;1;43;0
WireConnection;25;0;24;0
WireConnection;41;1;46;0
WireConnection;63;0;1;1
WireConnection;63;1;64;0
WireConnection;26;0;25;0
WireConnection;26;1;27;0
WireConnection;26;2;28;0
WireConnection;61;0;41;4
WireConnection;61;1;60;0
WireConnection;65;0;63;0
WireConnection;65;1;26;0
WireConnection;40;0;37;0
WireConnection;40;1;39;0
WireConnection;59;0;41;0
WireConnection;59;1;60;0
WireConnection;81;0;65;0
WireConnection;75;0;61;0
WireConnection;38;0;36;0
WireConnection;38;1;40;0
WireConnection;38;2;65;0
WireConnection;72;0;59;0
WireConnection;79;0;38;0
WireConnection;56;0;82;0
WireConnection;56;1;71;0
WireConnection;56;2;76;0
WireConnection;58;0;56;0
WireConnection;55;0;80;0
WireConnection;55;1;74;0
WireConnection;70;2;55;0
WireConnection;70;9;58;0
ASEEND*/
//CHKSM=B2C7E74DC88E78B4FC96E33700DFE2DAF2589BA3