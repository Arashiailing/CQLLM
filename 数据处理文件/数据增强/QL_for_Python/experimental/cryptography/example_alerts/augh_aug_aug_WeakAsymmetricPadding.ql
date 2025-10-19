/**
 * @name Weak or unknown asymmetric padding
 * @description
 * This security analysis identifies asymmetric encryption padding schemes that are
 * considered cryptographically weak or not explicitly approved by established
 * security standards. The query specifically filters out secure padding methods
 * such as OAEP, KEM, and PSS, marking all other padding schemes as potential
 * security vulnerabilities that require attention.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define source variables for asymmetric padding methods and their scheme names
from AsymmetricPadding paddingMethod, string paddingScheme
where
  // Retrieve the name of the padding scheme from the implementation
  paddingScheme = paddingMethod.getPaddingName()
  // Filter out known secure padding schemes to focus on potentially vulnerable ones
  and not paddingScheme = ["OAEP", "KEM", "PSS"]
select paddingMethod, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingScheme