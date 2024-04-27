using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PosUp : MonoBehaviour
{
    public float delta_test = 0.0f;
    public GameObject totract;
    public GameObject totract2;

    public ParticleSystem ps1;
    public ParticleSystem ps2;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        GetComponent<Renderer>().material.SetVector("_Position", new Vector4(totract.transform.position.x, totract.transform.position.y, totract.transform.position.z, 1));
        GetComponent<Renderer>().material.SetVector("_Position2", new Vector4(totract2.transform.position.x, totract2.transform.position.y, totract2.transform.position.z, 1));
        //GetComponent<Renderer>().material.SetConstantBuffer("_", , 0, 10);
        //Debug.Log(GetComponent<Renderer>().material.GetVector("_Position"));
        //GetComponent<Renderer>().material.SetVector("_Position", new Vector4(Mathf.Cos(delta_test), 0, Mathf.Sin(delta_test), 1));

    }
}
