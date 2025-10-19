/**
 * @name Complete Cryptographic Algorithm Inventory
 * @description Identifies and catalogs all potential cryptographic algorithm 
 *              implementations found across supported cryptographic libraries
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

// Query for all cryptographic algorithm instances in the codebase
from CryptographicAlgorithm cipherAlgorithm
// Generate alert message containing the algorithm name
select cipherAlgorithm, "Use of algorithm " + cipherAlgorithm.getName()