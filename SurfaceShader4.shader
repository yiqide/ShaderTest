// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Shader4.0(高光反射)"
{
    Properties
    {
        _MainTex("2D贴图", 2D) = "white" {}
        _Diffuse("漫反射颜色", Color)=(1,1,1,1)
        _Specular("高光色",Color)=(1,1,1,1)
        _Gloss("光泽度",Range(0,250))=50
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
            float _Gloss;
            float4 _Specular;

            struct Input
            {
                float4 pos :POSITION;//顶点坐标（对象空间）
                float3 normal :NORMAL;//法线（对象空间）
                
                //float4 texcoord :TEXCOORD;//模型第一套纹理
            };

            struct put
            {
                //fixed4 color : SV_Target;//把用户的输出颜色存到一个渲染目标（render target），这里输出到默认的帧缓存中
                float4 sv_pos : SV_POSITION;//裁剪空间中的顶点坐标
                float3 worldNormal : TEXCOORD0;//
                float3 WorldPos : TEXCOORD1;
            };

            put vert(Input input)
            {
                put o;
                o.sv_pos = UnityObjectToClipPos(input.pos);//将对象转换到裁剪空间
                o.worldNormal=normalize(mul(unity_ObjectToWorld,input.normal));//把法线从对象空间转换到世界空间
                o.WorldPos=mul(unity_ObjectToWorld,input.pos).xyz;
                return o;
            }

            float4 frag(put output) :SV_Target//把用户的输出颜色存到一个渲染目标（render target），这里输出到默认的帧缓存中
            {
                float3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;//UNITY_LIGHTMODEL_AMBIENT环境光照
                //_WorldSpaceLightPos0 对象到光源的方向
                float3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);//_WorldSpaceLightPos0光源方向
                //saturate如果x<0返回0,如果x>1返回1,否则返回x. dot数量积
                //_LightColor0光源的颜色和强度
                float3 diffuse= _LightColor0.rgb*_Diffuse.rgb*saturate(dot(output.worldNormal,worldLightDir));
                //reflect(I,N)根据入射光方向向量 I ，和顶点法向量 N ，计算反射光方向向量。其中 I 和 N 必须被归一化，需要非常注意的是，这个 I 是指向顶点的；函数只对三元向量有效。
                float3 reflectDir=normalize(reflect(-worldLightDir,output.worldNormal));
                //_WorldSpaceCameraPos 对象到相机的方向
                float3 viewDir=normalize(_WorldSpaceCameraPos.xyz-output.WorldPos.xyz);
                //pow(x,y) x的y次方  saturate如果x<0返回0,如果x>1返回1,否则返回x. dot数量积
                float3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);
                
                return float4(ambient+specular+diffuse,1);

            }
            ENDCG
        }
    }
        //FallBack "Diffuse"
}
