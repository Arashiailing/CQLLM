/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * security standards. This analysis flags potentially vulnerable padding configurations
 * by exclusively allowing the most robust padding methods (OAEP, KEM, PSS) and marking
 * all other schemes as potential security risks.
 * 
 * The query specifically targets padding implementations that could be susceptible
 * to cryptographic attacks when used in asymmetric encryption scenarios.
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
from AsymmetricPadding insecurePadding, string paddingMethod
where
  // Extract the padding algorithm identifier from the implementation
  paddingMethod = insecurePadding.getPaddingName()
  // Exclude implementations using secure padding methods
  and not paddingMethod = ["OAEP", "KEM", "PSS"]
select insecurePadding, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingMethod