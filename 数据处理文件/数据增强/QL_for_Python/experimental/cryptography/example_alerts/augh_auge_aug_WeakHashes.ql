/**
 * @name Weak cryptographic hash algorithms
 * @description Detects the use of cryptographic hash functions that are either unapproved 
 *              or considered cryptographically weak for security-sensitive applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and experimental cryptography analysis components
import python
import experimental.cryptography.Concepts

// Identify weak hash operations and generate corresponding security alerts
from HashAlgorithm cryptoHashOperation, string hashAlgorithmName, string securityAlertMessage
where
  // Extract the name of the hash algorithm being used
  hashAlgorithmName = cryptoHashOperation.getHashName() and
  // Define and exclude cryptographically strong hash algorithms
  not hashAlgorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate alert message based on algorithm recognition
  (
    // Scenario 1: Algorithm is recognized but not approved
    hashAlgorithmName != "" and
    securityAlertMessage = "Detected use of unapproved hash algorithm or API: " + hashAlgorithmName + "."
  )
  or
  (
    // Scenario 2: Algorithm is not recognized by the analysis
    hashAlgorithmName = "" and
    securityAlertMessage = "Detected use of unrecognized hash algorithm that may be insecure."
  )
select cryptoHashOperation, securityAlertMessage