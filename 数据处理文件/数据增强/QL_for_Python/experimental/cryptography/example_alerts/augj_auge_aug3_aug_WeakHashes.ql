/**
 * @name Weak cryptographic hash algorithms
 * @description Detects usage of deprecated or insecure cryptographic hash functions
 *              that should not be used in security-sensitive contexts.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python libraries and cryptographic analysis modules
import python
import experimental.cryptography.Concepts

// Identify hash functions using weak or deprecated algorithms
from HashAlgorithm hashFunc, string algoName, string warningMsg
where
  // Extract algorithm name from the hash function
  algoName = hashFunc.getHashName() and
  
  // Define approved strong hash algorithms
  not algoName = ["SHA256", "SHA384", "SHA512"] and
  
  // Generate warning message based on algorithm recognition
  (
    // Case 1: Known but unapproved algorithm
    algoName != "" and
    warningMsg = "Use of unapproved hash algorithm or API " + algoName + "."
  )
  or
  (
    // Case 2: Unrecognized algorithm
    algoName = "" and
    warningMsg = "Use of unrecognized hash algorithm."
  )
select hashFunc, warningMsg