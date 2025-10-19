/**
 * @name Vulnerable Cryptographic Hash Functions
 * @description Detects the utilization of cryptographic hash functions that are either
 *              disallowed due to security concerns or deemed weak and susceptible to attacks.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 *       security
 *       cryptography
 */

// Import necessary Python language modules and cryptographic functionality definitions
import python
import experimental.cryptography.Concepts

// Identify weak hash function usages, their algorithm names, and corresponding security alerts
from HashAlgorithm hashFuncUsage, string hashAlgorithm, string alertMessage
where
  // Retrieve the name of the hash algorithm being utilized
  hashAlgorithm = hashFuncUsage.getHashName() and
  // Exclude approved strong hash algorithms (SHA256, SHA384, SHA512)
  not hashAlgorithm = ["SHA256", "SHA384", "SHA512"] and
  // Determine appropriate security alert based on algorithm recognition status
  (
    // Case for unrecognized algorithms
    hashAlgorithm = unknownAlgorithm() and
    alertMessage = "Use of unrecognized hash algorithm."
    or
    // Case for recognized but unapproved algorithms
    not hashAlgorithm = unknownAlgorithm() and
    alertMessage = "Use of unapproved hash algorithm or API " + hashAlgorithm + "."
  )
select hashFuncUsage, alertMessage