using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectionMatrix : MonoBehaviour
{
    public Transform sphereTrans;
    // Start is called before the first frame update
    void Start()
    {
        Vector3 sphereViewSpace = Camera.main.WorldToViewportPoint(sphereTrans.position);
        Vector3 sphereCameraObjectSpace = Camera.main.transform.worldToLocalMatrix * sphereTrans.position;
        sphereCameraObjectSpace += Camera.main.transform.position;
        Debug.Log(sphereViewSpace);
        Debug.Log(sphereCameraObjectSpace);
    }

    // Update is called once per frame
    void Update()
    {

    }
}
