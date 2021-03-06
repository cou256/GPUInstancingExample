﻿using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.Rendering;

public class CommandBufferDrawProcedural : MonoBehaviour
{
    [SerializeField] int numberOfDraw;
    [SerializeField] float velocity;
    [SerializeField] Vector3 bounds;
    [SerializeField] Mesh mesh;
    [SerializeField] Shader shader;
    [SerializeField] ComputeShader kernel;
    [SerializeField] MeshTopology meshTopology;

    ComputeBuffer meshBuff;
    ComputeBuffer transformBuff;
    CommandBuffer commandBuffer;
    Material mat;

    void OnDisable()
    {
        meshBuff.Release();
        transformBuff.Release();
        commandBuffer.Release();
    }
    void Start()
    {
        meshBuff = CreateMeshBuffer(mesh);
        transformBuff = CreateComputeBuffer(new TransformStruct[numberOfDraw]);

        mat = new Material(shader);
        mat.SetBuffer("_MeshBuff", meshBuff);
        mat.SetBuffer("_TransformBuff", transformBuff);
        kernel.SetBuffer(kernel.FindKernel("Calculate"), "_TransformBuff", transformBuff);
        commandBuffer = new CommandBuffer();
        Camera.main.AddCommandBuffer(CameraEvent.AfterForwardOpaque, commandBuffer);
        commandBuffer.DrawProcedural(transform.localToWorldMatrix, mat, 0, meshTopology, meshBuff.count, numberOfDraw);
    }
    void Update()
    {
        kernel.SetFloat("_Velocity", velocity);
        kernel.SetVector("_Bounds", bounds);
        kernel.Dispatch(kernel.FindKernel("Calculate"), numberOfDraw / 8 + 1, 1, 1);
    }
    struct TransformStruct
    {
        public Vector3 translate;
        public Vector3 rotation;
        public Vector3 scale;
        public Vector3 velocity;
        public int init;
    }
    ComputeBuffer CreateMeshBuffer(Mesh mesh)
    {
        var indices = mesh.GetIndices(0);
        var len = indices.Length;
        var meshStructs = new MeshStructBase[len];
        for (var i = 0; i < indices.Length; i++)
        {
            meshStructs[i] = new MeshStructBase();
            meshStructs[i].position = mesh.vertices[indices[i]];
            meshStructs[i].normal = mesh.normals[indices[i]];
            meshStructs[i].uv = mesh.uv[indices[i]];
        }
        return CreateComputeBuffer(meshStructs);
    }
    struct MeshStructBase
    {
        public Vector3 position;
        public Vector3 normal;
        public Vector2 uv;
    }
    ComputeBuffer CreateComputeBuffer<T>(T[] data, ComputeBufferType type = ComputeBufferType.Default)
    {
        var computeBuffer = new ComputeBuffer(data.Length, Marshal.SizeOf(typeof(T)), type);
        computeBuffer.SetData(data);
        return computeBuffer;
    }
}