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

            CGPROGRAM//Tags { "LightMode"="ForwardBase" } //���ù���ģ��
            #pragma target 4.0
            #pragma vertex vert
            #pragma fragment frag
            //sampler2D _MainTex;
            struct Input
            { 
                float4 pos :POSITION;//��������
                float3 normal :NORMAL;//����
                float4 texcoord :TEXCOORD;//ģ�͵�һ������
            };

            struct put
            {
                //fixed4 color : SV_Target;//���û��������ɫ�浽һ����ȾĿ�꣨render target�������������Ĭ�ϵ�֡������
                float4 sv_pos : SV_POSITION;//�ü��ռ��еĶ�������
                fixed3 color2 : COLOR0;//���������洢��ɫ 
            };

            put vert(Input input)
            {
                put o;
                o.sv_pos=UnityObjectToClipPos(input.pos);//������ת�����ü��ռ�
                o.color2=input.normal*0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            fixed4 frag(put output) :SV_Target//���û��������ɫ�浽һ����ȾĿ�꣨render target�������������Ĭ�ϵ�֡������
            {
                return fixed4(output.color2,1);
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
}
