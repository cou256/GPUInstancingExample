// Const
const float4x4 m4x4identity = float4x4(
	1.0, 0.0, 0.0, 0.0,
	0.0, 1.0, 0.0, 0.0,
	0.0, 0.0, 1.0, 0.0,
	0.0, 0.0, 0.0, 1.0);
// Quaternion
float4 qmul(float4 q1, float4 q2) {
	return float4(q2.xyz * q1.w + q1.xyz * q2.w + cross(q1.xyz, q2.xyz), q1.w * q2.w + dot(-q1.xyz, q2.xyz));
}
float4 qrot(float3 axis, float d) {
	const float rad = d * 3.14159265359 * 0.5 / 180.0;
	float s, c;
	sincos(rad, s, c);
	return float4(normalize(axis) * s, c);
}
// Transform
float4x4 translate_m(float3 translate) {
	float4x4 m = m4x4identity;
	m[0][3] = translate.x;
	m[1][3] = translate.y;
	m[2][3] = translate.z;
	return m;
}
float4x4 quaternion_m(float4 q) {
	float xx = q.x * q.x * 2.0;
	float yy = q.y * q.y * 2.0;
	float zz = q.z * q.z * 2.0;
	float xy = q.x * q.y * 2.0;
	float yz = q.y * q.z * 2.0;
	float zx = q.z * q.x * 2.0;
	float wx = q.w * q.x * 2.0;
	float wy = q.w * q.y * 2.0;
	float wz = q.w * q.z * 2.0;

	float4x4 m = m4x4identity;
	m[0][0] = 1.0 - yy - zz;
	m[0][1] = xy - wz;
	m[0][2] = zx + wy;
	m[1][0] = xy + wz;
	m[1][1] = 1.0 - zz - xx;
	m[1][2] = yz - wx;
	m[2][0] = zx - wy;
	m[2][1] = yz + wx;
	m[2][2] = 1.0 - xx - yy;
	return m;
}
float4x4 rotate_m(float3 euler) {
	float4 qx = qrot(float3(1.0, 0.0, 0.0), euler.x);
	float4 qy = qrot(float3(0.0, 1.0, 0.0), euler.y);
	float4 qz = qrot(float3(0.0, 0.0, 1.0), euler.z);

	float4 q = qmul(qmul(qy, qx), qz);
	return quaternion_m(q);
}
float4x4 scale_m(float3 scale) {
	float4x4 m = m4x4identity;
	m[0][0] = scale.x;
	m[1][1] = scale.y;
	m[2][2] = scale.z;
	return m;
}
float4 trs(float4 p, float3 translate, float3 euler, float3 scale) {
	return mul(mul(translate_m(translate), mul(rotate_m(euler), scale_m(scale))), p);
}
float4 trs(float4 p, float3 translate, float4 quaternion, float3 scale) {
	return mul(mul(translate_m(translate), mul(quaternion_m(quaternion), scale_m(scale))), p);
}
float4 trs(float3 p, float3 translate, float3 euler, float3 scale) {
	return trs(float4(p, 1.0), translate, euler, scale);
}
float4 trs(float3 p, float3 translate, float4 quaternion, float3 scale) {
	return trs(float4(p, 1.0), translate, quaternion, scale);
}
float4 translate(float4 p, float3 t) {
	return float4((float3)p + t, p.w);
}
float4 translate(float3 p, float3 t) {
	return translate(float4(p, 1.0f), t);
}
float4 rotate(float4 p, float3 euler) {
	return mul(rotate_m(euler), p);
}
float4 rotate(float4 p, float4 quaternion) {
	return mul(quaternion_m(quaternion), p);
}
float4 rotate(float3 p, float3 euler) {
	return rotate(float4(p, 1.0), euler);
}
float4 rotate(float3 p, float4 quaternion) {
	return rotate(float4(p, 1.0), quaternion);
}
float4 scale(float4 p, float3 s) {
	return float4((float3)p * s, p.w);
}
float4 scale(float3 p, float3 s) {
	return scale(float4(p, 1.0f), s);
}
