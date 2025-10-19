/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * Identifies usage of asymmetric cryptographic padding algorithms that are either weak,
 * not approved for secure use, or have unknown security properties. Secure cryptographic
 * implementations should only use specific padding schemes. The approved secure asymmetric
 * padding schemes include:
 * - OAEP (Optimal Asymmetric Encryption Padding)
 * - KEM (Key Encapsulation Mechanism)
 * - PSS (Probabilistic Signature Scheme)
 * Using other padding schemes may introduce security vulnerabilities. This query flags
 * any asymmetric padding method that is not one of the approved secure schemes.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of approved secure asymmetric padding schemes
string approvedSecurePadding() {
  result = "OAEP" or   // Approved for encryption operations
  result = "KEM" or    // Approved for key encapsulation mechanisms
  result = "PSS"       // Approved for digital signature schemes
}

// Find all asymmetric padding methods that are not using approved secure schemes
from AsymmetricPadding vulnerablePadding, string algorithmName
where 
  // Extract the name of the padding algorithm being used
  algorithmName = vulnerablePadding.getPaddingName()
  // Verify the algorithm is not in the approved secure schemes list
  and algorithmName != approvedSecurePadding()
select vulnerablePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + algorithmName