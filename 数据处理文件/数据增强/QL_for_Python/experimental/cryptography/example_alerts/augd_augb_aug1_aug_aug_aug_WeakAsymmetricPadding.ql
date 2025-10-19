/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that lack cryptographic strength
 * or have not been explicitly verified as secure by recognized cryptographic standards.
 * This analysis identifies potentially vulnerable padding configurations by allowing only
 * the most robust padding methods (OAEP, KEM, PSS) and flagging all other schemes as
 * potential security risks.
 * 
 * The analysis specifically targets padding implementations that may be susceptible
 * to cryptographic attacks when deployed in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding schemes for asymmetric encryption
// These specific padding techniques are proven to resist known cryptographic attacks
from AsymmetricPadding paddingMechanism, string paddingAlgorithm
where
  // Extract the padding algorithm identifier from the implementation
  paddingAlgorithm = paddingMechanism.getPaddingName()
  // Identify implementations that do not use approved secure padding methods
  and not paddingAlgorithm in ["OAEP", "KEM", "PSS"]
select paddingMechanism, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm