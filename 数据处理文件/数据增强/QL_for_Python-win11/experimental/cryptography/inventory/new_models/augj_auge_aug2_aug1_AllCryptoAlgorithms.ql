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

// Identify all cryptographic algorithm implementations within the codebase
from CryptographicAlgorithm cryptoImpl
// Generate results with algorithm instance and descriptive message for each detected implementation
select cryptoImpl, "Cryptographic algorithm detected: " + cryptoImpl.getName()