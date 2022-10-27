Shader "Game/Uber Transparent"
{
    Properties
    {
        [Hdr]_Color ("Color", COLOR) = (1,1,1,1)
        _AlphaScale ("Alpha Scale", FLOAT) = 1
        [Hdr]_ColorFresnel ("Color Fresnel", COLOR) = (1,1,1,1)
        _Fresnel ("Fresnel", FLOAT) = 0
        _MainTex ("Texture", 2D) = "white" {}
        [Toggle(ANIM_ON)]_Anim_ON ("Animation", FLOAT) = 0
        _Anim ("Animation dir", VECTOR) = (0,0,0,0)
        [Space]
        _VCol ("Vertex Color", FLOAT) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendSrc ("Blend Src", FLOAT) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendDst ("Blend Dst", FLOAT) = 10
        [Enum(UnityEngine.Rendering.CullMode)]_Culling ("Culling", FLOAT) = 0
        [Toggle]_ZWrite ("Z Write", FLOAT) = 0
        _Z_Test ("Z Test", FLOAT) = 2
        [Toggle(CUTOUT_ON)]_Cutout ("Cut Out", FLOAT) = 0
        _CutThr ("Alpha Threshold", FLOAT) = 0.5
        [Space]
        _OffsetFactor ("Offset Factor", Range(-1,1)) = 0
        _OffsetUnits ("Offset Units", Range(-1,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        Cull [_Culling]
        ZWrite [_ZWrite]
        Blend [_BlendSrc] [_BlendDst]
        ZTest [_Z_Test]
        Offset [_OffsetFactor], [_OffsetUnits]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile __ CUTOUT_ON
            #pragma multi_compile __ ANIM_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID //Insert
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                half3 normal : NORMAL;
                half3 viewVec : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO //Insert
            };

            fixed4 _Color;
            fixed4 _ColorFresnel;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _VCol;
            half _Fresnel;
            half _CutThr;
            half _AlphaScale;

            #ifdef ANIM_ON
            float4 _Anim;
            #endif

            v2f vert (appdata v)
            {
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v); //Insert
                UNITY_INITIALIZE_OUTPUT(v2f, o); //Insert
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o); //Insert

                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                #ifdef ANIM_ON
                o.uv += _Anim.xy * _Time.xy;
                #endif

                o.color = lerp(1,v.color,_VCol);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewVec = (_WorldSpaceCameraPos - mul(unity_ObjectToWorld,v.vertex).xyz);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 tex = tex2D(_MainTex,i.uv);
                #ifdef CUTOUT_ON
                clip(tex.a - _CutThr);
                #endif
                tex.a *= _AlphaScale;
                half facing = abs(dot(normalize(i.normal),normalize(i.viewVec)));
                fixed4 col = 
                    tex * 
                    lerp(
                        _ColorFresnel,
                        _Color,
                        saturate(pow(abs(facing),_Fresnel))
                    ) * i.color;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
tex = tex2D(_MainTex,i.uv);
                #ifdef CUTOUT_ON
                clip(tex.a - _CutThr);
                #endif
                tex.a *= _AlphaScale;
                half facing = abs(dot(normalize(i.normal),normalize(i.viewVec)));
                fixed4 col = 
                    tex * 
                    lerp(
                        _ColorFresnel,
                        _Color,
                        saturate(pow(abs(facing),_Fresnel))
                    ) * i.color;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
