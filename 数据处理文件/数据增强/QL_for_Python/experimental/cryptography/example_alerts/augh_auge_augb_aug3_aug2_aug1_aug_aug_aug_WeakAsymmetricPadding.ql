/**
 * @name Weak or unknown asymmetric padding
 * @description
 * This query identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * security standards. The analysis follows a strict security model that only
 * permits the most robust padding methods (OAEP, KEM, PSS), flagging all other
 * padding configurations as potential security vulnerabilities.
 * 
 * The detection mechanism specifically targets padding implementations that
 * could be susceptible to cryptographic attacks in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of approved secure padding methods for asymmetric encryption
// These padding techniques are considered cryptographically secure according
// to established security standards
from AsymmetricPadding insecurePaddingMethod, string paddingSchemeName
where
  // Extract the padding algorithm identifier from the implementation
  paddingSchemeName = insecurePaddingMethod.getPaddingName()
  // Check if the padding scheme is not in the approved secure list
  and not paddingSchemeName = ["OAEP", "KEM", "PSS"]
select insecurePaddingMethod, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingSchemeName