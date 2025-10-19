/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding mechanisms that are either
 * cryptographically insecure or not explicitly recognized as safe by security standards.
 * This analysis identifies potentially vulnerable padding configurations by
 * allowing only the most robust padding methods (OAEP, KEM, PSS) and flagging
 * all other schemes as potential security vulnerabilities.
 * 
 * The query specifically targets padding implementations that might be susceptible
 * to cryptographic attacks when utilized in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the collection of cryptographically approved padding schemes
// These specific padding techniques are considered secure for asymmetric encryption
from AsymmetricPadding paddingImpl, string paddingScheme
where
  // Extract the padding algorithm identifier from the implementation
  paddingScheme = paddingImpl.getPaddingName()
  // Filter out implementations utilizing secure padding methods
  and not paddingScheme = ["OAEP", "KEM", "PSS"]
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingScheme