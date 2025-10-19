/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly approved by security standards.
 * This query excludes secure padding methods (OAEP, KEM, PSS) and flags
 * all other padding schemes as potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding implementations and their scheme names
from AsymmetricPadding paddingImpl, string schemeName
where
  // Extract padding scheme name from implementation
  schemeName = paddingImpl.getPaddingName()
  // Exclude known secure padding schemes
  and not schemeName = ["OAEP", "KEM", "PSS"]
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + schemeName