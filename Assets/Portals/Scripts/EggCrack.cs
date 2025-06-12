using UnityEngine;

public class EggCrack : MonoBehaviour
{
    [SerializeField] private Transform topHalf;
    [SerializeField] private Transform bottomHalf;
    
    [SerializeField] private float separationDistance = 0.1f;
    [SerializeField] private GameObject objectToActivate;
    
    private bool isCracked = false;
    
    void OnTriggerEnter(Collider other)
    {
        if (!isCracked && other.gameObject.name == "Pan")
        {
            CrackEgg();
        }
    }
    
    void OnCollisionEnter(Collision collision)
    {
        if (!isCracked && collision.gameObject.name == "Pan")
        {
            CrackEgg();
        }
    }
    
    void CrackEgg()
    {
        isCracked = true;
        
        if (topHalf != null)
            topHalf.position += transform.up * separationDistance;
        
        if (bottomHalf != null)
            bottomHalf.position += -transform.up * separationDistance;
        
        if (objectToActivate != null)
            objectToActivate.SetActive(true);
    }
}
