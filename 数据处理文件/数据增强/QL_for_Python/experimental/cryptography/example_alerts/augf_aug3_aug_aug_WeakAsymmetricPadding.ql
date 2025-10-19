/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure.
 * This query filters out approved padding methods (OAEP, KEM, PSS)
 * and flags any other padding schemes as potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding implementations and their algorithm names
from AsymmetricPadding paddingImpl, string algorithmName
where
  // Extract the padding algorithm name from the implementation
  algorithmName = paddingImpl.getPaddingName()
  // Exclude known secure padding algorithms (OAEP, KEM, PSS)
  and not algorithmName = ["OAEP", "KEM", "PSS"]
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + algorithmName