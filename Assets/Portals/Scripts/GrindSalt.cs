using UnityEngine;

public class GrindSalt : MonoBehaviour
{
    [SerializeField] private ParticleSystem particles;
    
    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.name == "EggCrack")
        {
            particles.Play();
        }
    }
    
    void OnTriggerExit(Collider other)
    {
        if (other.gameObject.name == "EggCrack")
        {
            particles.Stop();
        }
    }
    
    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.name == "EggCrack")
        {
            particles.Play();
        }
    }
    
    void OnCollisionExit(Collision collision)
    {
        if (collision.gameObject.name == "EggCrack")
        {
            particles.Stop();
        }
    }
}
