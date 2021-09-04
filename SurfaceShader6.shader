// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Shader6.0(法线纹理)"
{
    Properties
    {
        _Diffuse("漫反射颜色", Color)=(1,1,1,1)
        _MainTex("2D贴图", 2D) = "white" {}
        _NormalTex("法线贴图",2D)="white" {}
        _NormalSale("法线凸起",float)=1.0
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
            
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;//纹理的缩放
            sampler2D _NormalTex;
            float4 _NormalTex_ST;//法线纹理的缩放
            float _NormalSale;
            float4 _Diffuse;
            float _Gloss;
            float4 _Specular;

            struct Input
            {
                float4 pos :POSITION;//顶点坐标（对象空间）
                float3 normal :NORMAL;//法线（对象空间）
                float4 tangent :TANGENT;//切线方向
                float4 texcoord :TEXCOORD;//模型第一套纹理
            };

            struct put
            {
                //fixed4 color : SV_Target;//把用户的输出颜色存到一个渲染目标（render target），这里输出到默认的帧缓存中
                float4 sv_pos : SV_POSITION;//裁剪空间中的顶点坐标
                float3 lightDir : TEXCOORD0;//
                float3 viewDir : TEXCOORD1;
                float4 uv :TEXCOORD2;
            };

            put vert(Input input)
            {
                put o;
                o.sv_pos = UnityObjectToClipPos(input.pos);//将对象转换到裁剪空间
                o.uv.xy=input.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                o.uv.zw=input.texcoord.xy*_NormalTex_ST.xy+_NormalTex_ST.zw;
                //TANGENT_SPACE_ROTATION的定义  cross(x,y) x与y的向量积
                float3 binormal = cross( normalize(input.normal), normalize(input.tangent.xyz) ) * input.tangent.w; 
                //对象空间到切线空间的变换矩阵
                float3x3 rotation = float3x3( input.tangent.xyz, binormal, input.normal );
                //TANGENT_SPACE_ROTATION;
                o.lightDir=mul(rotation,ObjSpaceLightDir(input.pos)).xyz;//变换到切线空间
                o.viewDir=mul(rotation,ObjSpaceViewDir(input.pos)).xyz;//变换到切线空间
                return o;
            }

            float4 frag(put output) :SV_Target//把用户的输出颜色存到一个渲染目标（render target），这里输出到默认的帧缓存中
            {
                float3 tangentLightDir=normalize( output.lightDir);
                float3 tangentViewDir=normalize(output.viewDir);
                float4 packedNormal=tex2D(_NormalTex,output.uv.zw);//法线纹理采样
                float3 tangentNormal;
                //把法线贴图xy分量从0到1重新映射到-1到1之间（高度关系）
                tangentNormal.xy=(packedNormal.xy*2-1)*_NormalSale;
                //不知道为什么这么做   sqrt（x）返回x的平方根的倒数  
                tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
                //使用UnpackNormal 来得到正确的法线方向 unity会更具平台的不同来调整 

                float3 albedo =tex2D(_MainTex,output.uv.xy)*_Diffuse;//纹理采样
                float3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;//UNITY_LIGHTMODEL_AMBIENT环境光照

                // dot数量积
                //_LightColor0光源的颜色和强度   max 比较两个标量或等长向量元素，返回最大值
                float3 diffuse= _LightColor0.rgb*albedo*max(0,dot(tangentNormal,tangentLightDir));

                float3 halfDir=normalize(tangentLightDir+tangentViewDir);
               
                //pow(x,y) x的y次方  ,否则返回x. dot数量积
                float3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(tangentNormal,halfDir)),_Gloss);
                
                return float4(ambient+specular+diffuse,1);

            }
            ENDCG
        }
    }
        //FallBack "Diffuse"
}
