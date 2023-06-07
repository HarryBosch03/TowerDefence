Shader "Unlit/Ground"
{
    Properties
    {
        _BGColor("Background Color", Color) = (0, 0, 0, 1)
        _GridColor("Grid Color", Color) = (1, 1, 1, 1)
        _Size("Grid Size", Range(0.0, 1.0)) = 1.0
        _Sharpness("Sharpness", float) = 50.0
        _FadeOffset("Distance Fade Offset", float) = 1.0
        _FadeScale("Distance Fade Scale", float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 pos : VAR_POSITION;
            };
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                output.pos = TransformObjectToWorld(input.vertex.xyz);
                output.vertex = TransformWorldToHClip(output.pos);
                output.uv = input.uv;
                return output;
            }

            float4 _BGColor, _GridColor;

            float _Size, _Sharpness;
            float _FadeOffset, _FadeScale;
            
            float4 frag (Varyings input) : SV_Target
            {
                float3 col = _BGColor.rgb;
                float2 pos = input.pos.xz + 0.5;
                float2 origin = round(pos);
                float2 diff = pos - origin;
                float d = 1 - saturate((length(diff) - (_Size / 1.414 - 1 / _Sharpness)) * _Sharpness);
                
                float dist = length(input.pos - _WorldSpaceCameraPos);
                d *= clamp(dist * _FadeScale + _FadeOffset, 0.0, 1.0);
                
                col = lerp(col, _GridColor.rgb, d);
                return float4(col, 0.0);
            }
            ENDHLSL
        }
    }
}
