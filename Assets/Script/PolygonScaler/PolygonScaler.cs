using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct AdjacentVector
{
    public Vector3 v1;
    public Vector3 v2;
    public bool isConcave;

    public AdjacentVector(Vector3 v1, Vector3 v2, bool isConcave) : this()
    {
        this.v1 = v1;
        this.v2 = v2;
        this.isConcave = isConcave;
    }
}

[RequireComponent(typeof(PolygonDrawer))]
[ExecuteInEditMode]
public class PolygonScaler : MonoBehaviour
{
    [Tooltip("缩放宽度，+为扩大，-为缩小")]
    public float thickness = 1f;
    public PolygonDrawer targetPolygonDrawer;
    private PolygonDrawer _polygonDrawer;
    private List<AdjacentVector> vertor = new List<AdjacentVector>();//向量集
    private List<Vector3> scaleVertices = new List<Vector3>();
    void Start()
    {
        _polygonDrawer = GetComponent<PolygonDrawer>();
        Draw();
    }

    [ContextMenu("Draw")]
    public void Draw()
    {
        vertor.Clear();
        scaleVertices.Clear();

        MeshFilter meshFilter = targetPolygonDrawer.GetComponent<MeshFilter>();
        Mesh mesh = null;
        if (Application.isPlaying)
            mesh = meshFilter.mesh;
        else
            mesh = meshFilter.sharedMesh;
        Vector3[] vertices = mesh.vertices;
        Vector3[] normals = mesh.normals;

        //所有顶点做差，求得向量集
        for (int i = 0, length = vertices.Length; i < length; i++)
        {
            Vector3 v1 = vertices[i] - vertices[i == length - 1 ? 0 : i + 1];
            Vector3 v2 = vertices[i] - vertices[i == 0 ? length - 1 : i - 1];
            bool isConcave = Vector3.Dot(Vector3.Cross(v1, v2), normals[i]) < 0;//判定是否为凹点
            Debug.Log("v1:" + v1 + ",v2:" + v2 + "," + Vector3.Cross(v1, v2));
            vertor.Add(new AdjacentVector(v1.normalized, v2.normalized, isConcave));
        }
        for (int i = 0, length = vertices.Length; i < length; i++)
        {
            int startIndex = i == 0 ? length - 1 : i - 1;
            int endIndex = i;
            //利用叉乘求sinAlpha = |a x b|/|a||b| 这里a,b均为归一化的向量，长度为1，可以简化为sinAlpha = |a x b|
            Vector3 v1 = vertor[i].v1;
            Vector3 v2 = vertor[i].v2;
            float sinAlpha = Vector3.Cross(v1, v2).magnitude;
            if (sinAlpha > 0)//添加不共线的点到列表，忽略共线的点
            {
                //新的顶点是原顶点两条邻边方向所组成平行四边的对称点，所以新的顶点 p1 = p0 + d/sin * a + d/sin * b = p0 + d/sin *(a + b)
                sinAlpha = vertor[i].isConcave ? -sinAlpha : sinAlpha;//凹点要反向
                Vector3 point = vertices[i] + thickness / sinAlpha * (v1 + v2);
                scaleVertices.Add(point);
            }
        }
        _polygonDrawer.vertices = scaleVertices.ToArray();
        _polygonDrawer.Draw();
    }
}
