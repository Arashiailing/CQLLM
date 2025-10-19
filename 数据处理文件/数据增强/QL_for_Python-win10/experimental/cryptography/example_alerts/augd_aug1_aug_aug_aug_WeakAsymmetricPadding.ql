/**
 * @name Weak or unknown asymmetric padding
 * @description
 * This query identifies asymmetric encryption padding mechanisms that are either
 * cryptographically insecure or not explicitly recognized as secure by security standards.
 * By allowing only the most robust padding methods (OAEP, KEM, PSS) and flagging
 * all other schemes, this analysis helps detect potentially vulnerable padding configurations.
 * 
 * The focus is on padding implementations that might be susceptible
 * to cryptographic attacks in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define secure padding schemes for asymmetric encryption
// Only these specific padding techniques are considered secure
from AsymmetricPadding paddingAlgorithm, string paddingType
where
  // Extract the padding algorithm identifier from the implementation
  paddingType = paddingAlgorithm.getPaddingName()
  // Filter out implementations using secure padding methods
  and not paddingType = ["OAEP", "KEM", "PSS"]
select paddingAlgorithm, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingType