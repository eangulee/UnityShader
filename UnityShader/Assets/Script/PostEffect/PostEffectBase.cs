using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
//提供一个后处理的基类，主要功能在于直接通过Inspector面板拖入shader，生成shader对应的材质
public class PostEffectBase : MonoBehaviour
{
    public Shader shader = null;
    private Material _material = null;
    public Material Material
    {
        get
        {
            if (_material == null)
                _material = GenerateMaterial(shader);
            return _material;
        }
    }

    //根据shader创建用于屏幕特效的材质
    protected Material GenerateMaterial(Shader shader)
    {
        if (shader == null)
            return null;
        //需要判断shader是否支持
        if (shader.isSupported == false)
            return null;
        Material material = new Material(shader);
        material.hideFlags = HideFlags.DontSave;
        if (material)
            return material;
        return null;
    }

}