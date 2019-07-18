using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class Fade : PostEffectBase
{
    [Range(0.0f, 0.5f)]                         // 为1的时候完全代替当前帧的渲染结果
    public float start = 0.1f;
    public float speed = 1f;
    private float _time;
    void OnDisable()
    {
       
    }

    private void OnEnable()
    {
        _time = Time.time;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Material != null)
        {
            //仅仅当有材质的时候才进行后处理，如果_Material为空，不进行后处理
            if (Material)
            {
                Color color = Material.GetColor("_Color");
                color.a = start + (Time.time - _time) * speed;
                if (color.a >= 1f)
                {
                    Graphics.Blit(src, dest);
                    this.enabled = false;
                }
                else
                {
                    Material.SetColor("_Color", color);
                    //使用Material处理Texture，dest不一定是屏幕，后处理效果可以叠加的！
                    Graphics.Blit(src, dest, Material);
                }
            }
            else
            {
                //直接绘制
                Graphics.Blit(src, dest);
            }
        }
    }
}