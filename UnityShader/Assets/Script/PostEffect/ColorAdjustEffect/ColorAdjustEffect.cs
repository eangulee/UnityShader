using UnityEngine;
using System.Collections;

public class ColorAdjustEffect : PostEffectBase
{
    //通过Range控制可以输入的参数的范围
    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;//亮度
    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;  //对比度
    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;//饱和度

    //覆写OnRenderImage函数
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        //仅仅当有材质的时候才进行后处理，如果_Material为空，不进行后处理
        if (Material)
        {
            //通过Material.SetXXX（"name",value）可以设置shader中的参数值
            Material.SetFloat("_Brightness", brightness);
            Material.SetFloat("_Saturation", saturation);
            Material.SetFloat("_Contrast", contrast);
            //使用Material处理Texture，dest不一定是屏幕，后处理效果可以叠加的！
            Graphics.Blit(src, dest, Material);
        }
        else
        {
            //直接绘制
            Graphics.Blit(src, dest);
        }
    }
}