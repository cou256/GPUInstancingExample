using System.Linq;
using System.Collections.Generic;
using UnityEngine;

public class PseudoInstancing : MonoBehaviour
{
    [SerializeField] int numberOfDraw;
    [SerializeField] float velocity;
    [SerializeField] Vector3 bounds;
    [SerializeField] Mesh mesh;
    [SerializeField] Shader kernel;
    [SerializeField] Shader shader;

    Material kernelMat;
    Material shaderMat;
    List<Mesh> combineMeshs = new List<Mesh>();
    BufferTexture translateBuff, rotationBuff, scaleBuff, velocityBuff, initBuff;

    void OnDisable()
    {
        translateBuff.Destroy();
        rotationBuff.Destroy();
        scaleBuff.Destroy();
        velocityBuff.Destroy();
        initBuff.Destroy();

        Destroy(kernelMat);
        Destroy(shaderMat);
    }
    void OnEnable()
    {
        kernelMat = CreateMaterial(kernel);
        shaderMat = CreateMaterial(shader);

        var height = numberOfDraw / 4096 + 1;
        var width = 4096;
        if (height == 1)
        {
            width = numberOfDraw % 4096;
        }
        translateBuff = new BufferTexture(width, height, kernelMat);
        rotationBuff = new BufferTexture(width, height, kernelMat);
        scaleBuff = new BufferTexture(width, height, kernelMat);
        velocityBuff = new BufferTexture(width, height, kernelMat);
        initBuff = new BufferTexture(width, height, kernelMat);

        shaderMat.SetVector("_Offset", translateBuff.Texture.texelSize);

        shaderMat.SetTexture("_TranslateBuff", translateBuff.Texture);
        shaderMat.SetTexture("_RotationBuff", rotationBuff.Texture);
        shaderMat.SetTexture("_ScaleBuff", scaleBuff.Texture);

        kernelMat.SetTexture("_TranslateBuff", translateBuff.Texture);
        kernelMat.SetTexture("_RotationBuff", rotationBuff.Texture);
        kernelMat.SetTexture("_ScaleBuff", scaleBuff.Texture);
        kernelMat.SetTexture("_VelocityBuff", velocityBuff.Texture);
        kernelMat.SetTexture("_InitBuff", initBuff.Texture);

        kernelMat.SetFloat("_DeltaTime", Time.deltaTime);
        kernelMat.SetVector("_Bounds", bounds);
        kernelMat.SetVector("_Offset", translateBuff.Texture.texelSize);

        initBuff.Blit(0);
        translateBuff.Blit(1);
        rotationBuff.Blit(2);
        scaleBuff.Blit(3);
        velocityBuff.Blit(4);
        initBuff.Blit(5);
    }
    void Start ()
    {
        var maxDrawCont = 65536 / mesh.vertexCount;
        var lim0 = numberOfDraw / maxDrawCont;
        var lim1 = numberOfDraw % maxDrawCont;
        for (var i = 0; i < lim0; i++)
        {
            combineMeshs.Add(CreateCombineMesh(maxDrawCont, maxDrawCont * i));
        }
        combineMeshs.Add(CreateCombineMesh(lim1, maxDrawCont * lim0));
    }

    void Update ()
    {
        kernelMat.SetFloat("_DeltaTime", Time.deltaTime);
        kernelMat.SetFloat("_Velocity", velocity);
        kernelMat.SetVector("_Bounds", bounds);

        translateBuff.Blit(1);
        rotationBuff.Blit(2);
        scaleBuff.Blit(3);
        velocityBuff.Blit(4);
        initBuff.Blit(5);

        for (var i = 0; i < combineMeshs.Count; i++)
        {
            Graphics.DrawMesh(combineMeshs[i], transform.localToWorldMatrix, shaderMat, gameObject.layer);
        }
    }

    Mesh CreateCombineMesh(int count, int idOffset)
    {
        var vertexCount = mesh.vertexCount;
        var indices = mesh.GetIndices(0);
        var uvs = mesh.uv.ToList();

        var indicesList = new List<int>();
        var verticesList = new List<Vector3>();
        var normalsList = new List<Vector3>();
        var tangentsList = new List<Vector4>();
        var uvList = new List<Vector2>();
        var idList = new List<Vector2>();

        for (var i = 0; i < count; i++)
        {
            var indexOffset = vertexCount * i;
            for (var j = 0; j < indices.Length; j++)
            {
                indicesList.Add(indices[j] + indexOffset);
            }
            verticesList.AddRange(mesh.vertices);
            normalsList.AddRange(mesh.normals);
            tangentsList.AddRange(mesh.tangents);
            uvList.AddRange(mesh.uv);

            var id = i + idOffset;
            var uv2 = new Vector2(id % 4096, id / 4096);
            for (var j = 0; j < vertexCount; j++)
            {
                idList.Add(uv2);
            }
        }
        var meshBuff = new Mesh();
        meshBuff.hideFlags = HideFlags.DontSave;
        meshBuff.SetVertices(verticesList);
        meshBuff.SetIndices(indicesList.ToArray(), mesh.GetTopology(0), 0);
        meshBuff.SetNormals(normalsList);
        meshBuff.SetTangents(tangentsList);
        meshBuff.SetUVs(0, uvList);
        meshBuff.SetUVs(1, idList);
        return meshBuff;
    }
    Material CreateMaterial(Shader shader)
    {
        var mat = new Material(shader);
        mat.hideFlags = HideFlags.DontSave;
        return mat;
    }
    class BufferTexture
    {
        public RenderTexture Texture { get; private set; }
        RenderTexture temp;
        Material mat;
        public BufferTexture(int width, int height, Material mat)
        {
            Texture = CreateRenderTexture(width, height);
            temp = CreateRenderTexture(width, height);
            this.mat = mat;
        }
        public void Blit(int pass)
        {
            Graphics.Blit(null, temp, mat, pass);
            Graphics.Blit(temp, Texture);
        }
        public void Destroy()
        {
            Clean(temp);
            Clean(Texture);
        }
        void Clean(RenderTexture renderTexture)
        {
            renderTexture.Release();
            GameObject.Destroy(renderTexture);
        }
        RenderTexture CreateRenderTexture(int width, int heght)
        {
            var renderTexture = new RenderTexture(width, heght, 0, RenderTextureFormat.ARGBFloat);
            renderTexture.hideFlags = HideFlags.DontSave;
            renderTexture.filterMode = FilterMode.Point;
            renderTexture.wrapMode = TextureWrapMode.Repeat;
            return renderTexture;
        }
    }
}
