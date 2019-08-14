
/********************************************************************
 FileName: ReconstructPositionInvMatrix.cs
 Description:从深度图构建世界坐标，逆矩阵方式
*********************************************************************/
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ReconstructPositionInvMatrix : PostEffectBase
{
    private Camera currentCamera = null;

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
            var vpMatrix = currentCamera.projectionMatrix * currentCamera.worldToCameraMatrix;
            Material.SetMatrix("_InverseVPMatrix", vpMatrix.inverse);
            Graphics.Blit(source, destination, Material);
        }
    }
}