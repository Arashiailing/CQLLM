/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects usage of weak, unapproved, or unknown asymmetric padding schemes.
 * Secure padding schemes include OAEP, KEM, and PSS. Other schemes may introduce
 * security vulnerabilities and should be avoided.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding implementations
from AsymmetricPadding paddingScheme, string paddingName
where
  // Extract padding scheme name and verify against approved list
  paddingName = paddingScheme.getPaddingName() and
  // Exclude known secure padding schemes
  not paddingName = ["OAEP", "KEM", "PSS"]
select 
  paddingScheme, 
  "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingName