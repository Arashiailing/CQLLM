/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly approved by established
 * cryptographic standards. This query excludes known secure padding
 * methods (OAEP, KEM, PSS) and flags all other padding implementations
 * as potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding implementations and extract their scheme identifiers
from AsymmetricPadding asymmetricPaddingImpl, string paddingIdentifier
where
  // Extract padding scheme identifier from the implementation
  paddingIdentifier = asymmetricPaddingImpl.getPaddingName()
  // Exclude padding schemes recognized as secure by cryptographic standards
  and not paddingIdentifier = ["OAEP", "KEM", "PSS"]
select asymmetricPaddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingIdentifier