/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are considered
 * cryptographically insecure or lack explicit approval from established
 * security standards. The query specifically filters out recognized
 * secure padding methods (OAEP, KEM, PSS) and treats all other
 * padding schemes as potential security risks.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding implementations and their scheme names
from AsymmetricPadding paddingMethod, string paddingScheme
where
  // Extract padding scheme name from implementation
  paddingScheme = paddingMethod.getPaddingName()
  // Exclude known secure padding schemes (OAEP, KEM, PSS)
  and not paddingScheme = ["OAEP", "KEM", "PSS"]
select paddingMethod, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingScheme