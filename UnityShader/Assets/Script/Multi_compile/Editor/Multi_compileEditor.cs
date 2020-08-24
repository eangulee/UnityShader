using UnityEngine;
using System.Collections;
using UnityEditor;

public class Multi_compileEditor : MaterialEditor
{
    public const string Shader_Key_1 = "TEST_1";
    public const string Shader_Key_2 = "TEST_2";
    public const string Shader_Key_3 = "TEST_3";
    public const string Shader_Key_4 = "TEST_4";
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        Material mat = target as Material;
        if (EditorGUILayout.Toggle(Shader_Key_2, mat.IsKeywordEnabled(Shader_Key_2) ? true : false))
        {
            mat.SetInt("_" + Shader_Key_2, 1);
            mat.EnableKeyword(Shader_Key_2);
            mat.DisableKeyword(Shader_Key_1);
        }
        else
        {
            mat.SetInt("_" + Shader_Key_2, 0);
            mat.EnableKeyword(Shader_Key_1);
            mat.DisableKeyword(Shader_Key_2);
        }
        if (EditorGUILayout.Toggle(Shader_Key_4, mat.IsKeywordEnabled(Shader_Key_4) ? true : false))
        {
            mat.SetInt("_" + Shader_Key_4, 1);
            mat.EnableKeyword(Shader_Key_4);
            mat.DisableKeyword(Shader_Key_3);
        }
        else
        {
            mat.SetInt("_" + Shader_Key_4, 0);
            mat.EnableKeyword(Shader_Key_3);
            mat.DisableKeyword(Shader_Key_4);
        }
    }
}
