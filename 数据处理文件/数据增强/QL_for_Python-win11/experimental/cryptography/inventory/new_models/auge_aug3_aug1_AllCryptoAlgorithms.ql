/**
 * @name Comprehensive Cryptographic Algorithm Enumeration
 * @description Discovers and documents every cryptographic algorithm implementation
 *              across all supported cryptographic libraries in the codebase
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python analysis module for code examination
import python
// Import experimental cryptography concepts for algorithm identification
import experimental.cryptography.Concepts

// Identify all cryptographic algorithm implementations throughout the codebase
from CryptographicAlgorithm cryptoAlgorithm
// Generate alert with algorithm identification details
select cryptoAlgorithm, "Use of algorithm " + cryptoAlgorithm.getName()