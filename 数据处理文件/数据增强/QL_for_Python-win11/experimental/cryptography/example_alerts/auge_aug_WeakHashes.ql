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

// Identify weak hash operations and generate corresponding alert messages
from HashAlgorithm hashOp, string algoName, string alertMsg
where
  // Extract the hash algorithm name from the operation
  algoName = hashOp.getHashName() and
  // Exclude strong, approved hash algorithms (SHA256, SHA384, SHA512)
  not algoName = ["SHA256", "SHA384", "SHA512"] and
  // Generate alert message based on algorithm recognition status
  (
    // Case 1: Recognized but unapproved algorithm
    algoName != "" and
    alertMsg = "Use of unapproved hash algorithm or API " + algoName + "."
  )
  or
  (
    // Case 2: Unrecognized algorithm
    algoName = "" and
    alertMsg = "Use of unrecognized hash algorithm."
  )
select hashOp, alertMsg