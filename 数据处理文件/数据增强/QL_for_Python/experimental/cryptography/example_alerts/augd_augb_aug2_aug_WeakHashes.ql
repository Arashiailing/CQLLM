/**
 * @name Insecure cryptographic hash algorithms
 * @description Identifies cryptographic hash functions that are either deprecated 
 *              or deemed cryptographically weak for security-sensitive applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python modules and experimental cryptographic framework
import python
import experimental.cryptography.Concepts

// Locate vulnerable hash implementations and produce corresponding security warnings
from HashAlgorithm hashOperation, string algorithmName, string securityAlert
where
  // Retrieve the identifier of the hash algorithm in use
  algorithmName = hashOperation.getHashName() and
  // Exclude cryptographically strong, approved hash functions
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security warning based on algorithm identification status
  (
    // Case 1: Algorithm is identified but not approved
    algorithmName != "" and
    securityAlert = "Detected usage of non-compliant hash algorithm or API: " + algorithmName + "."
  )
  or
  (
    // Case 2: Algorithm cannot be identified
    algorithmName = "" and
    securityAlert = "Detected usage of unidentified hash algorithm."
  )
select hashOperation, securityAlert