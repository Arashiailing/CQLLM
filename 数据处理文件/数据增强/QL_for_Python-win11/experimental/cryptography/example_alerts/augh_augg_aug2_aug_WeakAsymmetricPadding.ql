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

// This query identifies asymmetric cryptographic padding methods that are considered weak
// or not approved for security-critical applications. The analysis focuses on detecting
// padding schemes that are not among the recommended secure techniques.
from AsymmetricPadding vulnerablePadding, string paddingAlgorithmName
where 
  // Extract the name of the padding algorithm being used in the cryptographic operation
  paddingAlgorithmName = vulnerablePadding.getPaddingName()
  // Verify that the padding method is not one of the approved secure schemes
  and not paddingAlgorithmName = ["OAEP", "KEM", "PSS"]
select vulnerablePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName