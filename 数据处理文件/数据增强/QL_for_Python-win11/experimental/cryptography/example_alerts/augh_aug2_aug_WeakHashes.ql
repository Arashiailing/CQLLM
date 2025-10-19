/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies cryptographic hash functions that are either unapproved or deemed 
 *              insufficiently secure for cryptographic applications.
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
from HashAlgorithm hashOperation, string hashName, string alertMessage
where
  // Extract the name of the hash algorithm being used
  hashName = hashOperation.getHashName() and
  // Filter out strong, approved hash algorithms
  not hashName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security alert message based on algorithm recognition
  (
    // Case: recognized but unapproved algorithms
    hashName != "" and
    alertMessage = "Use of unapproved hash algorithm or API " + hashName + "."
  )
  or
  (
    // Case: unrecognized algorithms
    hashName = "" and
    alertMessage = "Use of unrecognized hash algorithm."
  )
select hashOperation, alertMessage