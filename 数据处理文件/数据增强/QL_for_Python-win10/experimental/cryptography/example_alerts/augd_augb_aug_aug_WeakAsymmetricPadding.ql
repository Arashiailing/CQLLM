/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding implementations that utilize
 * cryptographic padding schemes which are either inherently insecure
 * or not explicitly validated as secure by established cryptographic
 * standards. This analysis specifically filters out and excludes
 * padding methods that are cryptographically proven to be secure
 * (OAEP, KEM, PSS) and flags all remaining padding implementations
 * as potential security vulnerabilities requiring review.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding implementations and extract their algorithm identifiers
from AsymmetricPadding asymmetricPaddingImpl, string paddingAlgorithm
where
  // Extract the padding algorithm name from the implementation
  paddingAlgorithm = asymmetricPaddingImpl.getPaddingName()
  // Exclude padding algorithms that are cryptographically secure and approved
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select asymmetricPaddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm