/**
 * @name All Cryptographic Algorithms
 * @description Identifies cryptographic algorithm implementations across supported libraries,
 *              capturing both algorithm names and block cipher modes in cryptographic operations.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

from Cryptography::CryptographicOperation cryptographicOperation, string algorithmName
where 
  // Capture algorithm name from cryptographic operation
  algorithmName = cryptographicOperation.getAlgorithm().getName()
  or
  // Capture block cipher mode from cryptographic operation
  algorithmName = cryptographicOperation.getBlockMode()
select cryptographicOperation, "Use of algorithm " + algorithmName