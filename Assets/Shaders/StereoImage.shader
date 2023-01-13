Shader "Stereo/StereoImage"
{

    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Cull Off
        ZTest Less
        ZWrite On

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 position: POSITION;
                float2 texcoord: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS: SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
                float4 uv: TEXCOORD0;
            };

            sampler2D _MainTex;

            Varyings vert (Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.position.xyz);
                output.uv.xy = input.texcoord;
                // UNITY_TRANSFER_FOG(o,o.vertex);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                // sample the texture


                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                float c = lerp(0,1,unity_StereoEyeIndex);
                half2 uv = input.uv;
                uv.x *= 0.5;
                uv.x += 0.5 * unity_StereoEyeIndex;
                half3 color = tex2D(_MainTex, uv);
                return half4(color,1);
            }
            ENDHLSL
        }
    }
}
