/**
 * @name Detection of vulnerable or unknown asymmetric padding schemes
 * @description
 * This query identifies cryptographic operations that employ asymmetric padding algorithms
 * which are classified as weak, unapproved, or have uncertain security characteristics.
 * Secure asymmetric padding methods that are approved include OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme).
 * Utilizing alternative padding schemes could potentially lead to security weaknesses in cryptographic systems.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// The following query detects asymmetric padding implementations that use
// algorithms not included in the approved secure set (OAEP, KEM, PSS)

// Identify asymmetric padding instances that utilize insecure or unknown algorithms
from AsymmetricPadding vulnerablePadding, string paddingType
where 
  // Extract the name of the padding algorithm being used
  paddingType = vulnerablePadding.getPaddingName()
  // Determine if the padding algorithm is not in the approved secure set
  and not (paddingType = "OAEP" or paddingType = "KEM" or paddingType = "PSS")
select vulnerablePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingType