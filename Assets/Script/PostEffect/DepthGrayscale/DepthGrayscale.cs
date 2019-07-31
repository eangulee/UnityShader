using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class DepthGrayscale : PostEffectBase
{
    private Camera mCamera;
    void Start()
    {
        mCamera = gameObject.GetComponent<Camera>();
        //设置Camera的depthTextureMode,使得摄像机能生成深度图。
        if (mCamera)
        {
            mCamera.depthTextureMode = DepthTextureMode.Depth;
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (null != Material)
        {
            Graphics.Blit(source, destination, Material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
