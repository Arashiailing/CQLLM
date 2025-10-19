/**
 * @name All Cryptographic Algorithms
 * @description Identifies all instances of cryptographic algorithm usage across supported libraries in the codebase.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis module
import python
// Import experimental cryptographic concepts library
import experimental.cryptography.Concepts

// Identify all cryptographic algorithm instances
from CryptographicAlgorithm cryptoAlgo
// Generate alert with algorithm name
select cryptoAlgo, "Use of algorithm " + cryptoAlgo.getName()