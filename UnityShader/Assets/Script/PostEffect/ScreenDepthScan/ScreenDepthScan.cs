/********************************************************************
 FileName: ScreenDepthScan.cs
 Description:深度扫描线效果
*********************************************************************/
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ScreenDepthScan : PostEffectBase
{
    private Camera currentCamera = null;

    [Range(0.0f, 1.0f)]
    public float scanValue = 0.05f;
    [Range(0.0f, 0.5f)]
    public float scanLineWidth = 0.02f;
    [Range(0.0f, 10.0f)]
    public float scanLightStrength = 10.0f;
    public Color scanLineColor = Color.white;

    void Awake()
    {
        currentCamera = GetComponent<Camera>();
    }

    void OnEnable()
    {
        currentCamera.depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnDisable()
    {
        currentCamera.depthTextureMode &= ~DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material == null)
        {
            Graphics.Blit(source, destination);
        }
        else
        {
            //限制一下最大值，最小值
            float lerpValue = Mathf.Min(0.95f, 1 - scanValue);
            if (lerpValue < 0.0005f)
                lerpValue = 1;

            //此处可以一个vec4传进去优化
            Material.SetFloat("_ScanValue", lerpValue);
            Material.SetFloat("_ScanLineWidth", scanLineWidth);
            Material.SetFloat("_ScanLightStrength", scanLightStrength);
            Material.SetColor("_ScanLineColor", scanLineColor);
            Graphics.Blit(source, destination, Material);
        }

    }
}