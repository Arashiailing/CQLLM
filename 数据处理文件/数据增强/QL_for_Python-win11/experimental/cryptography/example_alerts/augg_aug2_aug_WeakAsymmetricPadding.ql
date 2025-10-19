/**
 * @name Detection of vulnerable asymmetric cryptographic padding schemes
 * @description
 * This analysis identifies asymmetric cryptographic padding methods that are considered weak,
 * not approved for security-critical applications, or have unknown security properties.
 * The recommended secure asymmetric padding techniques include OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme).
 * Using alternative padding methods may introduce security vulnerabilities in cryptographic implementations.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Query for asymmetric padding schemes that fall outside the approved secure methods
from AsymmetricPadding insecurePadding, string paddingName
where 
  // Extract the name of the padding algorithm being used
  paddingName = insecurePadding.getPaddingName()
  // Check if the padding method is not among the approved secure schemes
  and not paddingName = ["OAEP", "KEM", "PSS"]
select insecurePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingName