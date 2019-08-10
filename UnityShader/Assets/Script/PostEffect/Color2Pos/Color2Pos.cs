using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 将顶点转换为颜色输出为rt，再去取rt上像素的颜色，转换为世界顶点的位置
/// </summary>
public class Color2Pos : PostEffectBase
{
    public delegate void PickPositionHandler(Vector3 vector);
    public PickPositionHandler pickPositionHandler;

    public Camera depthCam;
    private RenderTexture depthTexture;
    private Texture2D texture2D;
    public Material material;
    void Start()
    {

    }

    private void OnPreRender()
    {
        if (depthCam == null) return;
        if (depthTexture)
        {
            RenderTexture.ReleaseTemporary(depthTexture);
            depthTexture = null;
        }
        depthCam.CopyFrom(Camera.main);
        depthTexture = RenderTexture.GetTemporary(Camera.main.pixelWidth, Camera.main.pixelHeight, 32, RenderTextureFormat.ARGB32);
        depthCam.backgroundColor = new Color(0, 0, 0, 0);
        depthCam.clearFlags = CameraClearFlags.SolidColor;
        //depthCam.depthTextureMode = DepthTextureMode.Depth;
        depthCam.targetTexture = depthTexture;
        depthCam.RenderWithShader(shader, "RenderType");

        int width = depthTexture.width;
        int height = depthTexture.height;
        texture2D = new Texture2D(width, height, TextureFormat.ARGB32, false);
        RenderTexture temp = RenderTexture.active;
        RenderTexture.active = depthTexture;
        texture2D.ReadPixels(new Rect(0, 0, width, height), 0, 0);
        texture2D.Apply();
        RenderTexture.active = temp;
        Color color = texture2D.GetPixel(width / 2, height / 2);
        Vector3 w = new Vector3(color.r, color.g, color.b);
        float l = color.a * 100f;
        w.x = (w.x - 0.5f) * 2 * l;
        w.y = (w.y - 0.5f) * 2 * l;
        w.z = (w.z - 0.5f) * 2 * l;
        Debug.Log(w);

        if (pickPositionHandler != null)
            pickPositionHandler(w);
        material.SetTexture("_MainTex", texture2D);
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
