/**
 * @name Weak cryptographic hash algorithms
 * @description Detects the use of cryptographic hash functions that are either not approved 
 *              or considered weak for security purposes.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python libraries and experimental cryptography concepts
import python
import experimental.cryptography.Concepts

// Identify weak hash operations and generate appropriate security alerts
from HashAlgorithm cryptoHashOperation, string hashAlgorithmName, string securityAlertMessage
where
  // Extract the name of the hash algorithm being used
  hashAlgorithmName = cryptoHashOperation.getHashName() and
  // Filter out strong, approved hash algorithms
  not hashAlgorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Determine the appropriate security alert message based on algorithm recognition
  (
    // Handle recognized but unapproved algorithms
    hashAlgorithmName != "" and
    securityAlertMessage = "Use of unapproved hash algorithm or API " + hashAlgorithmName + "."
  )
  or
  (
    // Handle unrecognized algorithms
    hashAlgorithmName = "" and
    securityAlertMessage = "Use of unrecognized hash algorithm."
  )
select cryptoHashOperation, securityAlertMessage