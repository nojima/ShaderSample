Shader "Unlit/Lambert" {
    Properties {
		_BaseColor("Base Color", Color) = (0.8, 0.0, 0.0, 1.0)
		_LightDir("Light Direction", Vector) = (0.0, 1.0, 0.0, 0.0)
    }
    SubShader {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        Pass {
            CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float4 _BaseColor;
			float4 _LightDir;

			struct VertexInput {
				float4 pos : POSITION;
				float3 normal : NORMAL;
			};

			struct VertexOutput {
				float4 clipPos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 normal : TEXCOORD1;
			};

			VertexOutput vert(VertexInput v) {
				VertexOutput o;
				o.clipPos = UnityObjectToClipPos(v.pos);
				o.worldPos = mul(unity_ObjectToWorld, v.pos);
				o.normal = mul(v.normal,
							   (float3x3)unity_WorldToObject);
				return o;
			}

			float4 frag(VertexOutput i) : SV_TARGET {
				float3 lightDir = normalize(
					UnityWorldSpaceLightDir(i.worldPos));
				float3 normal = normalize(i.normal);

				float LN = max(dot(lightDir, normal), 0.0);
				float3 color = _BaseColor * LN;
				return float4(color, 1.0);
			}
            ENDCG
        }
    }
}
