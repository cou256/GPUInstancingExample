Shader "Custom/Kernel" {
	Properties {
	}
	CGINCLUDE

	#include "UnityCG.cginc"

    sampler2D _TranslateBuff;
	sampler2D _RotationBuff;
	sampler2D _ScaleBuff;
	sampler2D _VelocityBuff;
	sampler2D _InitBuff;

	float _DeltaTime;
	float _Velocity;
	float3 _Bounds;
	float2 _Offset;

	/*
	Reference
	https://stackoverflow.com/questions/12964279/whats-the-origin-of-this-glsl-rand-one-liner
	*/
	float rand(float2 uv, float salt) {
		return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453 * salt);
	}
	float4 initializeTranslate(float2 uv)
	{
		float d1 = _DeltaTime;
		float d2 = d1 * d1;
		float d3 = d1 * d2;
		float3 t = (float3(rand(uv, 11 * d1), rand(uv, 13 * d2), rand(uv, 17 * d3)) - 0.5) * _Bounds;
		return float4(t, 1.0);
	}
	float4 initializeRotation(float2 uv)
	{
		float r = rand(uv, 23 * _DeltaTime) * 360;
		return float4(r, r, r, 1.0);
	}
	float4 initializeScale(float2 uv)
	{
		float s = rand(uv, 19 * _DeltaTime) * 0.1;
		return float4(s, s, s, 1.0);
	}
	float4 initializeVelocity(float2 uv)
	{
		float d1 = _DeltaTime;
		float d2 = d1 * d1;
		float d3 = d1 * d2;
		float3 v = float3(rand(uv, d1), rand(uv, d2), rand(uv, d3)) - 0.5;
		return float4(v, 1.0);
	}

	float4 initBounds(v2f_img i) : SV_Target
	{
		return float4(true, 0.0, 0.0, 1.0);
	}
	float4 translate(v2f_img i) : SV_Target
	{
		float2 uv = i.uv;
		bool init = tex2D(_InitBuff, uv).x;
		if(init == true){
			return initializeTranslate(uv);
		}
		else {
			float3 t = tex2D(_TranslateBuff, uv).xyz;
			float3 v = tex2D(_VelocityBuff, uv).xyz * _Velocity;
			return float4(t + v, 1.0);
		}
	}
	float4 rotation(v2f_img i) : SV_Target
	{
		float2 uv = i.uv;
		bool init = tex2D(_InitBuff, uv).x;
		if(init == true){
			return initializeRotation(i.uv);
		}
		else {
			float3 r = tex2D(_RotationBuff, uv).xyz;
			float3 v = tex2D(_VelocityBuff, uv).xyz * _Velocity;
			r += length(v) * 50;
			return float4(r, 1.0);
		}
	}
	float4 scale(v2f_img i) : SV_Target
	{
		float2 uv = i.uv;
		bool init = tex2D(_InitBuff, uv).x;
		if(init == true){
			return initializeScale(uv);
		}
		else {
			float4 s = tex2D(_ScaleBuff, uv);
			s.w = 1.0f;
			return s;
		}
	}
	float4 velocity(v2f_img i) : SV_Target
	{
		float2 uv = i.uv;
		bool init = tex2D(_InitBuff, uv).x;
		if(init == true){
			return initializeVelocity(uv);
		}
		else {
			float4 v = tex2D(_VelocityBuff, uv);
			v.w = 1.0;
			return v;
		}
	}
	float4 bounds(v2f_img i) : SV_Target
	{
		float2 uv = i.uv;
		float3 b0 = abs(tex2D(_TranslateBuff, uv).xyz);
		float3 b1 = _Bounds * 0.5;
		return float4(b0.x > b1.x && b0.y > b1.y && b0.z > b1.z, 0.0, 0.0, 1.0);
	}

	ENDCG
	SubShader {
		Pass
        {
			CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment initBounds
			ENDCG
        }
		Pass
        {
			CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment translate
			ENDCG
        }
		Pass
        {
			CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment rotation
			ENDCG
        }
		Pass
        {
			CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment scale
			ENDCG
        }
		Pass
        {
			CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment velocity
			ENDCG
        }
		Pass
        {
			CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment bounds
			ENDCG
        }
	}
}
