/**
 * @name Complete Cryptographic Algorithm Inventory
 * @description Comprehensive detection and cataloging of all cryptographic algorithm 
 *              implementations across supported cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import essential modules for Python code analysis and cryptographic concepts detection
import python
import experimental.cryptography.Concepts

// Main query logic: Discover all cryptographic algorithm implementations throughout the codebase
// This query identifies every instance where a cryptographic algorithm is being used
from CryptographicAlgorithm cryptoAlgorithmInstance

// Generate detailed alert for each detected cryptographic algorithm
// The output includes the algorithm instance and a descriptive message with its name
select cryptoAlgorithmInstance, "Cryptographic algorithm detected: " + cryptoAlgorithmInstance.getName()