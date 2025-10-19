/**
 * @name Weak cryptographic hash algorithms
 * @description Detects usage of cryptographic hash functions that are either unapproved 
 *              or considered weak for security purposes.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and cryptography-related concepts
import python
import experimental.cryptography.Concepts

// Identify hash operations using weak or unapproved algorithms
from HashAlgorithm hashOp, string hashAlgorithm, string warningMsg
where
  // Extract the algorithm name from the hash operation
  hashAlgorithm = hashOp.getHashName() and
  // Filter out approved strong hash algorithms
  not hashAlgorithm = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate warning message based on algorithm recognition
  (
    // Handle recognized but unapproved algorithms
    hashAlgorithm != "" and
    warningMsg = "Use of unapproved hash algorithm or API " + hashAlgorithm + "."
  )
  or
  (
    // Handle unrecognized algorithms
    hashAlgorithm = "" and
    warningMsg = "Use of unrecognized hash algorithm."
  )
select hashOp, warningMsg