Shader "Gerson/UIOutline"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineWidth ("Outline Width", Int) = 1
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "UIOUTLINE"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            sampler2D _MainTex;
            fixed4 _TextureSampleAdd;
            float4 _MainTex_TexelSize;

            float4 _OutlineColor;
            int _OutlineWidth;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                float2 uvOriginXY : TEXCOORD1;
                float2 uvOriginZW : TEXCOORD2;
                fixed4 color : COLOR;
            };

            v2f vert(appdata IN)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(IN.vertex);
                o.texcoord = IN.texcoord;
                o.uvOriginXY = IN.texcoord1;
                o.uvOriginZW = IN.texcoord2;
                o.color = IN.color;

                return o;
            }

            fixed PiexIsInRect(float2 pPos, float2 pClipRectXY, float2 pClipRectZW)
            {
                pPos = step(pClipRectXY, pPos) * step(pPos, pClipRectZW);
                return pPos.x * pPos.y;
            }

            fixed OutLineAlpha(int pIndex, v2f IN)
            {
                const fixed sinArray[12] = {0, 0.5, 0.866, 1, 0.866, 0.5, 0, -0.5, -0.866, -1, -0.866, -0.5};
                const fixed cosArray[12] = {1, 0.866, 0.5, 0, -0.5, -0.866, -1, -0.866, -0.5, 0, 0.5, 0.866};
                float2 pos = IN.texcoord + _MainTex_TexelSize.xy * float2(cosArray[pIndex], sinArray[pIndex]) *
                    _OutlineWidth;
                return PiexIsInRect(pos, IN.uvOriginXY, IN.uvOriginZW) * (tex2D(_MainTex, pos) + _TextureSampleAdd).w *
                    _OutlineColor.w;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 col = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                if (_OutlineWidth > 0)
                {
                    col.w *= PiexIsInRect(IN.texcoord, IN.uvOriginXY, IN.uvOriginZW);
                    half4 outlineVert = half4(_OutlineColor.x, _OutlineColor.y, _OutlineColor.z, 0);

                    outlineVert.w += OutLineAlpha(0, IN);
                    outlineVert.w += OutLineAlpha(1, IN);
                    outlineVert.w += OutLineAlpha(2, IN);
                    outlineVert.w += OutLineAlpha(3, IN);
                    outlineVert.w += OutLineAlpha(4, IN);
                    outlineVert.w += OutLineAlpha(5, IN);
                    outlineVert.w += OutLineAlpha(6, IN);
                    outlineVert.w += OutLineAlpha(7, IN);
                    outlineVert.w += OutLineAlpha(8, IN);
                    outlineVert.w += OutLineAlpha(9, IN);
                    outlineVert.w += OutLineAlpha(10, IN);
                    outlineVert.w += OutLineAlpha(11, IN);

                    outlineVert.w = clamp(outlineVert.w, 0, 1);
                    col = (outlineVert * (1.0 - col.a)) + (col * col.a);
                }
                return col;
            }
            ENDCG
        }
    }
}