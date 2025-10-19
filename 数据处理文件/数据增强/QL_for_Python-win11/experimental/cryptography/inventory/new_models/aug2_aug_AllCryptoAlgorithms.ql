/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm implementations across the codebase,
 *              leveraging supported cryptographic libraries for detection.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import foundational Python analysis capabilities
import python
// Import experimental cryptography detection framework
import experimental.cryptography.Concepts

// Identify all cryptographic algorithm implementations
from CryptographicAlgorithm cryptoAlgo
// Generate results with algorithm identification messages
select cryptoAlgo, "Cryptographic algorithm implementation detected: " + cryptoAlgo.getName()