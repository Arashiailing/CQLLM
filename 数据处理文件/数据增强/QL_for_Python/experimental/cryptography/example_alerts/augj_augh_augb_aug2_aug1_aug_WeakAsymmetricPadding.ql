/**
 * @name Detection of insecure asymmetric cryptographic padding schemes
 * @description
 * Identifies usage of asymmetric cryptographic padding algorithms that are either
 * known to be vulnerable, not approved for security-critical operations, or lack
 * proper security validation. The only padding schemes considered secure for
 * asymmetric cryptographic operations are OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme).
 * Any alternative padding implementation may introduce security vulnerabilities
 * and should be replaced with one of the explicitly recommended schemes.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify insecure asymmetric padding implementations
// Only OAEP, KEM, and PSS are approved secure padding schemes
from AsymmetricPadding insecurePadding, string paddingName
where 
  // Extract the actual padding algorithm name
  paddingName = insecurePadding.getPaddingName()
  // Verify the padding scheme is not in the approved secure list
  and not paddingName.matches("OAEP")
  and not paddingName.matches("KEM")
  and not paddingName.matches("PSS")
select insecurePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingName