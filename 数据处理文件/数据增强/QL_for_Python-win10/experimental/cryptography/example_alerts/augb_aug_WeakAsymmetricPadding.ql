/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * Identifies usage of asymmetric cryptographic padding algorithms that are either weak,
 * not approved for secure use, or have unknown security properties. Approved secure
 * asymmetric padding schemes include OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme).
 * The use of other padding schemes may introduce security vulnerabilities in cryptographic
 * implementations. This query helps detect such potentially insecure padding choices.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding methods that are not in the list of secure schemes
from AsymmetricPadding paddingMethod, string schemeName
where 
  // Extract the name of the current padding algorithm
  schemeName = paddingMethod.getPaddingName()
  // Check if the padding algorithm is not among the approved secure schemes
  and not schemeName = "OAEP"
  and not schemeName = "KEM"
  and not schemeName = "PSS"
select paddingMethod, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + schemeName