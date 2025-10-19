/**
 * @name Weak hashes
 * @description Identifies usage of cryptographic hash algorithms that are either unapproved or considered weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import Python language support and cryptographic concepts
import python
import experimental.cryptography.Concepts

// Identify cryptographic hash operations, algorithm names, and corresponding security warnings
from HashAlgorithm cryptoHashOperation, string hashAlgorithmName, string securityWarning
where
  // Extract the hash algorithm name from the operation
  hashAlgorithmName = cryptoHashOperation.getHashName() and
  // Filter out approved strong hash algorithms
  not hashAlgorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security warning based on algorithm recognition
  (
    if hashAlgorithmName = unknownAlgorithm()
    then securityWarning = "Use of unrecognized hash algorithm."
    else securityWarning = "Use of unapproved hash algorithm or API " + hashAlgorithmName + "."
  )
select cryptoHashOperation, securityWarning