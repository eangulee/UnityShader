using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class ConeCreatorEditor
{
    static string meshPrefabPath = "Assets/Res/Models/Mesh/";//圆锥Mesh保存路径
    static string meshName = "Cone.asset";//圆锥
    [MenuItem("GameObject/3D Object/Cone", false, priority = 7)]
    public static void CreateCone()
    {
        SpawnConeInHierarchy();
    }


    private static void SetMesh(GameObject go)
    {
        if (null == go)
            return;
        //仿Cylinder参数
        float myRadius = 0.5f;
        int myAngleStep = 20;
        Vector3 myTopCenter = new Vector3(0, 1.5f, 0);
        Vector3 myBottomCenter = Vector3.zero;
        //构建顶点数组和UV数组
        Vector3[] myVertices = new Vector3[360 / myAngleStep * 2 + 2];
        //
        Vector2[] myUV = new Vector2[myVertices.Length];
        //这里我把锥尖顶点放在了顶点数组最后一个
        myVertices[0] = myBottomCenter;
        myVertices[myVertices.Length - 1] = myTopCenter;
        myUV[0] = new Vector2(0.5f, 0.5f);
        myUV[myVertices.Length - 1] = new Vector2(0.5f, 0.5f);
        //因为圆上顶点坐标相同，只是索引不同，所以这里循环一般长度即可
        for (int i = 1; i <= (myVertices.Length - 2) / 2; i++)
        {
            float curAngle = i * myAngleStep * Mathf.Deg2Rad;
            float curX = myRadius * Mathf.Cos(curAngle);
            float curZ = myRadius * Mathf.Sin(curAngle);
            myVertices[i] = myVertices[i + (myVertices.Length - 2) / 2] = new Vector3(curX, 0, curZ);
            myUV[i] = myUV[i + (myVertices.Length - 2) / 2] = new Vector2(curX + 0.5f, curZ + 0.5f);

        }
        //构建三角形数组
        int[] myTriangle = new int[(myVertices.Length - 2) * 3];
        for (int i = 0; i <= myTriangle.Length - 3; i = i + 3)
        {
            if (i + 2 < myTriangle.Length / 2)
            {
                myTriangle[i] = 0;
                myTriangle[i + 1] = i / 3 + 1;
                myTriangle[i + 2] = i + 2 == myTriangle.Length / 2 - 1 ? 1 : i / 3 + 2;
            }
            else
            {
                //绘制锥体部分，索引组起始点都为锥尖
                myTriangle[i] = myVertices.Length - 1;
                //锥体最后一个三角形的中间顶点索引值为19
                myTriangle[i + 1] = i == myTriangle.Length - 3 ? 19 : i / 3 + 2;
                myTriangle[i + 2] = i / 3 + 1;
            }
        }

        //构建mesh
        Mesh myMesh;
        if (!File.Exists(meshPrefabPath + meshName))
        {
            myMesh = new Mesh();
            myMesh.name = "Cone";
            myMesh.vertices = myVertices;
            myMesh.triangles = myTriangle;
            myMesh.uv = myUV;
            myMesh.RecalculateBounds();
            myMesh.RecalculateNormals();
            myMesh.RecalculateTangents();
            if (!Directory.Exists(meshPrefabPath))
                Directory.CreateDirectory(meshPrefabPath);
            AssetDatabase.CreateAsset(myMesh, meshPrefabPath + meshName);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
        else
        {
            myMesh = AssetDatabase.LoadAssetAtPath<Mesh>(meshPrefabPath + meshName);
        }


        //分配mesh
        MeshFilter mf = go.AddComponent<MeshFilter>();
        mf.mesh = myMesh;
        //分配材质
        MeshRenderer mr = go.AddComponent<MeshRenderer>();
        Material myMat = new Material(Shader.Find("Standard"));
        mr.sharedMaterial = myMat;
    }

    private static void SpawnConeInHierarchy()
    {
        Transform[] selections = Selection.GetTransforms(SelectionMode.TopLevel | SelectionMode.ExcludePrefab);

        if (selections.Length <= 0)
        {
            GameObject cone = new GameObject("Cone");
            cone.transform.position = Vector3.zero;
            cone.transform.rotation = Quaternion.identity;
            cone.transform.localScale = Vector3.one;
            //设置创建操作可撤销
            Undo.RegisterCreatedObjectUndo(cone, "Undo Creating Cone");
            SetMesh(cone);
            return;
        }

        foreach (Transform selection in selections)
        {
            GameObject cone = new GameObject("Cone");
            cone.transform.SetParent(selection);
            cone.transform.localPosition = Vector3.zero;
            cone.transform.localRotation = Quaternion.identity;
            cone.transform.localScale = Vector3.one;
            //设置创建操作可撤销
            Undo.RegisterCreatedObjectUndo(cone, "Undo Creating Cone");
            SetMesh(cone);
        }
    }
}