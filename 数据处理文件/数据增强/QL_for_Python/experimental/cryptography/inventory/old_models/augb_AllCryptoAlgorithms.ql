/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm usages across supported libraries,
 *              including both algorithm names and block cipher modes.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

from Cryptography::CryptographicOperation cryptoOperation, string algorithmName
where
  // Extract algorithm name from cryptographic operation
  algorithmName = cryptoOperation.getAlgorithm().getName()
  or
  // Extract block cipher mode from cryptographic operation
  algorithmName = cryptoOperation.getBlockMode()
select cryptoOperation, "Use of algorithm " + algorithmName