/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm implementations across supported libraries.
 *              This query detects both algorithm names and block modes used in cryptographic operations.
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
from Cryptography::CryptographicOperation cryptographicOperation, string algorithmIdentifier
where 
  // Extract algorithm name from cryptographic operation
  (algorithmIdentifier = cryptographicOperation.getAlgorithm().getName())
  or
  // Extract block mode from cryptographic operation
  (algorithmIdentifier = cryptographicOperation.getBlockMode())
select cryptographicOperation, "Use of algorithm " + algorithmIdentifier