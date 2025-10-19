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

// Find asymmetric padding schemes with insecure configurations
from AsymmetricPadding paddingScheme, string paddingName
where 
  // Retrieve the algorithm name for the current padding scheme
  paddingName = paddingScheme.getPaddingName()
  // Exclude secure padding algorithms from detection
  and (
    paddingName != "OAEP" and
    paddingName != "KEM" and
    paddingName != "PSS"
  )
select paddingScheme, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingName