Shader "SkyboxStencil"
{
    Properties
    {
        [NoScaleOffset] _FrontTex ("Front (+Z)", 2D) = "white" {}
        [NoScaleOffset] _BackTex ("Back (-Z)", 2D) = "white" {}
        [NoScaleOffset] _LeftTex ("Left (-X)", 2D) = "white" {}
        [NoScaleOffset] _RightTex ("Right (+X)", 2D) = "white" {}
        [NoScaleOffset] _UpTex ("Up (+Y)", 2D) = "white" {}
        [NoScaleOffset] _DownTex ("Down (-Y)", 2D) = "white" {}
        
        _Tint ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _Exposure ("Exposure", Range(0, 8)) = 1.0
        _Rotation ("Rotation", Range(0, 360)) = 0
        
        [Header(Stencil)]
        [IntRange] _StencilRef("Stencil Reference Value", Range(0,255)) = 1
    }
    
    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        
        // Match your Oculus stencil setup - only render where stencil equals reference
        Stencil
        {
            Ref [_StencilRef]
            Comp Equal
            Pass Keep
        }
        
        Cull Off
        ZWrite Off
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct VertexInput
            {
                half4 vertex : POSITION;
                half3 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                half4 pos : SV_POSITION;
                half3 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _FrontTex;
            sampler2D _BackTex;
            sampler2D _LeftTex;
            sampler2D _RightTex;
            sampler2D _UpTex;
            sampler2D _DownTex;
            
            half4 _Tint;
            half _Exposure;
            float _Rotation;
            
            float3 RotateAroundYInDegrees(float3 vertex, float degrees)
            {
                float alpha = degrees * UNITY_PI / 180.0;
                float sina = sin(alpha);
                float cosa = cos(alpha);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(mul(m, vertex.xz), vertex.y).xzy;
            }
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                
                // Apply rotation to skybox
                float3 rotated = RotateAroundYInDegrees(v.vertex, _Rotation);
                o.pos = UnityObjectToClipPos(rotated);
                o.texcoord = v.texcoord;
                
                return o;
            }
            
            half4 frag(VertexOutput i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                float3 c = abs(i.texcoord);
                half4 skyColor;
                
                // Sample the correct face based on direction
                if (c.x > c.y && c.x > c.z)
                {
                    // X face
                    if (i.texcoord.x > 0)
                    {
                        // +X (Right)
                        float2 uv = float2(-i.texcoord.z, i.texcoord.y) / i.texcoord.x;
                        uv = (uv + 1.0) * 0.5;
                        skyColor = tex2D(_RightTex, uv);
                    }
                    else
                    {
                        // -X (Left)
                        float2 uv = float2(i.texcoord.z, i.texcoord.y) / (-i.texcoord.x);
                        uv = (uv + 1.0) * 0.5;
                        skyColor = tex2D(_LeftTex, uv);
                    }
                }
                else if (c.y > c.z)
                {
                    // Y face
                    if (i.texcoord.y > 0)
                    {
                        // +Y (Up)
                        float2 uv = float2(i.texcoord.x, -i.texcoord.z) / i.texcoord.y;
                        uv = (uv + 1.0) * 0.5;
                        skyColor = tex2D(_UpTex, uv);
                    }
                    else
                    {
                        // -Y (Down)
                        float2 uv = float2(i.texcoord.x, i.texcoord.z) / (-i.texcoord.y);
                        uv = (uv + 1.0) * 0.5;
                        skyColor = tex2D(_DownTex, uv);
                    }
                }
                else
                {
                    // Z face
                    if (i.texcoord.z > 0)
                    {
                        // +Z (Front)
                        float2 uv = float2(i.texcoord.x, i.texcoord.y) / i.texcoord.z;
                        uv = (uv + 1.0) * 0.5;
                        skyColor = tex2D(_FrontTex, uv);
                    }
                    else
                    {
                        // -Z (Back)
                        float2 uv = float2(-i.texcoord.x, i.texcoord.y) / (-i.texcoord.z);
                        uv = (uv + 1.0) * 0.5;
                        skyColor = tex2D(_BackTex, uv);
                    }
                }
                
                // Apply tint and exposure
                skyColor.rgb = skyColor.rgb * _Tint.rgb * _Exposure;
                
                return skyColor;
            }
            ENDCG
        }
    }
    
    Fallback Off
}