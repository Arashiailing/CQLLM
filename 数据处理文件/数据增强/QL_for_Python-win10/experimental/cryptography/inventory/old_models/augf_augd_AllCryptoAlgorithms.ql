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

// Identify cryptographic operations and extract their algorithm identifiers
from Cryptography::CryptographicOperation cryptoOperation, string algoIdentifier
where
  // Extract algorithm identifier from the cryptographic operation
  algoIdentifier = cryptoOperation.getAlgorithm().getName()
  or
  // Extract block mode identifier from the cryptographic operation
  algoIdentifier = cryptoOperation.getBlockMode()
select cryptoOperation, "Use of algorithm " + algoIdentifier