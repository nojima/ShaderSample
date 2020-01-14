Shader "Unlit/MonoColorShader" {
    Properties {
		_MainColor("Color of the surface", Color) = (0.8, 0.0, 0.0, 1.0)
    }
    SubShader {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			float4 _MainColor;

            struct VertexInput {
                float4 pos : POSITION;
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
            };

            VertexOutput vert(VertexInput v) {
				float4 pos = v.pos;
				pos = mul(UNITY_MATRIX_M, pos); // ワールド変換
				pos = mul(UNITY_MATRIX_V, pos); // ビュー変換
				pos = mul(UNITY_MATRIX_P, pos); // パースペクティブ変換
                VertexOutput o;
				o.pos = pos;
                return o;
            }

			float4 frag(VertexOutput i) : SV_Target {
                return _MainColor;
            }
            ENDCG
        }
    }
}
