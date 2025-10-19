/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Discovers and reports all cryptographic algorithm implementations 
 *              across supported libraries to establish a complete cryptographic inventory
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis capabilities
import python
// Import experimental cryptography detection framework
import experimental.cryptography.Concepts

// Find all cryptographic algorithm implementations in the codebase
from CryptographicAlgorithm cryptographicImpl
// Report each identified algorithm with its name
select cryptographicImpl, "Use of algorithm " + cryptographicImpl.getName()