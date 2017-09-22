Shader "Custom/Shader" {
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
		#pragma target 3.0
		#include "../Cginc/Transform.cginc"

		sampler2D _MainTex;
		sampler2D _TranslateBuff;
		sampler2D _RotationBuff;
		sampler2D _ScaleBuff;

		float2 _Offset;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void vert(inout appdata_full v)
		{
			float4 uv = float4(v.texcoord1.xy * _Offset, 0, 0);
			float3 t = tex2Dlod(_TranslateBuff, uv).xyz;
			float3 r = tex2Dlod(_RotationBuff, uv).xyz;
			float3 s = tex2Dlod(_ScaleBuff, uv).xyz;
			v.vertex.xyz = trs(v.vertex.xyz, t, r, s);
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
