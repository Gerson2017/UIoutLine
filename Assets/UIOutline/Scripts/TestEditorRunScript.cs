using System.Collections.Generic;
using GersonFrame;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class ScriptExecutionEditor : Editor
{
    [MenuItem("MyMenu/ExecuteScriptAndMountAnotherScript")]
    public static void ExecuteScriptAndMountAnotherScript()
    {
        // 获取所有预制体的引用
        List<GameObject> prefabs = FindAllPrefabs();

        // 循环遍历所有预制体
        foreach (GameObject prefab in prefabs)
        {
            // 获取挂载在预制体上的目标脚本
            TestScript[] targetScripts = prefab.GetComponentsInChildren<TestScript>();
            
            Material newMaterial = new Material(Shader.Find("Gerson/UIOutline"));
            
            for (int i = 0; i < targetScripts.Length; i++)
            {
                GameObject go = targetScripts[i].gameObject;
                Text text = go.GetComponent<Text>();
                if (text)
                {
                    // 设置新的材质
                    text.material = newMaterial;
                    // 在预制体上保存新的材质
                    if (PrefabUtility.GetPrefabInstanceStatus(go) != PrefabInstanceStatus.NotAPrefab)
                        PrefabUtility.RecordPrefabInstancePropertyModifications(text);
                    Debug.Log(go.name +" Change material ");
                }

                if (!go.GetComponent<UIOutline>())
                    go.AddComponent<UIOutline>();
                DestroyImmediate(targetScripts[i]);
                Debug.Log(targetScripts[i].gameObject.name+" Add OutLineEx");
            }
            // 保存预制体的修改
            PrefabUtility.SavePrefabAsset(prefab);
                
        }
    }
    

    public static List<GameObject> FindAllPrefabs()
    {
        List<GameObject> allprefabs = new List<GameObject>();
        string[] guids = AssetDatabase.FindAssets("t:Prefab");

        Debug.Log("FindAllPrefabs length "+guids.Length);
        
        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            allprefabs.Add(prefab);
        }

        return allprefabs;
    }


   
}