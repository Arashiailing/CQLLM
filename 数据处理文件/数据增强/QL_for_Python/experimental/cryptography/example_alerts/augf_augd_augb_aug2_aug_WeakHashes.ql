/**
 * @name Insecure cryptographic hash algorithms
 * @description Detects the use of deprecated or cryptographically weak hash functions
 *              in security-sensitive contexts, which may lead to vulnerabilities.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python language support and cryptographic analysis framework
import python
import experimental.cryptography.Concepts

// Identify weak hash algorithm implementations and generate security alerts
from HashAlgorithm hashImpl, string hashAlgo, string alertMsg
where
  // Extract the algorithm name from the hash implementation
  hashAlgo = hashImpl.getHashName() and
  // Filter out cryptographically secure hash algorithms
  not hashAlgo = ["SHA256", "SHA384", "SHA512"] and
  // Determine the appropriate security alert message based on algorithm identification
  (
    // Handle identified but non-compliant algorithms
    hashAlgo != "" and
    alertMsg = "Non-compliant hash algorithm detected: " + hashAlgo + ". This algorithm is not approved for security-sensitive operations."
  )
  or
  (
    // Handle cases where the algorithm cannot be identified
    hashAlgo = "" and
    alertMsg = "Unidentified hash algorithm detected. Unable to verify cryptographic strength of this implementation."
  )
select hashImpl, alertMsg