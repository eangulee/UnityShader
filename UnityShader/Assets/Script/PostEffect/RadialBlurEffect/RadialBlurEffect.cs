using UnityEngine;

public class RadialBlurEffect : PostEffectBase
{
    //模糊程度，不能过高
    [Range(0, 0.05f)]
    public float blurFactor = 0.05f;
    //模糊中心（0-1）屏幕空间，默认为中心点
    public Vector2 blurCenter = new Vector2(0.5f, 0.5f);

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material)
        {
            Material.SetFloat("_BlurFactor", blurFactor);
            Material.SetVector("_BlurCenter", blurCenter);
            Graphics.Blit(source, destination, Material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}