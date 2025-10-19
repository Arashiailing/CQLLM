/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies the use of cryptographic hash algorithms that are either 
 *              deprecated or considered insecure for security-sensitive applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python libraries and cryptographic analysis components
import python
import experimental.cryptography.Concepts

// Find hash operations that utilize weak or deprecated algorithms
from HashAlgorithm hashOperation, string algorithmName, string alertMessage
where
  // Step 1: Extract the algorithm name from the hash operation
  algorithmName = hashOperation.getHashName() and
  
  // Step 2: Filter out approved strong hash algorithms
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  
  // Step 3: Generate appropriate warning message based on algorithm recognition
  (
    // Case for known but unapproved algorithms
    algorithmName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Case for unrecognized algorithms
    algorithmName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage