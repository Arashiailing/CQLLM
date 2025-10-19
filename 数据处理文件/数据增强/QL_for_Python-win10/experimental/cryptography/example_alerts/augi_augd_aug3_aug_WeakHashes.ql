/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies the use of cryptographic hash functions that are either 
 *              unapproved or considered weak for security-critical applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python language constructs and cryptographic analysis modules
import python
import experimental.cryptography.Concepts

// Find cryptographic hash operations that use weak or unapproved algorithms
from HashAlgorithm hashFunc, string hashAlgorithm, string warningMsg
where
  // Extract the name of the hash algorithm being used
  hashAlgorithm = hashFunc.getHashName() and
  // Filter out strong, approved hash algorithms
  not hashAlgorithm = ["SHA256", "SHA384", "SHA512"] and
  // Determine the appropriate warning message based on algorithm recognition
  (
    // Scenario 1: Algorithm is recognized but not approved
    hashAlgorithm != "" and
    warningMsg = "Use of unapproved hash algorithm or API " + hashAlgorithm + "."
  )
  or
  (
    // Scenario 2: Algorithm is not recognized
    hashAlgorithm = "" and
    warningMsg = "Use of unrecognized hash algorithm."
  )
select hashFunc, warningMsg