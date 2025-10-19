/**
 * @name Weak cryptographic hash algorithms
 * @description Detects usage of cryptographic hash functions deemed unsuitable for
 *              security-sensitive contexts. This rule identifies hash algorithms
 *              that fall outside the approved set of strong cryptographic functions
 *              (specifically SHA256, SHA384, SHA512) or cannot be recognized.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import required Python language constructs and cryptographic analysis components
import python
import experimental.cryptography.Concepts

// Locate cryptographic hash operations utilizing weak or non-approved algorithms
from HashAlgorithm cryptoHash, string algoIdentifier, string securityAlert
where
  // Retrieve the name of the hashing algorithm being used
  algoIdentifier = cryptoHash.getHashName() and
  // Filter out approved strong hash algorithms from our detection
  not algoIdentifier = ["SHA256", "SHA384", "SHA512"] and
  // Determine appropriate security warning based on algorithm status
  (
    // Scenario: Algorithm is identified but not in the approved list
    algoIdentifier != "" and
    securityAlert = "Use of unapproved hash algorithm or API " + algoIdentifier + "."
    or
    // Scenario: Algorithm cannot be recognized or identified
    algoIdentifier = "" and
    securityAlert = "Use of unrecognized hash algorithm."
  )
select cryptoHash, securityAlert