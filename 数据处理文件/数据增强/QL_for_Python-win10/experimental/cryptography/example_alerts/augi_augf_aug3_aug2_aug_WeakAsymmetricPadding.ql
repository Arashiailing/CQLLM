/**
 * @name Detection of insecure asymmetric cryptographic padding schemes
 * @description
 * This analysis identifies asymmetric cryptographic padding implementations that are
 * considered insecure, outdated, or without proper security validation. The query
 * specifically focuses on padding algorithms that deviate from established security
 * standards, with the exception of recommended approaches like OAEP (Optimal Asymmetric
 * Encryption Padding), KEM (Key Encapsulation Mechanism), and PSS (Probabilistic
 * Signature Scheme). Implementations using non-standard padding may introduce security
 * flaws such as malleability, chosen ciphertext attacks, or inadequate entropy,
 * potentially undermining the confidentiality and integrity of cryptographic operations.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding schemes that are not among the approved secure methods
from AsymmetricPadding weakPadding, string paddingScheme
where 
  // Extract the name of the padding algorithm being used
  paddingScheme = weakPadding.getPaddingName()
  // Filter out known secure padding algorithms
  and not paddingScheme = ["OAEP", "KEM", "PSS"]
select weakPadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingScheme