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

// Core analysis modules for cryptographic detection
import python
import experimental.cryptography.Concepts

// Identify all cryptographic algorithm instances in the codebase
from CryptographicAlgorithm cryptoAlgo
// Generate alert with algorithm identification details
select cryptoAlgo, "Cryptographic algorithm detected: " + cryptoAlgo.getName()