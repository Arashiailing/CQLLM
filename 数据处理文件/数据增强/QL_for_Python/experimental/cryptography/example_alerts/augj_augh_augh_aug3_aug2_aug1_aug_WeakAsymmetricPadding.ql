/**
 * @name Identification of vulnerable asymmetric cryptographic padding
 * @description
 * This analysis targets asymmetric encryption padding techniques that are known to be insecure,
 * obsolete, or have ambiguous security properties. According to current cryptographic standards,
 * only OAEP (Optimal Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism),
 * and PSS (Probabilistic Signature Scheme) are considered secure padding methods for
 * asymmetric cryptographic operations. Implementation of any alternative padding scheme
 * could potentially lead to security weaknesses and should be substituted with one of the
 * recommended algorithms.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric cryptographic padding schemes that fail to meet security requirements
from AsymmetricPadding vulnerablePaddingScheme, string paddingMethodIdentifier
where 
  // Extract the identifier of the padding algorithm in use
  paddingMethodIdentifier = vulnerablePaddingScheme.getPaddingName()
  // Validate that the padding scheme is not among the approved secure algorithms
  and not paddingMethodIdentifier = "OAEP"
  and not paddingMethodIdentifier = "KEM"
  and not paddingMethodIdentifier = "PSS"
select vulnerablePaddingScheme, "Detected use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingMethodIdentifier