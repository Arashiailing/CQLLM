/**
 * @name Insecure or unrecognized asymmetric encryption padding
 * @description
 * Detects padding schemes for asymmetric encryption that are either
 * cryptographically weak or not explicitly validated as secure
 * according to recognized cryptographic standards. This analysis
 * specifically excludes well-established secure padding methods
 * (OAEP, KEM, PSS) and flags all other padding techniques as
 * potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric encryption padding implementations
from AsymmetricPadding paddingImpl, string schemeIdentifier
where 
  // Extract the padding scheme identifier from the implementation
  schemeIdentifier = paddingImpl.getPaddingName()
  // Define the set of secure padding schemes that should be excluded
  and not schemeIdentifier = ["OAEP", "KEM", "PSS"]
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + schemeIdentifier