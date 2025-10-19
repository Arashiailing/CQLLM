/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either cryptographically weak
 * or not explicitly approved by established security standards. The analysis excludes
 * secure padding methods (OAEP, KEM, PSS) and flags all other padding schemes as
 * potential security vulnerabilities requiring remediation.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define variables for asymmetric padding instances and their scheme names
from AsymmetricPadding asymmetricPadding, string paddingName
where
  // Extract padding scheme name from implementation
  paddingName = asymmetricPadding.getPaddingName()
  // Exclude cryptographically secure padding schemes
  and not paddingName = ["OAEP", "KEM", "PSS"]
select asymmetricPadding, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingName