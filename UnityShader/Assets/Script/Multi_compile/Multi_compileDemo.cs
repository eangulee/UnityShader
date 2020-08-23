using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Multi_compileDemo : MonoBehaviour
{
    public string Shader_Key = "TEST_1";
    public string Shader_Key_2 = "TEST_2";
    public string Shader_Key_3 = "TEST_3";
    public string Shader_Key_4 = "TEST_4";
    public MeshRenderer meshRenderer;
    public Material material;

    // Start is called before the first frame update
    void Start()
    {
        //material = meshRenderer.material;
        Debug.Log(material.IsKeywordEnabled(Shader_Key_4));
        material.DisableKeyword(Shader_Key_3);
        material.EnableKeyword(Shader_Key_4);
        Debug.Log(material.IsKeywordEnabled(Shader_Key_4));

        //string[] keys = material.shaderKeywords;
        //foreach (var key in keys)
        //{
        //    Debug.Log("key:" + key);
        //}

        Debug.Log(Shader.IsKeywordEnabled(Shader_Key));
        Shader.DisableKeyword(Shader_Key);
        Shader.EnableKeyword(Shader_Key_2);
        Debug.Log(Shader.IsKeywordEnabled(Shader_Key));
    }
}
