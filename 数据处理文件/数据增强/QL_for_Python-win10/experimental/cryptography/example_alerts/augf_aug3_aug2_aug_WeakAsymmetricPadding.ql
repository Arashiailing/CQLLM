/**
 * @name Detection of insecure asymmetric cryptographic padding schemes
 * @description
 * Identifies implementations of asymmetric cryptographic padding that are considered
 * vulnerable, deprecated, or lacking proper security validation. This query specifically
 * targets padding algorithms that do not conform to established security standards,
 * excluding recommended methods such as OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme). Use of
 * non-standard padding may lead to security vulnerabilities including malleability,
 * chosen ciphertext attacks, or insufficient entropy, potentially compromising the
 * confidentiality and integrity of cryptographic operations.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding schemes that are not among the approved secure methods
from AsymmetricPadding vulnerablePadding, string paddingName
where 
  // Extract the name of the padding algorithm being used
  paddingName = vulnerablePadding.getPaddingName()
  // Exclude known secure padding algorithms from the results
  and not paddingName = ["OAEP", "KEM", "PSS"]
select vulnerablePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingName