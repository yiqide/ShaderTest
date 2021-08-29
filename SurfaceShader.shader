// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/SurfaceShader1.0"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        pass
        {

            CGPROGRAM//Tags { "LightMode"="ForwardBase" } //内置光照模型
            #pragma target 4.0
            #pragma vertex vert
            #pragma fragment frag
            //sampler2D _MainTex;
            struct Input
            { 
                float4 pos :POSITION;//顶点坐标
                float3 normal :NORMAL;//法线
                float4 texcoord :TEXCOORD;//模型第一套纹理
            };

            struct put
            {
                //fixed4 color : SV_Target;//把用户的输出颜色存到一个渲染目标（render target），这里输出到默认的帧缓存中
                float4 sv_pos : SV_POSITION;//裁剪空间中的顶点坐标
                fixed3 color2 : COLOR0;//可以用来存储颜色 
            };

            put vert(Input input)
            {
                put o;
                o.sv_pos=UnityObjectToClipPos(input.pos);//将对象转换到裁剪空间
                o.color2=input.normal*0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            fixed4 frag(put output) :SV_Target//把用户的输出颜色存到一个渲染目标（render target），这里输出到默认的帧缓存中
            {
                return fixed4(output.color2,1);
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
}
