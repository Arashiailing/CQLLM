/**
 * @name Block cipher mode of operation detection
 * @description This query identifies cryptographic operations that utilize block cipher modes
 *              within supported cryptographic libraries, helping to assess quantum readiness
 *              by detecting classic encryption models that may be vulnerable to quantum attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

// Identify cryptographic operations and extract their block cipher mode configuration
from Cryptography::CryptographicOperation cipherOperation, string blockCipherMode
where 
  // Extract the block cipher mode name for each detected cryptographic operation
  blockCipherMode = cipherOperation.getBlockMode()
  // Ensure we only report operations with a defined block cipher mode
  and blockCipherMode != ""
select 
  cipherOperation, 
  "Cryptographic operation uses block cipher mode: " + blockCipherMode