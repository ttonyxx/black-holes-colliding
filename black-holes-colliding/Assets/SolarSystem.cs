using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SolarSystem : MonoBehaviour
{

    float G = 10f;

    GameObject[] celestials;

    // Start is called before the first frame update
    void Start()
    {
        celestials = GameObject.FindGameObjectsWithTag("Celestial");

        // Initialize velocity
        // foreach (GameObject a in celestials) {
        //     a.GetComponent<Rigidbody>().velocity = new Vector3(1f, 0f, 0f);
    //}
    celestials[0].GetComponent<Rigidbody>().velocity = new Vector3(1f, 0f, 0f);
        celestials[1].GetComponent<Rigidbody>().velocity = new Vector3(-1f, 0f, 0f);
    }

    private void FixedUpdate() {
        Gravity();
    }

    // Update is called once per frame
    void Gravity()
    {
        foreach (GameObject a in celestials) {
            foreach (GameObject b in celestials) {
                if (!a.Equals(b)) {
                    float m1 = a.GetComponent<Rigidbody>().mass;
                    float m2 = b.GetComponent<Rigidbody>().mass;
                    float r = Vector3.Distance(a.transform.position, b.transform.position);

                    a.GetComponent<Rigidbody>().AddForce((b.transform.position - a.transform.position).normalized * G * (m1 * m2) / (r * r));
                    
                }
            }//
            a.GetComponent<Rigidbody>().velocity *= 0.999f;
        }
        //G += 0.01f;
    }
}
