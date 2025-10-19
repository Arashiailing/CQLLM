/**
 * @name Detection of weak or unknown asymmetric padding
 * @description Identifies asymmetric cryptographic padding algorithms that are either
 * known to be vulnerable, not sanctioned for secure applications, or have undetermined
 * security characteristics. Only OAEP (Optimal Asymmetric Encryption Padding), 
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme) are 
 * recognized as secure. Any other padding methods could potentially introduce 
 * security vulnerabilities and should be substituted with approved schemes.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Locate implementations of insecure asymmetric padding
from AsymmetricPadding insecurePaddingImpl, string paddingSchemeName
where 
  // Extract the name of the padding algorithm being used
  paddingSchemeName = insecurePaddingImpl.getPaddingName()
  // Exclude OAEP (Optimal Asymmetric Encryption Padding) as it is secure
  and paddingSchemeName != "OAEP"
  // Exclude KEM (Key Encapsulation Mechanism) as it is secure
  and paddingSchemeName != "KEM"
  // Exclude PSS (Probabilistic Signature Scheme) as it is secure
  and paddingSchemeName != "PSS"
select insecurePaddingImpl, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingSchemeName