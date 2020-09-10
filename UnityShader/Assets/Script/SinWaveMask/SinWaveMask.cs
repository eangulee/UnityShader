using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
public class SinWaveMask : MonoBehaviour
{
    public Graphic graphic;
    private Material material;
    public float speed = 0.1f;

    private void Start()
    {
        material = graphic.material;
        StartCoroutine("OffsetCoroutine");
    }

    private IEnumerator OffsetCoroutine()
    {
        float time = Time.time;
        float offset = 0;
        while (true)
        {
            yield return null;
            offset += Time.deltaTime * speed;
            material.SetFloat("_Offset",offset);
            if (offset > 1)
                offset = 0f;
        }
    }
}
