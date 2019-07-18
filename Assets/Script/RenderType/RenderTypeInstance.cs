using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum RenderType
{
    None = 0,
    Opaque = 1,//用于大多数着色器（法线着色器、自发光着色器、反射着色器以及地形的着色器）。
    Transparent = 2,//用于半透明着色器（透明着色器、粒子着色器、字体着色器、地形额外通道的着色器）。
    TransparentCutout = 3,//蒙皮透明着色器（Transparent Cutout，两个通道的植被着色器）。
    Background = 4,//Skybox shaders. 天空盒着色器。
    Overlay = 5,//GUITexture, Halo, Flare shaders. 光晕着色器、闪光着色器。
    TreeOpaque = 6,//terrain engine tree bark. 地形引擎中的树皮。
    TreeTransparentCutout = 7,//terrain engine tree leaves. 地形引擎中的树叶。
    TreeBillboard = 8,//terrain engine billboarded trees. 地形引擎中的广告牌树。
    Grass = 9,//terrain engine grass. 地形引擎中的草。
    GrassBillboard = 10,// terrain engine billboarded grass. 地形引擎何中的广告牌草。
}

public class RenderTypeInstance : MonoBehaviour
{
    public RenderType renderType = RenderType.Opaque;
    public Shader shader;
    // Start is called before the first frame update
    void Start()
    {
        Debug.Log(renderType.ToString());
        Camera.main.SetReplacementShader(shader, "RenderType");
    }

    // Update is called once per frame
    void Update()
    {

    }
}
