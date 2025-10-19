/**
 * @name Weak or Unknown Asymmetric Padding Detection
 * @description
 * This query detects asymmetric cryptographic padding algorithms that are
 * either recognized as weak, not sanctioned for secure applications, or have
 * undetermined security properties. The only padding schemes deemed secure
 * for asymmetric cryptography are OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme).
 * Any alternative padding approaches could potentially create security risks
 * and ought to be substituted with approved methodologies.
 * @id py/weak-asymmetric-padding
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify vulnerable asymmetric padding implementations
from AsymmetricPadding vulnerablePadding, string paddingAlgorithm
where 
  // Extract the name of the padding algorithm being used
  paddingAlgorithm = vulnerablePadding.getPaddingName()
  // Verify that the padding algorithm is not among the secure schemes
  and paddingAlgorithm != "OAEP"
  and paddingAlgorithm != "KEM"
  and paddingAlgorithm != "PSS"
select vulnerablePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithm