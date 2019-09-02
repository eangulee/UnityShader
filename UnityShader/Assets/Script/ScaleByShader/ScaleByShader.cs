using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ScaleByShader : MonoBehaviour
{
    public Renderer[] renderers;

    [SerializeField, SetProperty("scale")]
    private float _scale = 1f;
    public float scale
    {
        get
        {
            return _scale;
        }
        set
        {
            _scale = value;
            foreach (var r in renderers)
            {
                foreach (var m in r.materials)
                {
                    m.SetFloat("_Scale", value);
                }
            }
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        renderers = this.gameObject.GetComponentsInChildren<Renderer>(true);
    }
}
