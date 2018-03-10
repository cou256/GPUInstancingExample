using System.Runtime.InteropServices;
using UnityEngine;

public class GraphicsDrawMeshInstanced : MonoBehaviour
{
    [SerializeField] int numberOfDraw;
    [SerializeField] float velocity;
    [SerializeField] Vector3 bounds;
    [SerializeField] Mesh mesh;
    [SerializeField] Shader shader;
    [SerializeField] ComputeShader kernel;

    ComputeBuffer transformBuff;
    ComputeBuffer argsBuff;
    Material mat;

    void OnDisable()
    {
        transformBuff.Release();
        argsBuff.Release();
        transformBuff = null;
        argsBuff = null;
        Destroy(mat);
    }
    void Start()
    {
        transformBuff = CreateComputeBuffer(new TransformStruct[numberOfDraw]);

        var args = new uint[5] { 0, 0, 0, 0, 0 };
        args[0] = mesh.GetIndexCount(0);
        args[1] = (uint)numberOfDraw;
        argsBuff = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        argsBuff.SetData(args);
        kernel.SetBuffer(kernel.FindKernel("Calculate"), "_TransformBuff", transformBuff);

        mat = new Material(shader);
        mat.SetBuffer("_TransformBuff", transformBuff);
    }
    void Update()
    {
        kernel.SetFloat("_DeltaTime", Time.deltaTime);
        kernel.SetFloat("_Velocity", velocity);
        kernel.SetVector("_Bounds", bounds);
        kernel.Dispatch(kernel.FindKernel("Calculate"), numberOfDraw / 8 + 1, 1, 1);
        Graphics.DrawMeshInstancedIndirect(mesh, 0, mat, new Bounds(Vector3.zero, bounds), argsBuff);
    }
    struct TransformStruct
    {
        public Vector3 translate;
        public Vector3 rotation;
        public Vector3 scale;
        public Vector3 velocity;
        public bool init;
    }
    ComputeBuffer CreateComputeBuffer<T>(T[] data, ComputeBufferType type = ComputeBufferType.Default)
    {
        var computeBuffer = new ComputeBuffer(data.Length, Marshal.SizeOf(typeof(T)), type);
        computeBuffer.SetData(data);
        return computeBuffer;
    }
}