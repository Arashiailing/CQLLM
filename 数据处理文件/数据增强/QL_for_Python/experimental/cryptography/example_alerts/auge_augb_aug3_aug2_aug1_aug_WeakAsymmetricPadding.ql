/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric cryptographic padding algorithms that are either
 * known to be weak, not approved for secure use, or have unknown security
 * characteristics. Only OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme)
 * are considered secure for asymmetric cryptography. All other padding methods
 * may introduce security vulnerabilities and should be replaced with approved schemes.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define approved secure padding schemes
string getSecurePaddingScheme() {
  result = "OAEP" or
  result = "KEM" or
  result = "PSS"
}

// Identify unapproved asymmetric padding implementations
from AsymmetricPadding insecurePadding, string paddingName
where 
  // Extract padding algorithm name
  paddingName = insecurePadding.getPaddingName()
  // Exclude approved secure padding schemes
  and paddingName != getSecurePaddingScheme()
select insecurePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingName