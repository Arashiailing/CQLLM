/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Systematically identifies all cryptographic algorithm implementations 
 *              across supported Python libraries to establish a complete cryptographic inventory.
 *              This analysis serves as a foundation for cryptographic agility and 
 *              quantum readiness assessments.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis capabilities for code examination
import python
// Import experimental cryptography framework providing algorithm classification concepts
import experimental.cryptography.Concepts

// Define the source of cryptographic algorithm implementations to be analyzed
from CryptographicAlgorithm cryptographicImplementation
// Construct the result output by combining the algorithm instance with descriptive message
select cryptographicImplementation, "Cryptographic algorithm detected: " + cryptographicImplementation.getName()