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

// Define secure padding schemes as constant references
// Note: Only OAEP, KEM, and PSS are considered secure
from AsymmetricPadding vulnerablePadding, string paddingScheme
where 
  // Extract the name of the padding algorithm being used
  paddingScheme = vulnerablePadding.getPaddingName()
  // Verify the padding scheme is not among the approved secure methods
  and not paddingScheme.matches("OAEP")
  and not paddingScheme.matches("KEM")
  and not paddingScheme.matches("PSS")
select vulnerablePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingScheme