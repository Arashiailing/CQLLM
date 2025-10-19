/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding mechanisms that are either
 * cryptographically vulnerable or not explicitly recognized as secure by established
 * security standards. This analysis flags potentially risky padding configurations
 * by exclusively allowing robust padding methods (OAEP, KEM, PSS) and marking
 * all other schemes as security concerns.
 * 
 * The query specifically targets padding implementations susceptible to
 * cryptographic attacks in asymmetric encryption scenarios.
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
from AsymmetricPadding vulnerablePadding, string paddingAlgorithm
where
  // Extract the padding algorithm identifier from implementation
  paddingAlgorithm = vulnerablePadding.getPaddingName()
  // Exclude implementations using secure padding methods
  and not paddingAlgorithm in ["OAEP", "KEM", "PSS"]
select vulnerablePadding, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingAlgorithm