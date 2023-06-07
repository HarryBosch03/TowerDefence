Shader "Unlit/Ground"
{
    Properties
    {
        _GridColor("Grid Color", Color) = (1, 1, 1, 1)
        _GridValue("Grid Brightness", float) = 0.1
        _Size("Grid Size", Range(0.0, 1.0)) = 1.0
        _Sharpness("Sharpness", float) = 50.0
        _FadeOffset("Distance Fade Offset", float) = 1.0
        _FadeScale("Distance Fade Scale", float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Blend One One

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

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.pos = TransformObjectToWorld(input.vertex.xyz);
                output.vertex = TransformWorldToHClip(output.pos);
                output.uv = input.uv;
                return output;
            }

            float4 _GridColor;

            float _Size, _Sharpness;
            float _FadeOffset, _FadeScale;
            float _GridValue;

            float4 frag(Varyings input) : SV_Target
            {
                float3 col = 0.0;
                float2 pos = input.pos.xz;
                float2 origin = round(pos);
                float2 diff = pos - origin;
                float d = 1 - saturate((length(diff) - (_Size / 1.414 - 1 / _Sharpness)) * _Sharpness);

                float dist = length(input.pos - _WorldSpaceCameraPos);
                d *= clamp(dist * _FadeScale + _FadeOffset, 0.0, 1.0);

                float3 gridColor = _GridColor.rgb;
                int depth = 1;
                for (int i = 0; i < 2; i++)
                {
                    int gridSize = pow(5, i + 1) + 1;
                    if (floor(abs(pos.x) + 0.5) % gridSize == 0 || floor(abs(pos.y) + 0.5) % gridSize == 0)
                    {
                        depth = i + 2;
                    }
                }
                gridColor *= pow(depth, 3) * _GridValue;
                gridColor *= 1.0 / (1.0 - 50.0 * input.pos.y);
                col += gridColor * d;

                return float4(col, 0.0);
            }
            ENDHLSL
        }
    }
}