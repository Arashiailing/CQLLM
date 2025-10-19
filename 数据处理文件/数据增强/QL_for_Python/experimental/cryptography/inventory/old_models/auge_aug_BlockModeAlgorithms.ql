/**
 * @name Block cipher mode detection
 * @description Detects cryptographic operations that employ block cipher modes
 *              within supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

// Identify cryptographic operations and their associated block cipher modes
from Cryptography::CryptographicOperation cryptoOp, string cipherMode
where 
  // Extract the block cipher mode from the cryptographic operation
  cipherMode = cryptoOp.getBlockMode()
select 
  cryptoOp, 
  "Cryptographic operation uses block cipher mode: " + cipherMode