/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * This query detects the use of asymmetric cryptographic padding algorithms that are
 * either known to be weak, not approved for secure use, or have unknown security
 * characteristics. The only padding schemes considered secure for asymmetric
 * cryptography are OAEP (Optimal Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism),
 * and PSS (Probabilistic Signature Scheme). Any other padding method could potentially
 * lead to security vulnerabilities and should be replaced with one of the approved schemes.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify instances of asymmetric padding algorithms that are not considered secure
from AsymmetricPadding weakPaddingScheme, string schemeName
where 
  // Extract the name of the padding algorithm being used
  schemeName = weakPaddingScheme.getPaddingName()
  // Verify that the padding algorithm is not among the approved secure schemes
  and not (
    schemeName = "OAEP" or
    schemeName = "KEM" or
    schemeName = "PSS"
  )
select weakPaddingScheme, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + schemeName