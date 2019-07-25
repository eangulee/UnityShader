
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 绘制多边形
/// TODO: 存在两点重合时绘制有问题
/// </summary>
[ExecuteInEditMode]
public class PolygonDrawer : MonoBehaviour
{
    public Shader shader;
    public Vector3[] vertices;
    private MeshRenderer mRenderer;
    private MeshFilter mFilter;
    //public UnityOutlineFX unityOutlineFX;
    void Start()
    {
        Draw();
    }

    void Update()
    {
        //Draw();
    }

    [ContextMenu("Draw")]
    public void Draw()
    {
        Vector2[] vertices2D = new Vector2[vertices.Length];
        Vector3[] vertices3D = new Vector3[vertices.Length];
        for (int i = 0; i < vertices.Length; i++)
        {
            Vector3 vertice = vertices[i];
            vertices2D[i] = new Vector2(vertice.x, vertice.y);
            vertices3D[i] = vertice;
        }

        Triangulator tr = new Triangulator(vertices2D);
        int[] triangles = tr.Triangulate();

        Mesh mesh = new Mesh();
        mesh.vertices = vertices3D;
        mesh.triangles = triangles;

        if (mRenderer == null)
        {
            mRenderer = gameObject.GetOrAddComponent<MeshRenderer>();
        }
        mRenderer.material = new Material(shader);
        if (mFilter == null)
        {
            mFilter = gameObject.GetOrAddComponent<MeshFilter>();
        }
        mesh.RecalculateNormals();        
        mFilter.mesh = mesh;
        //unityOutlineFX.AddRenderers(new List<Renderer>() { mRenderer });
    }
}