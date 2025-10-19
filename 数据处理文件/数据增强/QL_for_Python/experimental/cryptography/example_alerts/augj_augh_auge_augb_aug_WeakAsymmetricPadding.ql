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

// Specifies the set of cryptographically secure asymmetric padding schemes
// that are approved for use in secure implementations
string approvedSecurePadding() {
  result = "OAEP" or   // Approved for encryption operations
  result = "KEM" or    // Approved for key encapsulation mechanisms
  result = "PSS"       // Approved for digital signature schemes
}

// Identifies asymmetric cryptographic padding implementations that utilize
// padding algorithms outside the approved secure schemes list
from AsymmetricPadding insecurePadding, string paddingScheme
where 
  // Extract the name of the padding algorithm being used
  paddingScheme = insecurePadding.getPaddingName()
  // Verify the algorithm is not in the approved secure schemes list
  and paddingScheme != approvedSecurePadding()
select insecurePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingScheme