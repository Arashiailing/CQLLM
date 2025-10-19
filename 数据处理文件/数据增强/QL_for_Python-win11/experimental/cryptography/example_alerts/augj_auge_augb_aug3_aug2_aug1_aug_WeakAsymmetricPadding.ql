/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * This analysis identifies asymmetric cryptographic padding algorithms that are
 * either known to be vulnerable, not recommended for security-critical applications,
 * or have undetermined security properties. The analysis recognizes only OAEP
 * (Optimal Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism),
 * and PSS (Probabilistic Signature Scheme) as secure padding schemes for
 * asymmetric cryptography. Any other padding method may introduce security
 * vulnerabilities and should be replaced with these approved schemes.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding implementations that use non-approved schemes
from AsymmetricPadding vulnerablePadding, string paddingAlgorithm
where 
  // Extract the padding algorithm name from the implementation
  paddingAlgorithm = vulnerablePadding.getPaddingName()
  // Check if the padding algorithm is not one of the approved secure schemes
  and paddingAlgorithm != "OAEP"
  and paddingAlgorithm != "KEM"
  and paddingAlgorithm != "PSS"
select vulnerablePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithm