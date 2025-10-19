/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Identifies all cryptographic algorithm implementations across 
 *              supported libraries, including both algorithm names and 
 *              block cipher operation modes.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

from Cryptography::CryptographicOperation cryptoOp, string algoName
where 
  // Extract either the algorithm name or block cipher mode from the crypto operation
  algoName = cryptoOp.getAlgorithm().getName() 
  or 
  algoName = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algoName