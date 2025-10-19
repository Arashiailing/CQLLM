/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either
 * cryptographically insecure or not explicitly endorsed as secure by recognized security standards.
 * This analysis identifies potentially vulnerable padding configurations by
 * only allowing the most robust padding techniques (OAEP, KEM, PSS) and flagging
 * all other methods as potential security concerns.
 * 
 * The query specifically targets padding implementations that may be susceptible
 * to cryptographic attacks when used in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the collection of cryptographically secure padding algorithms
// These padding mechanisms are acknowledged as secure for asymmetric cryptographic operations
from AsymmetricPadding asymmetricPadding, string paddingAlgorithm
where
  // Extract the padding algorithm identifier from the implementation
  paddingAlgorithm = asymmetricPadding.getPaddingName()
  // Filter out implementations that utilize approved secure padding methods
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select asymmetricPadding, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm