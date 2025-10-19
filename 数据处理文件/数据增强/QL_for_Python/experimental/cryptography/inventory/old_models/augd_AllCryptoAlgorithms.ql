/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm usage patterns across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import required Python and Semmle libraries
import python
import semmle.python.Concepts

// Identify cryptographic operations and their associated algorithm identifiers
from Cryptography::CryptographicOperation cryptoOp, string algorithmName
where
  // Extract algorithm name from cryptographic operation
  algorithmName = cryptoOp.getAlgorithm().getName()
  or
  // Extract block mode identifier from cryptographic operation
  algorithmName = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algorithmName