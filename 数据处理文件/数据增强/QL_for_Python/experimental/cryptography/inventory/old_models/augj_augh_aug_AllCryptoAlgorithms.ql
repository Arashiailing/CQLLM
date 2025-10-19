/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python and Semmle core libraries
import python
import semmle.python.Concepts

// Identify cryptographic operations and extract algorithm identifiers
from Cryptography::CryptographicOperation cryptographicOperation, string algorithmName
where 
  // Extract algorithm name directly from operation
  algorithmName = cryptographicOperation.getAlgorithm().getName()
  or
  // Extract block mode identifier from operation
  algorithmName = cryptographicOperation.getBlockMode()
select cryptographicOperation, "Use of algorithm " + algorithmName