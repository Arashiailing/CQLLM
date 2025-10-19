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

// Locate cryptographic operations and extract their block cipher mode information
from Cryptography::CryptographicOperation encryptionOp, string cipherMode
where 
  // Obtain the block cipher mode name for each identified cryptographic operation
  cipherMode = encryptionOp.getBlockMode()
select 
  encryptionOp, 
  "Cryptographic operation uses block cipher mode: " + cipherMode