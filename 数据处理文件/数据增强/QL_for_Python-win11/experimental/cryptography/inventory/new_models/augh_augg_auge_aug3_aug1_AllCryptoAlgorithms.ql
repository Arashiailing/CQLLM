/**
 * @name Comprehensive Cryptographic Algorithm Enumeration
 * @description Systematically identifies and catalogs all cryptographic algorithm implementations
 *              across supported cryptographic libraries in the analyzed codebase
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis framework for code examination
import python
// Import experimental cryptography module for algorithm detection
import experimental.cryptography.Concepts

// Define algorithm detection scope
from CryptographicAlgorithm algorithm
// Generate alert with algorithm identification details
select algorithm, "Use of algorithm " + algorithm.getName()