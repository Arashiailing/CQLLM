/**
 * @name Weak hashes
 * @description Identifies the usage of cryptographic hash algorithms that are either unapproved or considered weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// Import necessary Python libraries and experimental cryptography concepts
import python
import experimental.cryptography.Concepts

// Identify weak hash operations and generate corresponding security alerts
from HashAlgorithm hashOp, string algoName, string warningMsg
where
  // Extract the algorithm name from the hash operation
  algoName = hashOp.getHashName() and
  
  // Exclude cryptographically strong hash algorithms from detection
  not algoName = ["SHA256", "SHA384", "SHA512"] and
  
  // Generate appropriate security warning based on algorithm recognition status
  (
    // Case: Recognized but unapproved algorithm
    algoName != "" and
    warningMsg = "Use of unapproved hash algorithm or API " + algoName + "."
  )
  or
  (
    // Case: Unrecognized algorithm
    algoName = "" and
    warningMsg = "Use of unrecognized hash algorithm."
  )
select hashOp, warningMsg