/**
 * @name Weak cryptographic hash functions
 * @description Detects implementations of cryptographic hash algorithms that are considered weak or unapproved for security-sensitive applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary modules for Python code and cryptographic analysis
import python
import experimental.cryptography.Concepts

// Query to detect weak hash algorithm implementations in code
from HashAlgorithm hashImplementation, string algorithmName, string alertMessage
where
  // Extract the algorithm name from the hash implementation
  algorithmName = hashImplementation.getHashName()
  
  // Check if the algorithm is not in the approved list
  and not algorithmName = ["SHA256", "SHA384", "SHA512"]
  
  // Generate appropriate alert message based on algorithm recognition
  and (if algorithmName = unknownAlgorithm()
       then alertMessage = "Use of unrecognized hash algorithm."
       else alertMessage = "Use of unapproved hash algorithm or API: " + algorithmName + ".")
select hashImplementation, alertMessage