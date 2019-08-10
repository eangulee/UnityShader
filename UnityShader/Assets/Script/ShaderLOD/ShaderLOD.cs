using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderLOD : MonoBehaviour
{
    public Shader shader;//公开属性需要关联
    public int LOD_value = 600;//外部来设置shader的LOD的值，可以是负数，可以是0
    // Use this for initialization
    void Start()
    {
        //Shader.globalMaximumLOD = LOD_value;
        Debug.Log(this.shader.maximumLOD);
    }

    // Update is called once per frame
    void Update()
    {
        // 当前这个shader最大的LOD_value;
        this.shader.maximumLOD = this.LOD_value;//关联的节点可以直接使用和改变
    }
}
