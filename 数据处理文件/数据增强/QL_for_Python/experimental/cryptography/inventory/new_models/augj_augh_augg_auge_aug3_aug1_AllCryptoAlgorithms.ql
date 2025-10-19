/**
 * @name Complete Cryptographic Implementation Discovery
 * @description Discovers and enumerates all cryptographic algorithm instances
 *              throughout the codebase across supported cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import fundamental Python analysis infrastructure for code inspection
import python
// Import specialized cryptography concepts module for algorithm identification
import experimental.cryptography.Concepts

// Identify cryptographic implementations within the codebase
from CryptographicAlgorithm cryptoImpl
// Generate results with detailed algorithm information
select cryptoImpl, "Use of algorithm " + cryptoImpl.getName()