/**
 * @name All Cryptographic Algorithms
 * @description Discovers every cryptographic algorithm used throughout the codebase,
 *              utilizing the supported cryptographic libraries for comprehensive detection.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis functionalities
import python
// Import experimental cryptography detection utilities
import experimental.cryptography.Concepts

// Locate all cryptographic algorithm implementations present in the code
from CryptographicAlgorithm cipherAlgorithm
// Produce output results with detailed algorithm identification information
select cipherAlgorithm, "Cryptographic algorithm implementation detected: " + cipherAlgorithm.getName()