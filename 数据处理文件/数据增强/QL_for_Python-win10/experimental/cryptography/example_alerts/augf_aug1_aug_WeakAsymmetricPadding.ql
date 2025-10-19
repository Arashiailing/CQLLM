/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * This query identifies the usage of asymmetric padding algorithms that are
 * considered weak, unapproved, or have unknown security properties. Approved
 * secure asymmetric padding schemes include OAEP, KEM, and PSS. All other
 * padding schemes may introduce security vulnerabilities and should be avoided
 * in cryptographic implementations.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Find all instances of asymmetric padding algorithms
from AsymmetricPadding insecurePadding, string paddingScheme
where 
  // Extract the name of the current padding algorithm
  paddingScheme = insecurePadding.getPaddingName()
  // Check if the padding algorithm is not approved (not OAEP, KEM, or PSS)
  and not (
    paddingScheme = "OAEP" or
    paddingScheme = "KEM" or
    paddingScheme = "PSS"
  )
select insecurePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingScheme