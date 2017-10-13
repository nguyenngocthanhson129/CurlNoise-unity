﻿Shader "Custom/ParticleShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 200

        CGINCLUDE
        #include "UnityCG.cginc"
        #include "UnityStandardShadow.cginc"

        struct Particle
        {
            int id;
            bool active;
            float3 position;
            float scale;
            float time;
            float lifeTime;
        };

#ifdef SHADER_API_D3D11
        StructuredBuffer<Particle> _Particles;
#endif

        int _IdOffset;

        struct appdata
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 uv1 : TEXCOORD1;
        };

        struct v2f
        {
            float4 position : SV_POSITION;
            float3 normal : NORMAL;
            float2 uv1 : TEXCOORD1;
        };

        inline int getId(float2 uv1)
        {
            return (int)(uv1.x + 0.5) + _IdOffset;
        }

        v2f vert(appdata v)
        {
#ifdef SHADER_API_D3D11
            Particle p = _Particles[getId(v.uv1)];
            v.vertex.xyz *= p.scale;
            v.vertex.xyz += p.position;
#endif

            v2f o;
            o.uv1 = v.uv1;
            o.position = UnityObjectToClipPos(v.vertex);
            o.normal = v.normal;
            return o;
        }

        float4 frag(v2f i) : SV_Target
        {
            return _Color;
        }
        ENDCG

        Pass
        {
            ZWrite On
            ZTest LEqual
            Cull Off

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
    FallBack "Diffuse"
}
