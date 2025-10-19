/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects padding mechanisms in asymmetric encryption that are either
 * cryptographically insecure or not explicitly recognized as secure by
 * established cryptographic standards. This query identifies potentially
 * vulnerable padding configurations by allowing only the most robust
 * padding methods (OAEP, KEM, PSS) and flagging all others as security risks.
 * 
 * The analysis specifically targets padding implementations that may be
 * susceptible to cryptographic attacks when utilized in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding schemes for asymmetric encryption
// These padding methods are proven to be resistant against known cryptographic vulnerabilities
from AsymmetricPadding asymmetricPaddingScheme, string paddingAlgorithm
where
  // Extract the padding algorithm identifier from the implementation
  paddingAlgorithm = asymmetricPaddingScheme.getPaddingName()
  // Filter out implementations that utilize approved secure padding methods
  and not paddingAlgorithm in ["OAEP", "KEM", "PSS"]
select asymmetricPaddingScheme, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm