/**
 * @name Comprehensive Cryptographic Algorithm Enumeration
 * @description Discovers and documents every cryptographic algorithm implementation
 *              across all supported cryptographic libraries in the codebase
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

// Find all cryptographic algorithm implementations in the codebase
from CryptographicAlgorithm algo
// Report each algorithm with its name
select algo, "Use of algorithm " + algo.getName()