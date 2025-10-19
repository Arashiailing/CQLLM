/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm implementations and block modes across supported libraries.
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
from Cryptography::CryptographicOperation cryptoOp, string algorithmIdentifier
where 
  // Case 1: Extract algorithm name from cryptographic operation
  algorithmIdentifier = cryptoOp.getAlgorithm().getName()
  or
  // Case 2: Extract block mode from cryptographic operation
  algorithmIdentifier = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algorithmIdentifier