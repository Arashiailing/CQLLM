/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * This query identifies asymmetric cryptographic padding algorithms that are either
 * known to be weak, not approved for secure use, or have unknown security
 * characteristics. The only padding schemes considered secure for asymmetric
 * cryptography are OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme).
 * Any other padding method may introduce security vulnerabilities and should be
 * replaced with one of these approved schemes.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding implementations that use unapproved schemes
from AsymmetricPadding insecurePadding, string paddingName
where 
  // Extract the name of the padding algorithm being used
  paddingName = insecurePadding.getPaddingName()
  // Exclude the approved secure padding schemes
  and paddingName != "OAEP"
  and paddingName != "KEM"
  and paddingName != "PSS"
select insecurePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingName