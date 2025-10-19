/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding implementations that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * security standards. This analysis flags potentially vulnerable padding configurations
 * by exclusively allowing the most robust padding methods (OAEP, KEM, PSS) and marking
 * all other schemes as potential security risks.
 * 
 * The query specifically targets padding mechanisms that could be vulnerable
 * to cryptographic attacks when used in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define cryptographically secure padding schemes for asymmetric encryption
// Only these specific padding techniques are considered secure
from AsymmetricPadding paddingImpl, string paddingName
where
  // Extract the padding algorithm identifier from the implementation
  paddingName = paddingImpl.getPaddingName()
  // Exclude implementations using approved secure padding methods
  and not paddingName = ["OAEP", "KEM", "PSS"]
select paddingImpl, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingName