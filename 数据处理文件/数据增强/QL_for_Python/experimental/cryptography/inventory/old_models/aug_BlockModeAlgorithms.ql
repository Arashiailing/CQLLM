/**
 * @name Block cipher mode of operation
 * @description Identifies cryptographic operations utilizing block cipher modes
 *              in supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

// Identify cryptographic operations and their associated block cipher modes
from Cryptography::CryptographicOperation cryptoOp, string modeName
where 
  // Retrieve the block cipher mode from the cryptographic operation
  modeName = cryptoOp.getBlockMode()
select 
  cryptoOp, 
  "Cryptographic operation uses block cipher mode: " + modeName