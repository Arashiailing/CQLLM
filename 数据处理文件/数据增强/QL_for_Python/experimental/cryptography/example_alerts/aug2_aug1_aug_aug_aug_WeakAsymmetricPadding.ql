/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * security standards. This analysis flags potentially vulnerable padding configurations
 * by permitting only the most robust padding methods (OAEP, KEM, PSS) and marking
 * all other schemes as potential security risks.
 * 
 * The query specifically focuses on padding implementations that could be vulnerable
 * to cryptographic attacks when used in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding schemes for asymmetric encryption
// These specific padding techniques are considered secure for asymmetric encryption
from AsymmetricPadding paddingMethod, string paddingName
where
  // Retrieve the padding algorithm identifier from the implementation
  paddingName = paddingMethod.getPaddingName()
  // Exclude implementations that use secure padding methods
  and not paddingName = ["OAEP", "KEM", "PSS"]
select paddingMethod, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingName