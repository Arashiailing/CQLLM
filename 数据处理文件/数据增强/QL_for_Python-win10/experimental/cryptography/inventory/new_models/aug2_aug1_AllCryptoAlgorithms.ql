/**
 * @name All Cryptographic Algorithms
 * @description Identifies all potential cryptographic algorithm implementations across supported libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis module
import python
// Import experimental cryptography concepts for algorithm detection
import experimental.cryptography.Concepts

// Identify all cryptographic algorithm instances
from CryptographicAlgorithm algoInstance
// Generate alert with algorithm name
select algoInstance, "Use of algorithm " + algoInstance.getName()