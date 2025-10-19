/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import required Python and Semmle core libraries for cryptographic analysis
import python
import semmle.python.Concepts

// Identify cryptographic operations and extract their algorithm identifiers
// This query captures both algorithm names and block modes used in cryptographic operations
from Cryptography::CryptographicOperation cryptoOp, string algorithmIdentifier
where 
  // Extract algorithm name from the cryptographic operation
  algorithmIdentifier = cryptoOp.getAlgorithm().getName()
  or
  // Extract block mode from the cryptographic operation
  algorithmIdentifier = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algorithmIdentifier