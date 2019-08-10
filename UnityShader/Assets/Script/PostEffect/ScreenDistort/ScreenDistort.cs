using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenDistort : PostEffectBase
{
    //扭曲的时间系数
    [Range(0.0f, 1.0f)]
    public float DistortTimeFactor = 0.15f;
    //扭曲的强度
    [Range(0.0f, 0.2f)]
    public float DistortStrength = 0.01f;
    //噪声图
    public Texture NoiseTexture = null;

    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material)
        {
            Material.SetTexture("_NoiseTex", NoiseTexture);
            Material.SetFloat("_DistortTimeFactor", DistortTimeFactor);
            Material.SetFloat("_DistortStrength", DistortStrength);
            Graphics.Blit(source, destination, Material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
