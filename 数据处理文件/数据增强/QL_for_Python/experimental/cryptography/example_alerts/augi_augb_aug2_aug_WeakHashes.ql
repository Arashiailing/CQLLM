/**
 * @name Weak cryptographic hash algorithms
 * @description Identifies usage of cryptographic hash functions that are either unapproved 
 *              or deemed insufficient for security-critical applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python libraries and experimental cryptography modules
import python
import experimental.cryptography.Concepts

// Detect weak hash operations and generate corresponding security warnings
from HashAlgorithm hashOperation, string algorithmName, string securityAlert
where
  // Retrieve the name of the hash algorithm being utilized
  algorithmName = hashOperation.getHashName() and
  // Exclude strong, cryptographically secure hash algorithms from detection
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Construct appropriate security alert based on algorithm identification status
  (
    // Case: Algorithm is identified but not in the approved list
    algorithmName != "" and
    securityAlert = "Use of unapproved hash algorithm or API " + algorithmName + "."
  )
  or
  (
    // Case: Algorithm cannot be identified or recognized
    algorithmName = "" and
    securityAlert = "Use of unrecognized hash algorithm."
  )
select hashOperation, securityAlert