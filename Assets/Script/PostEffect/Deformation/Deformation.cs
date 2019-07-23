using System.Collections;
using System.Collections.Generic;
using UnityEngine;

///变形
[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class Deformation : PostEffectBase
{
    private Matrix4x4 _originalProjection;
    public Camera camera;
    private Matrix4x4 _p;
    public float widthFactor = 0.15f;
    public float heightFactor = 0.12f;
    private void Awake()
    {
        if (!camera)
            camera = GetComponent<Camera>();
        _originalProjection = camera.projectionMatrix;
    }

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        _p = _originalProjection;
        _p.m01 += Mathf.Sin(Time.time * widthFactor);
        _p.m11 += Mathf.Sin(Time.time * heightFactor);
        //_p.m22 += Mathf.Sin(Time.time * heightFactor) * 0.1F;
        Camera.main.projectionMatrix = _p;
    }
}
