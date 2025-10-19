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

// Define query to detect cryptographic algorithm instances
from CryptographicAlgorithm cryptoAlgo
// Generate alert with algorithm identification details
select cryptoAlgo, "Use of algorithm " + cryptoAlgo.getName()