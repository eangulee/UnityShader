
using UnityEngine;

public class WaterWaveEffect : PostEffectBase
{
    //距离系数
    public float distanceFactor = 60.0f;
    //时间系数
    public float timeFactor = -30.0f;
    //sin函数结果系数
    public float totalFactor = 1.0f;
    //波纹宽度
    public float waveWidth = 0.3f;
    //波纹扩散的速度
    public float waveSpeed = 0.3f;
    private float waveStartTime;
    private Vector4 startPos = new Vector4(0.5f, 0.5f, 0, 0);

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //计算波纹移动的距离，根据enable到目前的时间*速度求解
        float curWaveDistance = (Time.time - waveStartTime) * waveSpeed;
        //设置一系列参数
        Material.SetFloat("_distanceFactor", distanceFactor);
        Material.SetFloat("_timeFactor", timeFactor);
        Material.SetFloat("_totalFactor", totalFactor);
        Material.SetFloat("_waveWidth", waveWidth);
        Material.SetFloat("_curWaveDis", curWaveDistance);
        Material.SetVector("_startPos", startPos);

        Graphics.Blit(source, destination, Material);
    }

    void OnEnable()
    {
        //设置startTime
        waveStartTime = Time.time;
    }

    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Vector2 mousePos = Input.mousePosition;
            //将mousePos转化为（0，1）区间
            startPos = new Vector4(mousePos.x / Screen.width, mousePos.y / Screen.height, 0, 0);
            waveStartTime = Time.time;
        }

    }
}