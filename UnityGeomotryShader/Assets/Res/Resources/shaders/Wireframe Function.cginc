#ifndef Unity_EANGULEE_WIREFRAME
#define Unity_EANGULEE_WIREFRAME
// Wireframe shader based on the the following
// http://developer.download.nvidia.com/SDK/10/direct3d/Source/SolidWireframe/Doc/SolidWireframe.pdf


#include "UnityCG.cginc"

float _WireThickness;
half4 _LineColor;

struct appdata
{
	float4 vertex : POSITION;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2g
{
	float4 projectionSpaceVertex : SV_POSITION;
	// float4 worldSpacePosition : TEXCOORD1;
	float4 vertexPos : TEXCOORD2;
	UNITY_VERTEX_OUTPUT_STEREO
};

struct g2f
{
	float4 projectionSpaceVertex : SV_POSITION;
	// float4 worldSpacePosition : TEXCOORD0;
	float4 dist : TEXCOORD1;
	int maxIndex : TEXCOORD2;
	UNITY_VERTEX_OUTPUT_STEREO
};

v2g vert (appdata v)
{
	v2g o;
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
	o.projectionSpaceVertex = UnityObjectToClipPos(v.vertex);
	o.vertexPos = v.vertex;
	return o;
}

[maxvertexcount(3)]
void geom(triangle v2g i[3], inout TriangleStream<g2f> triangleStream)
{
	float2 _p0 = i[0].projectionSpaceVertex.xy / i[0].projectionSpaceVertex.w;
	float2 _p1 = i[1].projectionSpaceVertex.xy / i[1].projectionSpaceVertex.w;
	float2 _p2 = i[2].projectionSpaceVertex.xy / i[2].projectionSpaceVertex.w;

	float3 p0 = i[0].vertexPos;
	float3 p1 = i[1].vertexPos;
	float3 p2 = i[2].vertexPos;

	float2 edge0 = _p2 - _p1;
	float2 edge1 = _p2 - _p0;
	float2 edge2 = _p1 - _p0;

	float s0 = length(p2 - p1);
	float s1 = length(p2 - p0);
	float s2 = length(p1 - p0);

	// To find the distance to the opposite edge, we take the
	// formula for finding the area of a triangle Area = Base/2 * Height, 
	// and solve for the Height = (Area * 2)/Base.
	// We can get the area of a triangle by taking its cross product
	// divided by 2.  However we can avoid dividing our area/base by 2
	// since our cross product will already be double our area.
	float area = abs(edge1.x * edge2.y - edge1.y * edge2.x);
	float wireThickness = 800 - _WireThickness;//经验系数（不清楚怎么来的，可能是配出来的）
	int maxIndex = 0;

	#if ENABLE_DRAWQUAD
	if(s1 > s0)
	{
		if(s1 > s2)
			maxIndex = 1;
		else
			maxIndex = 2;
	}
	else if(s2 > s0)
	{
		maxIndex = 2;
	}
	#endif
	g2f o;

	o.projectionSpaceVertex = i[0].projectionSpaceVertex;
	o.dist.xyz = float3( (area / length(edge0)), 0.0, 0.0) * wireThickness * o.projectionSpaceVertex.w;
	o.dist.w = 1.0 / o.projectionSpaceVertex.w;
	o.maxIndex = maxIndex;
	UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(i[0], o);
	triangleStream.Append(o);

	o.projectionSpaceVertex = i[1].projectionSpaceVertex;
	o.dist.xyz = float3(0.0, (area / length(edge1)), 0.0) * wireThickness * o.projectionSpaceVertex.w;
	o.dist.w = 1.0 / o.projectionSpaceVertex.w;
	o.maxIndex = maxIndex;
	UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(i[1], o);
	triangleStream.Append(o);

	o.projectionSpaceVertex = i[2].projectionSpaceVertex;
	o.dist.xyz = float3(0.0, 0.0, (area / length(edge2))) * wireThickness * o.projectionSpaceVertex.w;
	o.dist.w = 1.0 / o.projectionSpaceVertex.w;
	o.maxIndex = maxIndex;
	UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(i[2], o);
	triangleStream.Append(o);
}

fixed4 frag (g2f i) : SV_Target
{				
	float minDistanceToEdge;
	#if ENABLE_DRAWQUAD
	if(i.maxIndex == 0)
		minDistanceToEdge = min(i.dist.y, i.dist.z);
	else if(i.maxIndex == 1)
		minDistanceToEdge = min(i.dist.x, i.dist.z);
	else 
		minDistanceToEdge = min(i.dist.x, i.dist.y);
	#else
		minDistanceToEdge = min(i.dist.x, min(i.dist.y, i.dist.z)) * i.dist.w;
	#endif
	// Early out if we know we are not on a line segment.
	if(minDistanceToEdge > 0.9)
	{
		return fixed4(0,0,0,0);
	}

	// Smooth our line out
	float t = exp2(-2 * minDistanceToEdge * minDistanceToEdge);
	fixed4 wireColor = _LineColor;

	fixed4 finalColor = lerp(float4(0,0,0,0), wireColor, t);
	finalColor.a = t;

	return finalColor;
}
#endif