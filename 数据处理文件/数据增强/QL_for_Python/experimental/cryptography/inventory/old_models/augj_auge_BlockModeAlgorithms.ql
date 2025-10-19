/**
 * @name Block cipher mode detection
 * @description Identifies cryptographic operations using block cipher modes across supported libraries.
 *              This query detects all potential block cipher modes of operations implemented
 *              through supported cryptographic libraries in Python codebases.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language modules and Semmle's cryptographic concepts
import python
import semmle.python.Concepts

// Identify cryptographic operations and extract their block cipher modes
from Cryptography::CryptographicOperation cryptoOperation, string blockModeName
where 
  // Extract block mode name from the cryptographic operation
  blockModeName = cryptoOperation.getBlockMode()
select 
  cryptoOperation, 
  "Detected algorithm using mode: " + blockModeName