/**
 * @name All Cryptographic Algorithms
 * @description Identifies all instances where cryptographic algorithms are utilized across the codebase,
 *              leveraging the supported cryptographic libraries for detection.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import the Python library for code analysis
import python
// Import the experimental cryptography concepts library to identify cryptographic algorithms
import experimental.cryptography.Concepts

// Query to retrieve all cryptographic algorithm instances
from CryptographicAlgorithm cryptoAlgorithm
// Return each algorithm along with a message indicating its usage
select cryptoAlgorithm, "Usage detected for cryptographic algorithm: " + cryptoAlgorithm.getName()