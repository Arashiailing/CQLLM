/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Discovers and reports all cryptographic algorithm implementations
 *              within the analyzed codebase across supported cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import fundamental Python analysis capabilities
import python
// Import experimental cryptography framework for algorithm identification
import experimental.cryptography.Concepts

// Query to locate every cryptographic algorithm implementation present in the code
from CryptographicAlgorithm cryptoAlgo
// Create alert message detailing the specific algorithm being used
select cryptoAlgo, "Detected cryptographic algorithm: " + cryptoAlgo.getName()