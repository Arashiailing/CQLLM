/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * Identifies usage of asymmetric padding algorithms that are considered weak,
 * unapproved, or have unknown security properties. This rule helps prevent potential
 * vulnerabilities by flagging padding schemes that are not among the secure ones
 * such as OAEP, KEM, and PSS. Using insecure padding schemes can lead to
 * cryptographic weaknesses and potential security breaches.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding schemes that are not in the secure list
from AsymmetricPadding asymmetricPadding, string paddingAlgorithmName
where 
  // Extract the name of the current padding algorithm
  paddingAlgorithmName = asymmetricPadding.getPaddingName()
  // Check if the padding algorithm is not one of the secure ones
  and (
    paddingAlgorithmName != "OAEP" and
    paddingAlgorithmName != "KEM" and
    paddingAlgorithmName != "PSS"
  )
select asymmetricPadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName