/**
 * @name Detection of weak or unidentified asymmetric padding
 * @description
 * Identifies cryptographic implementations that use asymmetric padding schemes which are
 * considered weak, unapproved, or unrecognized. This query flags any padding mechanisms
 * that are not among the secure options like OAEP, KEM, and PSS, which are known to provide
 * adequate security. Using insecure padding can lead to cryptographic vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Query for asymmetric padding schemes that are not secure
from AsymmetricPadding insecurePaddingScheme, string schemeName
where
  // Extract the name of the padding scheme being used
  schemeName = insecurePaddingScheme.getPaddingName() and
  
  // Verify that the scheme is not in the list of approved secure padding schemes
  not schemeName in ["OAEP", "KEM", "PSS"]
select insecurePaddingScheme, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + schemeName