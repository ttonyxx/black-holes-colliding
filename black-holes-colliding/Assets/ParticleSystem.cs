using UnityEngine;

public class OrbitAroundSphere : MonoBehaviour
{
    public Transform centerPoint; // The center point of the sphere
    public Transform centerPoint2; // The center point of the other sphere

    public float orbitSpeed = 5f; // Speed of rotation
    public float gravityStrength = 100f; // Strength of gravity
    public int initialParticleCount = 100; // Number of particles to start with

    public float orbitRadius = 1f;

    private ParticleSystem particleSystem;


    void Start()
    {
        particleSystem = GetComponent<ParticleSystem>();

        // Set particle system to start with a specific number of particles
        var emission = particleSystem.emission;
        emission.enabled = true; // Enable emission
        emission.rateOverTime = 0; // Disable continuous emission
        particleSystem.Emit(initialParticleCount);

        // Set initial position of particles to be near the center point
        // var particles = new ParticleSystem.Particle[particleSystem.main.maxParticles];
        // int particleCount = particleSystem.GetParticles(particles);
        // for (int i = 0; i < particleCount; i++)
        // {
        //     float angle = i * Mathf.PI * 2 / particleCount;
        //     Vector3 position = centerPoint.position + new Vector3(Mathf.Cos(angle), 0f, Mathf.Sin(angle)) * 1.0f;
        //     particles[i].position = position;
        // }
        // particleSystem.SetParticles(particles, particleCount);

        var particles = new ParticleSystem.Particle[particleSystem.main.maxParticles];
        int particleCount = particleSystem.GetParticles(particles);
        for (int i = 0; i < particleCount; i++)
        {
            float angle = i * Mathf.PI * 2 / particleCount;
            Vector3 position = centerPoint.position + new Vector3(Mathf.Cos(angle), 0f, Mathf.Sin(angle)) * orbitRadius;
            particles[i].position = position;

            // Add random noise to the initial particle positions
            float noiseRange = 0.3f; // Adjust the range of noise as needed
            Vector3 noiseOffset = new Vector3(Random.Range(-noiseRange, noiseRange), Random.Range(-noiseRange, noiseRange), Random.Range(-noiseRange, noiseRange));
            particles[i].position += noiseOffset;

            // Calculate the initial velocity of the particles
            Vector3 up = new Vector3(0f, 1f, 0f); // or any other up vector
            Vector3 tangentialVelocity = Vector3.Cross(new Vector3(Mathf.Cos(angle), 0f, Mathf.Sin(angle)), up).normalized;
            Vector3 velocity = tangentialVelocity * 3f;
            particles[i].velocity = velocity;
        }
        particleSystem.SetParticles(particles, particleCount);

    }


    void Update()
    {
        // Get particles
        ParticleSystem.Particle[] particles = new ParticleSystem.Particle[particleSystem.main.maxParticles];
        int particleCount = particleSystem.GetParticles(particles);

        for (int i = 0; i < particles.Length; i++)
        {
            // Calculate gravitational force from the first center point
            Vector3 toCenter1 = (centerPoint.position - particles[i].position).normalized;
            Vector3 gravitationalForce1 = toCenter1 * gravityStrength;

            // Calculate gravitational force from the second center point
            Vector3 toCenter2 = (centerPoint2.position - particles[i].position);
            float distanceToCenter2 = toCenter2.magnitude;
            Vector3 toCenter2Normalized = toCenter2.normalized;

            Vector3 gravitationalForce2 = toCenter2Normalized * gravityStrength / (distanceToCenter2 * distanceToCenter2) * 0.01f;

            // Calculate total gravitational force
            Vector3 totalGravitationalForce = gravitationalForce1;

            // Apply gravitational force to the particle's velocity
            particles[i].velocity += totalGravitationalForce * Time.deltaTime;

            // Apply orbiting force to the particle's velocity
            particles[i].velocity = Quaternion.Euler(0f, orbitSpeed * Time.deltaTime, 0f) * particles[i].velocity;
        }

        // Set particles back
        particleSystem.SetParticles(particles, particleCount);
    }
}
