/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Discovers and reports all cryptographic algorithm implementations
 *              throughout the codebase by analyzing supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis functionalities
import python
// Import experimental cryptography analysis framework
import experimental.cryptography.Concepts

// Query to identify all cryptographic algorithm implementations
from CryptographicAlgorithm cipherAlgorithm
// Generate detailed results with algorithm identification information
select cipherAlgorithm, "Detected cryptographic algorithm implementation: " + cipherAlgorithm.getName()