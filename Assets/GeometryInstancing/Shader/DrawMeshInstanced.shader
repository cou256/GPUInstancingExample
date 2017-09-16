Shader "Instanced/DrawMeshInstanced" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert
		#pragma multi_compile_instancing
		#pragma instancing_options procedural:setup
		#pragma target 5.0

		#include "../Cginc/Transform.cginc"

		struct TransformStruct {
			float3 translate;
			float3 rotation;
			float3 scale;
			float3 velocity;
			bool init;
		};
		#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
		StructuredBuffer<TransformStruct> _TransformBuff;
		#endif

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		UNITY_INSTANCING_CBUFFER_START(Props)
		UNITY_INSTANCING_CBUFFER_END

		void setup()
		{
			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
			TransformStruct t = _TransformBuff[unity_InstanceID];
			unity_ObjectToWorld = mul(translate_m(t.translate), mul(rotate_m(t.rotation), scale_m(t.scale)));
			#endif
		}
		void vert(inout appdata_full v) {
		}
		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
