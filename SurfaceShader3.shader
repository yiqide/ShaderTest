// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/SurfaceShader3.0"
{
    Properties
    {
        _MainTex("2D贴图", 2D) = "white" {}
        _Diffuse("漫反射颜色", Color)=(1,1,1,1)
    }
        SubShader
    {
        pass
        {
            Tags { "LightMode" = "ForwardBase" } //内置光照模型
            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vert
            #pragma fragment frag
            //sampler2D _MainTex;
            #include "Lighting.cginc"

            float4 _Diffuse;

            struct Input
            {
                float4 pos :POSITION;//顶点坐标（对象空间）
                float3 normal :NORMAL;//法线（对象空间）
                float4 texcoord :TEXCOORD;//模型第一套纹理
            };

            struct put
            {
                //fixed4 color : SV_Target;//把用户的输出颜色存到一个渲染目标（render target），这里输出到默认的帧缓存中
                float4 sv_pos : SV_POSITION;//裁剪空间中的顶点坐标
                float3 worldNormal : TEXCOORD0;//可以用来存储颜色 
            };

            put vert(Input input)
            {
                put o;
                o.sv_pos = UnityObjectToClipPos(input.pos);//将对象转换到裁剪空间
                o.worldNormal=normalize(mul(input.normal,(float3x3)unity_WorldToObject));//把法线从对象空间转换到世界空间
            
                return o;
            }

            fixed4 frag(put output) :SV_Target//把用户的输出颜色存到一个渲染目标（render target），这里输出到默认的帧缓存中
            {
                float3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;//UNITY_LIGHTMODEL_AMBIENT环境光照
                float3 worldLight=normalize(_WorldSpaceLightPos0.xyz);//_WorldSpaceLightPos0光源方向
                //saturate如果x<0返回0,如果x>1返回1,否则返回x. dot数量积
                float3 diffuse= _LightColor0.rgb*_Diffuse.rgb*saturate(dot(output.worldNormal,worldLight));//_LightColor0光源的颜色和强度
                float3 color = diffuse+ambient;
                return fixed4(color,1);

            }
            ENDCG
        }
    }
        //FallBack "Diffuse"
}
