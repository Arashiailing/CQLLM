/**
 * @name All Cryptographic Algorithms
 * @description Identifies all potential cryptographic algorithm implementations across supported libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python analysis module
import python
// Import experimental cryptography concepts for algorithm detection
import experimental.cryptography.Concepts

// Retrieve all cryptographic algorithm instances
from CryptographicAlgorithm cryptoAlgorithm
// Generate alert with algorithm name
select cryptoAlgorithm, "Use of algorithm " + cryptoAlgorithm.getName()