/**
 * @name Block cipher mode of operation
 * @description Identifies cryptographic operations utilizing block cipher modes
 *              in supported cryptographic libraries. This analysis helps detect
 *              specific encryption patterns that may require security review.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

// Identify cryptographic operations and extract their block cipher modes
from Cryptography::CryptographicOperation cryptOperation, string blockCipherMode
where 
  // Retrieve the block cipher mode from the cryptographic operation
  blockCipherMode = cryptOperation.getBlockMode()
select 
  cryptOperation, 
  "Cryptographic operation uses block cipher mode: " + blockCipherMode