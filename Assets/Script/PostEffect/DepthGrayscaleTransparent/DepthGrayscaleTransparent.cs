using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DepthGrayscaleTransparent : PostEffectBase
{
    public RawImage rawImage;
    public Camera depthCam;
    public Material material;
    private RenderTexture depthTexture;
    public Texture2D texture2D;

    private Matrix4x4 VPMatrix
    {
        get { return Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix; }
    }

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
        //depthCam.depthTextureMode = DepthTextureMode.Depth;
        depthCam.targetTexture = depthTexture;
        depthCam.RenderWithShader(shader, "RenderType");
        Material m = rawImage.material;
        m.mainTexture = depthTexture;
        m.SetMatrix("_CurrentInverseVP", VPMatrix.inverse);


        int width = depthTexture.width;
        int height = depthTexture.height;
        texture2D = new Texture2D(width, height, TextureFormat.ARGB32, false);
        RenderTexture temp = RenderTexture.active;
        RenderTexture.active = depthTexture;
        texture2D.ReadPixels(new Rect(0, 0, width, height), 0, 0);
        texture2D.Apply();
        RenderTexture.active = temp;
        Color color = texture2D.GetPixel(width / 2, height / 2);
        //Vector3 vector = new Vector3((color.r * 2 - 1) * 100, (color.g * 2 - 1) * 100, (color.b * 2 - 1) * 100);
        Vector4 ndc = new Vector4(0.5f * 2f - 1f, 0.5f * 2f - 1f, color.r * 2 - 1, color.a);//NDC坐标
        Vector4 D = VPMatrix.inverse * ndc;
        Vector4 W = D / D.w; //将齐次坐标w分量变1得到世界坐标
        Debug.Log(W);

        //Vector3 vector = new Vector3((color.r * 2 - 1) * 10, (color.g * 2 - 1) * 10, (color.b * 2 - 1) * 10);
        ////vector.z += 0.5f;
        //Debug.Log(vector);
    }

    //private void OnPostRender()
    //{
    //    float width = rawImage.rectTransform.sizeDelta.x;
    //    float height = rawImage.rectTransform.sizeDelta.y;
    //    Texture2D texture2D = new Texture2D((int)width, (int)height, TextureFormat.ARGB32, false);
    //    //RenderTexture temp = RenderTexture.active;
    //    //RenderTexture.active = depthTexture;
    //    texture2D.ReadPixels(new Rect(0, 0, width, height), 0, 0);
    //    //texture2D.Apply();
    //    //RenderTexture.active = temp;
    //    Color color = texture2D.GetPixel((int)width / 2, (int)height / 2);
    //    Vector4 w = new Vector4(color.r, color.g, color.b, color.a);
    //    w.x -= 0.5f;
    //    w.y -= 0.5f;
    //    w.z -= 0.5f;
    //    w *= 2f;
    //    float dis = Vector3.Magnitude((Vector3)w);
    //    w *= dis;
    //    Debug.Log(w);
    //}

    //void OnRenderImage(RenderTexture source, RenderTexture destination)
    //{
    //    if (null != material)
    //    {
    //        Graphics.Blit(source, destination, material);
    //    }
    //    else
    //    {
    //        Graphics.Blit(source, destination);
    //    }
    //}
}
