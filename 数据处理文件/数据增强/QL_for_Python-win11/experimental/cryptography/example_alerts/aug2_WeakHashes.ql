/**
 * @name Weak cryptographic hash functions
 * @description Identifies usage of cryptographic hash algorithms that are considered unapproved or weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python and cryptographic analysis modules
import python
import experimental.cryptography.Concepts

// Query for identifying weak hash algorithm implementations
from HashAlgorithm hashAlgo, string hashName, string warningMsg
where
  // Extract the algorithm name from the hash operation
  hashName = hashAlgo.getHashName() and
  // Exclude approved strong hash algorithms (SHA256, SHA384, SHA512)
  not hashName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate warning message based on algorithm recognition status
  (if hashName = unknownAlgorithm()
   then warningMsg = "Use of unrecognized hash algorithm."
   else warningMsg = "Use of unapproved hash algorithm or API: " + hashName + ".")
select hashAlgo, warningMsg