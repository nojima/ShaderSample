Shader "Unlit/Marble" {
    Properties {
		_Color1("Color1", Color) = (0.04165185, 0.6792453, 0.5164949, 1.0)
		_Color2("Color2", Color) = (0.0, 0.0, 0.0, 1.0)
		_Color3("Color3", Color) = (0.03551085, 0.1269515, 0.3962264, 1.0)
		_Color4("Color4", Color) = (1.0, 1.0, 1.8, 1.0)

		_LightDir("Light Direction", Vector) = (0.0, 1.0, 0.0, 0.0)
		_LightIntencity("Light Intencity", Float) = 1.0
		_AmbientReflectance("Ambient Reflection Constant", Range(0, 1)) = 0.1
		_DiffuseReflectance("Diffuse Reflection Constant", Range(0, 1)) = 0.7
		_SpecularReflectance("Specular Reflection Constant", Range(0, 1)) = 0.2
		_Shininess("Shininess", Float) = 20.0
    }
    SubShader {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "UnityCG.cginc"

			float4 _Color1;
			float4 _Color2;
			float4 _Color3;
			float4 _Color4;

			uniform float4 _LightDir;
			uniform float _LightIntencity;
			uniform float _AmbientReflectance;
			uniform float _DiffuseReflectance;
			uniform float _SpecularReflectance;
			uniform float _Shininess;

			uint MurmurHash13(uint3 src) {
				const uint M = 0x5bd1e995u;
				uint h = 1190494759u;
				src *= M; src ^= src>>24u; src *= M;
				h *= M; h ^= src.x; h *= M; h ^= src.y; h *= M; h ^= src.z;
				h ^= h>>13u; h *= M; h ^= h>>15u;
				return h;
			}

			// 1 output, 3 inputs
			float Hash13(float3 src) {
				uint h = MurmurHash13(asuint(src));
				return asfloat(h & 0x007fffffu | 0x3f800000u) - 1.0;
			}

			float ValueNoise(float3 p) {
				float3 i = floor(p);
				float3 f = frac(p);

				float v0 = Hash13(i + float3(0, 0, 0));
				float v1 = Hash13(i + float3(1, 0, 0));
				float v2 = Hash13(i + float3(0, 1, 0));
				float v3 = Hash13(i + float3(1, 1, 0));
				float v4 = Hash13(i + float3(0, 0, 1));
				float v5 = Hash13(i + float3(1, 0, 1));
				float v6 = Hash13(i + float3(0, 1, 1));
				float v7 = Hash13(i + float3(1, 1, 1));

				float3 alpha = smoothstep(0.0, 1.0, f);

				return lerp(
					lerp(
						lerp(v0, v1, alpha.x),
						lerp(v2, v3, alpha.x),
						alpha.y
					),
					lerp(
						lerp(v4, v5, alpha.x),
						lerp(v6, v7, alpha.x),
						alpha.y
					),
					alpha.z
				);
			}

			float FBM(float3 p) {
				float v = 0.0;
				v += 1.0 * ValueNoise(p / 1.0);
				v += 2.0 * ValueNoise(p / 2.0);
				v += 4.0 * ValueNoise(p / 4.0);
				v += 8.0 * ValueNoise(p / 8.0);
				v += 16.0 * ValueNoise(p / 16.0);
				return v / 31;
			}

			float DomainWarping(float3 p, out float q, out float r) {
				q = FBM(p);
				r = FBM(p + 50 * q);
				return FBM(p + 50 * r);
			}

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
				o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

			float3 Marble(float3 p) {
				float q, r;
                float v = DomainWarping(10 * p, q, r);

				float3 color = lerp(_Color1.rgb, _Color2.rgb, q);
				color = lerp(color, _Color3.rgb, pow(10.0, r) * 0.1);
				color = lerp(color, _Color4.rgb, v);
			
				return color;
			}

			float3 Phong(VertexOutput i, float3 baseColor) {
				float3 lightDir = normalize(_LightDir);
				float3 normal = normalize(i.normal);
				
				// 環境光
				float3 ambient = _AmbientReflectance * baseColor * _LightIntencity;

				// 拡散光
				float LN = dot(lightDir, normal);
				float3 diffuse = _DiffuseReflectance * max(LN, 0.0) * baseColor * _LightIntencity;

				// 反射光
				float3 reflectionDir = -reflect(lightDir, normal);
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float RV = dot(reflectionDir, viewDir);
				float3 specular = _SpecularReflectance * pow(max(RV, 0.0), _Shininess) * _LightIntencity;

				float3 color = ambient + diffuse + specular;
				return float4(color, 1.0);
			}

			float4 frag(VertexOutput i) : SV_Target {
				float3 baseColor = Marble(i.worldPos);
				float3 color = Phong(i, baseColor);
				return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
