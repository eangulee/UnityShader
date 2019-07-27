using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class LineData
{
    [Tooltip("屏幕起始坐标")]
    public Vector2 startPoint;
    [Tooltip("屏幕结束坐标")]
    public Vector2 endPoint;
}

[ExecuteInEditMode]
public class VectorLine : MonoBehaviour
{
    public LineData[] lineDatas;
    private List<LineRenderer> lineRenderers = new List<LineRenderer>();
    void Start()
    {
        DrawVectorLine();
    }

    [ContextMenu("DrawVectorLine")]
    public void DrawVectorLine()
    {
        if (lineDatas == null || lineDatas.Length == 0)
            return;

        for (int i = 0,count = lineRenderers.Count; i < count; i++)
        {
            LineRenderer lineRenderer = lineRenderers[i];
            if (Application.isPlaying)
                GameObject.Destroy(lineRenderer.gameObject);
            else
                DestroyImmediate(lineRenderer.gameObject);
        }
        lineRenderers.Clear();

        for (int i = 0,length = lineDatas.Length; i < length; i++)
        {
            LineData lineData = lineDatas[i];
            GameObject child = new GameObject();
            child.transform.SetParent(this.transform);
            child.name = i.ToString();
            LineRenderer lineRenderer = child.AddComponent<LineRenderer>();
            Material material = new Material(Shader.Find("Custom/VectorLine"));
            material.SetVector("_CameraDir", Camera.main.transform.forward);
            lineRenderer.material = material;
            lineRenderer.positionCount = 2;            
            lineRenderer.SetPosition(0,lineData.startPoint);
            lineRenderer.SetPosition(1, lineData.endPoint);
            lineRenderers.Add(lineRenderer);
        }
    }
}
