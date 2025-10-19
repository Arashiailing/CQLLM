/**
 * @name All Cryptographic Algorithms
 * @description This query detects every cryptographic algorithm implementation found in the supported libraries.
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

// Identify cryptographic algorithm implementations and extract their names
from CryptographicAlgorithm cryptoAlgo, string algoName
where algoName = cryptoAlgo.getName()
// Generate alert with algorithm identification
select cryptoAlgo, "Use of algorithm " + algoName