﻿Shader "Custom/WaterShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_Amplitude ("Amplitute", Range(0,1)) = 0.5
		_Speed ("Speed", Range(0,50)) = 0.5
		_Wavelength ("Wavelength", Range(0,10)) = 0.5
		_Q ("Steepness", range(0,2)) = 0.5
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
		#pragma vertex vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#include "AutoLight.cginc"

		sampler2D _MainTex;
		float _Amplitude, _Speed, _Wavelength, _Q;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		float3 gerstnerWave(float3 P, float2 D) 
		{
			//Gerstner waveform.  
			float W = 2 * 3.1416 / _Wavelength;
			float dotD = dot(P.xz, D);
			float C = cos(W*dotD + _Time*_Speed);
			float S = sin(W*dotD + _Time*_Speed);
			return float3(P.x + _Q*_Amplitude*C*D.x, _Amplitude*S, P.z + _Q*_Amplitude*C*D.y);
		}

		void vert(inout appdata_full v)
		{
			float3 P0 = v.vertex.xyz;
			//Sample points for normal recalculations.
			float3 P1 = P0 + float3(0.05, 0, 0); //+X
			float3 P2 = P0 + float3(0, 0, 0.05); //+Y

			//Wave directions.
			float2 D0 = float2(1, 0);
			float2 D1 = float2(0.75, 0.5);
			float2 D2 = float2(0.9, 0.37);
			float2 D3 = float2(0.62, 0.45);
			float2 D4 = float2(0, 1);

			float3 Pv0 = gerstnerWave(P0, D0) + gerstnerWave(P0, D1) + gerstnerWave(P0, D2) + gerstnerWave(P0, D2) + gerstnerWave(P0, D4);
			float3 Pv1 = gerstnerWave(P1, D0) + gerstnerWave(P1, D1) + gerstnerWave(P1, D2) + gerstnerWave(P1, D2) + gerstnerWave(P1, D4);
			float3 Pv2 = gerstnerWave(P2, D0) + gerstnerWave(P2, D1) + gerstnerWave(P2, D2) + gerstnerWave(P2, D2) + gerstnerWave(P2, D4);

			//Take the cross product to find the normal of the vertices.
			float3 vn = cross(Pv2 - Pv0, Pv1 - Pv0);
			v.normal += normalize(vn);

			v.vertex.xyz += float4(Pv0, 1);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG


	}
	FallBack "Diffuse"

}