Shader "Instanced/DrawProcedural" {
	Properties {
		_MainTex("Texture", 2D) = "white" {}
	}
	SubShader {
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass {
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "../Cginc/Transform.cginc"

			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag

			struct MeshStruct
			{
				float3 position;
				float3 normal;
				float2 uv;
			};
			struct TransformStruct
			{
				float3 translate;
				float3 rotation;
				float3 scale;
				float3 velocity;
				bool init;
			};
			StructuredBuffer<MeshStruct> _MeshBuff;
			StructuredBuffer<TransformStruct> _TransformBuff;

			struct in_cs {
				uint vertexID : SV_VertexID;
				uint instanceID : SV_InstanceID;
			};
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(in_cs i)
			{
				v2f o;
				TransformStruct t = _TransformBuff[i.instanceID];
				float4 m = trs(_MeshBuff[i.vertexID].position, t.translate, t.rotation, t.scale);
				o.vertex = UnityObjectToClipPos(m);
				o.uv = _MeshBuff[i.vertexID].uv;
				return o;
			}
			fixed4 frag(v2f i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}

			ENDCG
		}
	}
	Fallback "Diffuse"
}