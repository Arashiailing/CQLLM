/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm usages across supported libraries
 *              by detecting both algorithm names and block cipher modes.
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
  algorithmName = cryptoOperation.getAlgorithm().getName()
  or
  algorithmName = cryptoOperation.getBlockMode()
select cryptoOperation, "Use of algorithm " + algorithmName