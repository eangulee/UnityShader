using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 将顶点转换为颜色输出为rt，再去取rt上像素的颜色，转换为世界顶点的位置
/// </summary>
public class Color2Pos : PostEffectBase
{
    public Camera depthCam;
    private RenderTexture depthTexture;
    public Material material;
    void Start()
    {

    }

    private void OnPreRender()
    {
        if (depthTexture)
        {
            RenderTexture.ReleaseTemporary(depthTexture);
            depthTexture = null;
        }
        depthCam.CopyFrom(Camera.main);
        depthTexture = RenderTexture.GetTemporary(Camera.main.pixelWidth, Camera.main.pixelHeight, 32, RenderTextureFormat.ARGB32);
        depthCam.backgroundColor = new Color(0, 0, 0, 0);
        depthCam.clearFlags = CameraClearFlags.SolidColor;
        depthCam.depthTextureMode = DepthTextureMode.Depth;
        depthCam.targetTexture = depthTexture;
        depthCam.RenderWithShader(shader, "RenderType");

        int width = depthTexture.width;
        int height = depthTexture.height;
        Texture2D texture2D = new Texture2D(width, height, TextureFormat.ARGB32, false);
        RenderTexture temp = RenderTexture.active;
        RenderTexture.active = depthTexture;
        texture2D.ReadPixels(new Rect(0, 0, width, height), 0, 0);
        texture2D.Apply();
        RenderTexture.active = temp;
        material.SetTexture("_MainTex", depthTexture);
        Color color = texture2D.GetPixel(width / 2, height / 2);
        Vector3 vector = new Vector3((color.r * 2 - 1) * 10, (color.g * 2 - 1) * 10, (color.b * 2 - 1) * 10);
        //vector.z += 0.5f;
        Debug.Log(vector);
    }

    //void OnRenderImage(RenderTexture source, RenderTexture destination)
    //{
    //    if (null != Material)
    //    {
    //        Graphics.Blit(source, destination, Material);
    //    }
    //    else
    //    {
    //        Graphics.Blit(source, destination);
    //    }
    //}

}
