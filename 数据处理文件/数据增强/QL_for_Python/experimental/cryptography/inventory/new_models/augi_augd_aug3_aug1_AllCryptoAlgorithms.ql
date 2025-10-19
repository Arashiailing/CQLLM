/**
 * @name Comprehensive Cryptographic Algorithm Enumeration
 * @description Identifies and catalogs all cryptographic algorithm implementations
 *              found within analyzed cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python analysis framework for code inspection
import python
// Import experimental cryptography module for algorithm detection
import experimental.cryptography.Concepts

// Define primary query to discover cryptographic implementations
from CryptographicAlgorithm algoInstance
// Validate algorithm name existence for reporting
where exists(algoInstance.getName())
// Generate alert with algorithm identification details
select algoInstance, "Implementation detected: " + algoInstance.getName()