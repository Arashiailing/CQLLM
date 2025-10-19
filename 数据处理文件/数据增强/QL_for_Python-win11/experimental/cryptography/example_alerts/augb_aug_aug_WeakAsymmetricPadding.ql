/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding methods that are either
 * cryptographically insecure or not explicitly recognized as secure
 * by established cryptographic standards. The query specifically
 * excludes secure padding methods (OAEP, KEM, PSS) and highlights
 * all other padding schemes as potential security risks.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Locate asymmetric padding implementations and extract their scheme identifiers
from AsymmetricPadding paddingMethod, string paddingScheme
where
  // Retrieve the padding scheme identifier from the implementation
  paddingScheme = paddingMethod.getPaddingName()
  // Filter out padding schemes that are known to be secure
  and not paddingScheme = ["OAEP", "KEM", "PSS"]
select paddingMethod, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingScheme