Shader "Unlit/MonoColor" {
    SubShader {
        Tags { "RenderType"="Opaque" }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4 vert(float4 pos : POSITION) : SV_POSITION {
				return UnityObjectToClipPos(pos); // 座標変換
            }

			float4 frag() : SV_TARGET {
                return float4(0.22, 0.71, 0.55, 1.0); // 翡翠色
            }
            ENDCG
        }
    }
}
