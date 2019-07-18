using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPUInstance : MonoBehaviour
{
    public MeshRenderer[] objects;
    // Start is called before the first frame update
    void Start()
    {
        objects = GetComponentsInChildren<MeshRenderer>(true);
        SetColor();
    }

    public void SetColor()
    {
        MaterialPropertyBlock props = new MaterialPropertyBlock();

        foreach (MeshRenderer renderer in objects)
        {
            float r = Random.Range(0.0f, 1.0f);
            float g = Random.Range(0.0f, 1.0f);
            float b = Random.Range(0.0f, 1.0f);
            props.SetColor("_Color", new Color(r, g, b));

            renderer.SetPropertyBlock(props);
        }
    }
}
