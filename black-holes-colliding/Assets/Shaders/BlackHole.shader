Shader "DotCrossDot/BlackHoleRaymarching"
{
	Properties
	{
		_BlackHoleColor ("Black hole color", Color) = (0,0,0,1)
		_SchwarzschildRadius ("schwarzschildRadius", Float) = 0.5
		_SpaceDistortion ("Space distortion", Float) = 4.069
		_SkyCube("Skycube", Cube) = "defaulttexture" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			// Set from script.
			//uniform float4x4 unity_CameraInvProjection;
			//uniform float3 _WorldSpaceCameraPos;

			// Set from material.
			float _SpaceDistortion;
			float _SchwarzschildRadius;
			half4 _BlackHoleColor;
			uniform float4 _Position;
			uniform float4 _Position2;
			samplerCUBE _SkyCube;
			uniform StructuredBuffer<float> _Particles;

			struct appdata
            {
                float4 vertex : POSITION;
                float3 ray : TEXCOORD1;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 ray : TEXCOORD0;
            };

			// An (very rough!!) approximation of how light is bent given the distance to a black hole. 
			float GetSpaceDistortionLerpValue(float schwarzschildRadius, float distanceToSingularity, float spaceDistortion) {
				return pow(schwarzschildRadius, spaceDistortion) / pow(distanceToSingularity, spaceDistortion);
			}

			fixed4 raymarch(float3 ro, float3 rd) {

				int maxstep = 1000;
				float3 previousPos = ro;
				float epsilon = 0.01;
				float stepSize = .05;
				float thickness = 0;

				float disregard_shit_beyond_this_radius_plus_shitchild = 1.5;

				float3 previousRayDir = rd;
				float3 blackHolePosition = _Position.xyz;
				float3 blackHolePosition2 = _Position2.xyz;

				float dsbtrps1 = length(cross(blackHolePosition - ro, normalize(rd))) - _SchwarzschildRadius - disregard_shit_beyond_this_radius_plus_shitchild;
				float dsbtrps2 = length(cross(blackHolePosition2 - ro, normalize(rd))) - _SchwarzschildRadius - disregard_shit_beyond_this_radius_plus_shitchild;

				if (dsbtrps1 > 0 && dsbtrps2 > 0){
					maxstep = 0;
                }
				
				float distanceToSingularity1 = 99999999;
				float distanceToSingularity2 = 99999999;
				float blackHoleInfluence = 0;
				half4 lightAccumulation = half4(0, 0, 0, 1);
				half rotationSpeed = 1.5;
				
				for (int i = 0; i < maxstep; ++i) {
					// Get two vectors. One pointing in previous direction and one pointing to the singularity. 
					float3 forwardDir = normalize(previousRayDir) * stepSize;
					float3 toBH1 = normalize(blackHolePosition - previousPos) * stepSize;
					float3 toBH2 = normalize(blackHolePosition2 - previousPos) * stepSize;

					distanceToSingularity1 = distance(blackHolePosition, previousPos);
					distanceToSingularity2 = distance(blackHolePosition2, previousPos);

					// Calculate how to interpolate between the two previously calculated vectors.
					float lerpValue = GetSpaceDistortionLerpValue(_SchwarzschildRadius, distanceToSingularity1, _SpaceDistortion);
					float lerpValue2 = GetSpaceDistortionLerpValue(_SchwarzschildRadius, distanceToSingularity2, _SpaceDistortion);

					float3 l1 = lerp(forwardDir, toBH1, lerpValue);
					float3 l2 = lerp(forwardDir, toBH2, lerpValue2);
					float3 newRayDir = normalize(lerp(l1, l2, distanceToSingularity1 / (distanceToSingularity1 + distanceToSingularity2))) * stepSize;

					// Move the lightray along and calculate the sdf result
					float3 newPos = previousPos + newRayDir;

					// Calculate black hole influence on the final color.
					blackHoleInfluence = max(step(distanceToSingularity1, _SchwarzschildRadius), step(distanceToSingularity2, _SchwarzschildRadius));
					previousPos = newPos;
					previousRayDir = newRayDir;
				}

				// Sample the skybox.
				float3 skyColor = texCUBE(_SkyCube, previousRayDir).rgb;

				// Sample let background be either skybox or the black hole color.
				half4 backGround = lerp(float4(skyColor.rgb, 1), _BlackHoleColor, blackHoleInfluence);

				// Return background and light.
				return backGround + lightAccumulation;
			}
			float steep(float color){
				return 1.0 / (1 + pow(2.718, -20 * (color - .7)));
            }

			fixed4 raymarch2(float3 ro, float3 rd) {
				float p2l = length(cross(-ro, normalize(rd))) / 7;//sm
				p2l = steep(p2l);
				return float4(p2l, p2l, p2l, 1);
			}

			v2f vert(appdata v)
			{
				v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //o.ray = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz - _WorldSpaceCameraPos;
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.ray = worldPos.xyz - _WorldSpaceCameraPos.xyz; // Direction from camera to vertex in world space

                return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				// ray direction
				//float3 rd = normalize(i.pos - mul(unity_WorldToObject, _WorldSpaceCameraPos));
				// ray origin (camera position)
				//float3 ro = mul(unity_WorldToObject, _WorldSpaceCameraPos);
				float3 ro = _WorldSpaceCameraPos;
				float3 rd = i.ray;

				fixed4 col = raymarch(ro, rd);
				//_Position = float4(0,0,0,0);

				return col;
			}
			ENDCG
		}
	}
}
