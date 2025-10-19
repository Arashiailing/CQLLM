/**
 * @name Detection of vulnerable or unverified asymmetric cryptographic padding schemes
 * @description
 * This security analysis identifies the use of asymmetric cryptographic padding algorithms
 * that are known to be vulnerable, not approved for security-sensitive applications,
 * or lack adequate security verification. For asymmetric cryptographic operations,
 * the only recommended padding methodologies are OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme). Any other
 * padding technique may introduce security vulnerabilities and should be replaced with
 * one of the explicitly recommended approaches.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding algorithms that are not in the approved secure set
from AsymmetricPadding vulnerablePadding, string paddingSchemeName
where 
  // Retrieve the name of the padding algorithm being used
  paddingSchemeName = vulnerablePadding.getPaddingName()
  // Ensure the padding algorithm is not one of the approved secure schemes
  and paddingSchemeName != "OAEP"
  and paddingSchemeName != "KEM"
  and paddingSchemeName != "PSS"
select vulnerablePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingSchemeName