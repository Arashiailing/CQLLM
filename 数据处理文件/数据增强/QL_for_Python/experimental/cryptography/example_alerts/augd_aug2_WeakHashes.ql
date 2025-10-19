/**
 * @name Weak cryptographic hash functions
 * @description Identifies usage of cryptographic hash algorithms that are considered unapproved or weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required modules for Python code analysis and cryptographic security concepts
import python
import experimental.cryptography.Concepts

// Security analysis query to detect implementations of weak cryptographic hash algorithms
from HashAlgorithm hashImpl, string hashIdentifier, string alertMessage
where
  // Extract the algorithm identifier from the hash implementation
  hashIdentifier = hashImpl.getHashName() and
  // Exclude approved strong hash algorithms (SHA256, SHA384, SHA512) from detection
  not hashIdentifier = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security alert based on algorithm recognition status
  (if hashIdentifier = unknownAlgorithm()
   then alertMessage = "Use of unrecognized hash algorithm."
   else alertMessage = "Use of unapproved hash algorithm or API: " + hashIdentifier + ".")
select hashImpl, alertMessage