Shader "Unlit/Phong" {
    Properties {
		_BaseColor("Base Color", Color) = (0.8, 0.0, 0.0, 1.0)
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

			uniform float4 _BaseColor;
			uniform float4 _LightDir;
			uniform float _LightIntencity;
			uniform float _AmbientReflectance;
			uniform float _DiffuseReflectance;
			uniform float _SpecularReflectance;
			uniform float _Shininess;

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
				o.normal = mul(v.normal, (float3x3)unity_WorldToObject);
                return o;
            }

			float4 frag(VertexOutput i) : SV_Target {
				float3 lightDir = normalize(_LightDir);
				float3 normal = normalize(i.normal);
				
				// 環境光
				float3 ambient = _AmbientReflectance * _LightIntencity;

				// 拡散光
				float LN = dot(lightDir, normal);
				float3 diffuse = _DiffuseReflectance * max(LN, 0.0) * _BaseColor * _LightIntencity;

				// 反射光
				float3 reflectionDir = -reflect(lightDir, normal);
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float RV = dot(reflectionDir, viewDir);
				float3 specular = _SpecularReflectance * pow(max(RV, 0.0), _Shininess) * _LightIntencity;

				float3 color = ambient + diffuse + specular;
				return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
