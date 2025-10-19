/**
 * @name Block Cipher Mode Detection
 * @description Detects cryptographic operations that employ block cipher modes
 *              within supported cryptographic libraries. This analysis identifies
 *              encryption patterns that may necessitate security evaluation.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

// Identify cryptographic operations and extract their block cipher modes
from Cryptography::CryptographicOperation cryptoOp, string cipherMode
where 
  // Retrieve the block cipher mode from the cryptographic operation
  cipherMode = cryptoOp.getBlockMode()
select 
  cryptoOp, 
  "Cryptographic operation uses block cipher mode: " + cipherMode