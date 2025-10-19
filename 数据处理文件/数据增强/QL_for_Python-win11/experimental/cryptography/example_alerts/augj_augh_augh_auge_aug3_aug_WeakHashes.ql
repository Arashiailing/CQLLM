/**
 * @name Weak cryptographic hash algorithms
 * @description Detects usage of deprecated or insecure cryptographic hash functions
 *              that should not be used in security-sensitive applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import Python language support and cryptographic analysis utilities
import python
import experimental.cryptography.Concepts

// Identify hash functions using weak or deprecated cryptographic algorithms
from HashAlgorithm hashFunc, string algoName, string warningMsg
where
  // Retrieve the algorithm name from the hash function operation
  algoName = hashFunc.getHashName() and
  
  // Exclude approved secure hash algorithms from detection
  not algoName = ["SHA256", "SHA384", "SHA512"] and
  
  // Determine appropriate warning message based on algorithm recognition status
  (
    // Handle identified but unapproved algorithms
    algoName != "" and
    warningMsg = "Use of unapproved hash algorithm or API " + algoName + "."
  )
  or
  (
    // Handle cases where algorithm cannot be identified
    algoName = "" and
    warningMsg = "Use of unrecognized hash algorithm."
  )
select hashFunc, warningMsg