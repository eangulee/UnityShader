using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class FirstViewer : MonoBehaviour
{
    public bool workable;
    public float m_speed = 5f;
    // Use this for initialization
    void Awake()
    {
#if !UNITY_EDITOR
        GameObject.Destroy(this);
#endif
    }

    private void Update()
    {
        if (!workable) return;
        if (Input.GetMouseButton(1))
            RotateControl();
        MoveControlByTranslate();
    }
    //鼠标敏度  
    public float mousesSensity = 10F;

    //上下最大视角(Y视角)  
    public float minYLimit = -20F;
    public float maxYLimit = 80F;

    Vector3 m_camRotation;
    void RotateControl()
    {
        //根据鼠标的移动,获取相机旋转的角度
        m_camRotation.x = transform.localEulerAngles.y + Input.GetAxis("Mouse X") * mousesSensity;
        m_camRotation.y += Input.GetAxis("Mouse Y") * mousesSensity;
        //角度限制
        m_camRotation.y = Mathf.Clamp(m_camRotation.y, minYLimit, maxYLimit);
        //相机角度随着鼠标旋转  
        transform.localEulerAngles = new Vector3(-m_camRotation.y, m_camRotation.x, 0);
    }

    //Translate移动控制函数
    void MoveControlByTranslate()
    {
        if (Input.GetKey(KeyCode.W) | Input.GetKey(KeyCode.UpArrow)) //前
        {
            this.transform.Translate(Vector3.forward * m_speed * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.S) | Input.GetKey(KeyCode.DownArrow)) //后
        {
            this.transform.Translate(Vector3.forward * -m_speed * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.A) | Input.GetKey(KeyCode.LeftArrow)) //左
        {
            this.transform.Translate(Vector3.right * -m_speed * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.D) | Input.GetKey(KeyCode.RightArrow)) //右
        {
            this.transform.Translate(Vector3.right * m_speed * Time.deltaTime);
        }
    }
}
