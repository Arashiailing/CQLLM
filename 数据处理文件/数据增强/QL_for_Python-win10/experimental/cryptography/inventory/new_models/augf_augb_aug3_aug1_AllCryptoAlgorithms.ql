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

// Define the main query to identify cryptographic implementations
from CryptographicAlgorithm cryptoImplementation
// Generate a detailed alert message for each detected algorithm
select cryptoImplementation, 
       "Cryptographic algorithm detected: " + cryptoImplementation.getName()