/**
 * @name Weak or Unknown Asymmetric Padding Detection
 * @description
 * Detects the use of asymmetric padding algorithms that are classified as weak,
 * unapproved, or with unknown security implications. This security rule identifies
 * padding schemes that deviate from the recommended secure standards (OAEP, KEM, PSS).
 * Employing insecure padding mechanisms may introduce cryptographic vulnerabilities
 * and compromise system security.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define secure padding algorithms as a set
string securePadding() {
  result in ["OAEP", "KEM", "PSS"]
}

// Identify asymmetric padding schemes that are not in the secure list
from AsymmetricPadding vulnerablePadding, string algorithmName
where 
  // Extract the name of the current padding algorithm
  algorithmName = vulnerablePadding.getPaddingName()
  // Verify the algorithm is not among the approved secure padding methods
  and algorithmName != securePadding()
select vulnerablePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + algorithmName