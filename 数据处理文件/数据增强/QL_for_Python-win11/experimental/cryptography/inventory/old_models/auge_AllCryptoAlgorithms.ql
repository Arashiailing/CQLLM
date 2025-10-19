/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm usage patterns in supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language support and Semmle security concepts
import python
import semmle.python.Concepts

// Identify cryptographic operations and their associated algorithm identifiers
from Cryptography::CryptographicOperation cryptoOp, string algorithmName
where 
  // Match either the core algorithm name or block cipher mode
  algorithmName = cryptoOp.getAlgorithm().getName()
  or
  algorithmName = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algorithmName