/********************************************************************
 FileName: ReconstructPositionViewPortRay.cs
 Description:通过深度图重建世界坐标，视口射线插值方式
*********************************************************************/
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ReconstructPositionViewPortRay : PostEffectBase
{
    //private Camera currentCamera = null;
    public Camera depthCam;
    private RenderTexture depthTexture;
    private Texture2D texture2D;
    public Material material;
    void Awake()
    {
        //currentCamera = GetComponent<Camera>();
    }

    void OnEnable()
    {
        //currentCamera.depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnDisable()
    {
        //currentCamera.depthTextureMode &= ~DepthTextureMode.Depth;
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


        var aspect = depthCam.aspect;
        var far = depthCam.farClipPlane;
        var right = transform.right;
        var up = transform.up;
        var forward = transform.forward;
        var halfFovTan = Mathf.Tan(depthCam.fieldOfView * 0.5f * Mathf.Deg2Rad);

        //计算相机在远裁剪面处的xyz三方向向量
        var rightVec = right * far * halfFovTan * aspect;
        var upVec = up * far * halfFovTan;
        var forwardVec = forward * far;

        //构建四个角的方向向量
        var topLeft = (forwardVec - rightVec + upVec);
        var topRight = (forwardVec + rightVec + upVec);
        var bottomLeft = (forwardVec - rightVec - upVec);
        var bottomRight = (forwardVec + rightVec - upVec);

        var viewPortRay = Matrix4x4.identity;
        viewPortRay.SetRow(0, topLeft);
        viewPortRay.SetRow(1, topRight);
        viewPortRay.SetRow(2, bottomLeft);
        viewPortRay.SetRow(3, bottomRight);

        Shader.SetGlobalMatrix("_ViewPortRay", viewPortRay);

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

        //if (pickPositionHandler != null)
        //    pickPositionHandler(w);
        material.SetTexture("_MainTex", texture2D);
    }

    //void OnRenderImage(RenderTexture source, RenderTexture destination)
    //{
    //    if (Material == null)
    //    {
    //        Graphics.Blit(source, destination);
    //    }
    //    else
    //    {
    //        var aspect = currentCamera.aspect;
    //        var far = currentCamera.farClipPlane;
    //        var right = transform.right;
    //        var up = transform.up;
    //        var forward = transform.forward;
    //        var halfFovTan = Mathf.Tan(currentCamera.fieldOfView * 0.5f * Mathf.Deg2Rad);

    //        //计算相机在远裁剪面处的xyz三方向向量
    //        var rightVec = right * far * halfFovTan * aspect;
    //        var upVec = up * far * halfFovTan;
    //        var forwardVec = forward * far;

    //        //构建四个角的方向向量
    //        var topLeft = (forwardVec - rightVec + upVec);
    //        var topRight = (forwardVec + rightVec + upVec);
    //        var bottomLeft = (forwardVec - rightVec - upVec);
    //        var bottomRight = (forwardVec + rightVec - upVec);

    //        var viewPortRay = Matrix4x4.identity;
    //        viewPortRay.SetRow(0, topLeft);
    //        viewPortRay.SetRow(1, topRight);
    //        viewPortRay.SetRow(2, bottomLeft);
    //        viewPortRay.SetRow(3, bottomRight);

    //        Material.SetMatrix("_ViewPortRay", viewPortRay);
    //        Graphics.Blit(source, destination, Material);
    //    }
    //}
}