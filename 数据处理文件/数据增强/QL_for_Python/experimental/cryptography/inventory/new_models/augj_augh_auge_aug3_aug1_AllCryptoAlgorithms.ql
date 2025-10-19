/**
 * @name Comprehensive Cryptographic Algorithm Enumeration
 * @description Identifies and catalogs all cryptographic algorithm implementations
 *              present in the codebase across various cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python analysis module
import python

// Import experimental cryptography concepts
import experimental.cryptography.Concepts

// Query to identify all cryptographic algorithm implementations
from CryptographicAlgorithm cryptoAlgorithm
// Generate report for each identified algorithm
select cryptoAlgorithm, "Use of algorithm " + cryptoAlgorithm.getName()