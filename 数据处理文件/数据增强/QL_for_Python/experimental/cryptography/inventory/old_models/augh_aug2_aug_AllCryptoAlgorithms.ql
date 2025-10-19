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

// Detect cryptographic operations and extract algorithm identifiers
from Cryptography::CryptographicOperation cryptoOperation, string algorithmName
where 
  // Extract primary algorithm name from cryptographic operation
  algorithmName = cryptoOperation.getAlgorithm().getName()
  or
  // Extract block mode identifier when available
  algorithmName = cryptoOperation.getBlockMode()
select cryptoOperation, "Use of algorithm " + algorithmName