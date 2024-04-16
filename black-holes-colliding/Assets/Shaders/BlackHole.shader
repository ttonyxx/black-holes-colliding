Shader "Custom/BlackShaderWithRadius"
{
    Properties
    {
        _Time ("Time", Float) = 0.0
        _Strength ("Strength", Float) = 1.1
        _Radius ("Radius", Float) = 10.0
        _InnerRadius ("Inner Radius", Float) = 0
        _SphereCenter ("Sphere Center", Vector) = (0,0,0,0)
        _SkyCube("SkyCube", Cube) = "defaulttexture" {}
    }
    
    SubShader
    {
        Tags { "Queue" = "Background" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // float _Time;
            float _Strength;
            float _Radius;
            float _InnerRadius;
            samplerCUBE _SkyCube;
            float4 _SphereCenter;

            struct appdata_t
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Calculate direction from fragment to the sphere center
                float3 toSphere = normalize(_SphereCenter.xyz - i.worldPos);

                // Calculate distance from fragment to the sphere center
                float distanceToSphere = length(_SphereCenter.xyz - i.worldPos);

                // If the distance is less than the inner radius, return black color
                if (distanceToSphere < 0.5)
                {
                    return float4(0, 0, 1, 1);
                }
                else
                {
                    // Calculate warped position based on distance from sphere center and time
                    float3 warpedPos = i.worldPos + _Strength * sin(_Time + distanceToSphere) * toSphere;

                    // Normalize the warped position to use as UV coordinates
                    float3 uv = normalize(warpedPos);

                    // Sample the skybox texture using the warped UV coordinates
                    float4 skyboxColor = texCUBE(_SkyCube, uv);

                    return skyboxColor;
                }
            }
            ENDCG
        }
    }
}