/**
 * @name Weak cryptographic hash algorithms
 * @description Detects usage of cryptographic hash functions that are deprecated 
 *              or considered insecure for security-sensitive contexts.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import Python language support and cryptographic analysis utilities
import python
import experimental.cryptography.Concepts

// Identify hash operations using weak or deprecated cryptographic algorithms
from HashAlgorithm cryptoHashOp, string hashAlgoName, string warningMsg
where
  // Retrieve the algorithm name from the cryptographic hash operation
  hashAlgoName = cryptoHashOp.getHashName() and
  
  // Exclude approved strong hash algorithms from detection
  not hashAlgoName = ["SHA256", "SHA384", "SHA512"] and
  
  // Generate appropriate warning message based on algorithm status
  (
    // Handle recognized but unapproved algorithms
    hashAlgoName != "" and
    warningMsg = "Use of unapproved hash algorithm or API " + hashAlgoName + "."
  )
  or
  (
    // Handle unrecognized algorithm cases
    hashAlgoName = "" and
    warningMsg = "Use of unrecognized hash algorithm."
  )
select cryptoHashOp, warningMsg