using System;
using UnityEngine;
using UnityEngine.Serialization;

namespace Graphics
{
    [SelectionBase]
    [DisallowMultipleComponent]
    public sealed class Grid : MonoBehaviour
    {
        [SerializeField] private Material gridMaterial;

        private Camera cam;
        private static readonly int CenterID = Shader.PropertyToID("_Center");
        private static readonly int SizeID = Shader.PropertyToID("_Size");

        private void Awake()
        {
            cam = Camera.main;
        }

        private void LateUpdate()
        {
            var planeBounds = GetPlaneBounds();
            gridMaterial.SetVector(CenterID, planeBounds.center);
            gridMaterial.SetVector(SizeID, planeBounds.size);

            var vertices = Mathf.CeilToInt(planeBounds.size.x) * 2 + Mathf.CeilToInt(planeBounds.size.z) * 2;
            
            UnityEngine.Graphics.DrawProcedural(gridMaterial, planeBounds, MeshTopology.Lines, vertices);
        }

        private Bounds GetPlaneBounds()
        {
            var screenCorners = new Vector2[]
            {
                new(0.0f, 0.0f),
                new(0.0f, 1.0f),
                new(1.0f, 0.0f),
                new(1.0f, 1.0f),
            };
            
            var worldCorners = new Vector2[4];
            var plane = new Plane(Vector3.up, 0.0f);
            
            for (var i = 0; i < 4; i++)
            {
                var ray = cam.ViewportPointToRay(screenCorners[i]);
                if (plane.Raycast(ray, out var enter)) return new Bounds();

                worldCorners[i] = ray.GetPoint(enter);
            }

            var bounds = new Bounds(worldCorners[0], Vector3.zero);
            for (var i = 0; i < 4; i++)
            {
                bounds.Encapsulate(worldCorners[i]);
            }

            return bounds;
        }
    }
}
