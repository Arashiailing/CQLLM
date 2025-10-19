/**
 * @name Comprehensive Cryptographic Algorithm Enumeration
 * @description Discovers and documents all cryptographic algorithm implementations
 *              present within the analyzed cryptographic libraries
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

// Define the main query to identify cryptographic implementations
from CryptographicAlgorithm cryptoImpl
// Extract algorithm name for reporting purposes
where exists(cryptoImpl.getName())
// Generate alert with algorithm identification
select cryptoImpl, "Implementation detected: " + cryptoImpl.getName()