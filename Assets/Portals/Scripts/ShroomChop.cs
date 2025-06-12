using UnityEngine;

public class ShroomChop : MonoBehaviour
{
    [SerializeField] private GameObject choppedObject;
    
    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.name == "Knife")
        {
            SwitchObjects();
        }
    }
    
    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.name == "Knife")
        {
            SwitchObjects();
        }
    }
    
    void SwitchObjects()
    {
        // Turn off this object
        gameObject.SetActive(false);
        
        // Turn on the target object
        if (choppedObject != null)
            choppedObject.SetActive(true);
    }
}
