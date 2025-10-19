/**
 * @name Comprehensive Cryptographic Algorithm Enumeration
 * @description Identifies and catalogs all cryptographic algorithm implementations 
 *              across supported cryptographic libraries in the codebase
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python analysis framework
import python

// Import experimental cryptography analysis components
import experimental.cryptography.Concepts

// Identify cryptographic algorithm implementations
from CryptographicAlgorithm cryptoAlgo
// Generate report with algorithm identification
select cryptoAlgo, "Detected algorithm usage: " + cryptoAlgo.getName()