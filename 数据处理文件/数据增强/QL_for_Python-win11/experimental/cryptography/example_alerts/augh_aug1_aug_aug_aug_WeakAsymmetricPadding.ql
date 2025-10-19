/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding mechanisms that are either
 * cryptographically weak or not explicitly verified as secure by established security standards.
 * This analysis flags potentially vulnerable padding configurations by
 * exclusively permitting the most secure padding methods (OAEP, KEM, PSS) and marking
 * all alternative schemes as potential security risks.
 * 
 * The query specifically examines padding implementations that could be vulnerable
 * to cryptographic attacks when deployed in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding schemes
// These padding techniques are recognized as secure for asymmetric encryption operations
from AsymmetricPadding paddingMethod, string paddingName
where
  // Retrieve the padding algorithm identifier from the implementation
  paddingName = paddingMethod.getPaddingName()
  // Exclude implementations that use approved secure padding methods
  and not paddingName = ["OAEP", "KEM", "PSS"]
select paddingMethod, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingName