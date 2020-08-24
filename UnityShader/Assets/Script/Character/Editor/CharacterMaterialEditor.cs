using UnityEngine;
using System.Collections;
using UnityEditor;

public class CharacterMaterialEditor : MaterialEditor
{
    public const string CLIP_POSITION_OFF = "CLIP_POSITION_OFF";
    public const string CLIP_POSITION_ON = "CLIP_POSITION_ON";
    public const string RIMLIGHT_ON = "RIMLIGHT_ON";
    public const string RIMLIGHT_OFF = "RIMLIGHT_OFF";
    public const string BODY_ON = "BODY_ON";
    public const string BODY_OFF = "BODY_OFF";
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        Material mat = target as Material;
        if (EditorGUILayout.Toggle("Is Body", mat.IsKeywordEnabled(BODY_ON) ? true : false))
        {
            mat.SetInt("_IsBody", 1);
            mat.EnableKeyword(BODY_ON);
            mat.DisableKeyword(BODY_OFF);
        }
        else
        {
            mat.SetInt("_IsBody", 0);
            mat.EnableKeyword(BODY_OFF);
            mat.DisableKeyword(BODY_ON);
        }
        if (EditorGUILayout.Toggle("Open Clip Position", mat.IsKeywordEnabled(CLIP_POSITION_ON) ? true : false))
        {
            mat.SetInt("_ClipPosition", 1);
            mat.EnableKeyword(CLIP_POSITION_ON);
            mat.DisableKeyword(CLIP_POSITION_OFF);
        }
        else
        {
            mat.SetInt("_ClipPosition", 0);
            mat.EnableKeyword(CLIP_POSITION_OFF);
            mat.DisableKeyword(CLIP_POSITION_ON);
        }
        if (EditorGUILayout.Toggle("Open Rim", mat.IsKeywordEnabled(RIMLIGHT_ON) ? true : false))
        {
            mat.SetInt("_RimLight", 1);
            mat.EnableKeyword(RIMLIGHT_ON);
            mat.DisableKeyword(RIMLIGHT_OFF);
        }
        else
        {
            mat.SetInt("_RimLight", 0);
            mat.EnableKeyword(RIMLIGHT_OFF);
            mat.DisableKeyword(RIMLIGHT_ON);
        }
    }
}
