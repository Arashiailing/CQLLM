/**
 * @name Weak hashes
 * @description Identifies cryptographic hash functions that are either unrecognized or deemed insecure for security-sensitive applications.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import Python language support and cryptographic analysis capabilities
import python
import experimental.cryptography.Concepts

// Query to detect weak hash algorithm usage along with algorithm identification and security warnings
from HashAlgorithm cryptoHashOperation, string hashAlgorithmName, string securityWarning
where
  // Extract the algorithm name from the cryptographic hash operation
  hashAlgorithmName = cryptoHashOperation.getHashName() and
  // Filter out strong, approved hash algorithms from analysis
  not hashAlgorithmName = ["SHA256", "SHA384", "SHA512"] and
  // Generate appropriate security warning based on algorithm recognition status
  (
    // Case for unrecognized algorithm
    hashAlgorithmName = unknownAlgorithm() and
    securityWarning = "Use of unrecognized hash algorithm."
    or
    // Case for recognized but unapproved algorithm
    not hashAlgorithmName = unknownAlgorithm() and
    securityWarning = "Use of unapproved hash algorithm or API " + hashAlgorithmName + "."
  )
select cryptoHashOperation, securityWarning