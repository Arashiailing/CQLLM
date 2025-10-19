/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding mechanisms that are either
 * cryptographically weak or not explicitly recognized as secure by cryptographic standards.
 * This query flags potentially vulnerable padding configurations by only allowing
 * the most secure padding methods (OAEP, KEM, PSS) and marking all others
 * as potential security risks.
 * 
 * The analysis specifically targets padding implementations that could be
 * vulnerable to cryptographic attacks in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding schemes
// These padding techniques are approved for use in asymmetric encryption
from AsymmetricPadding paddingMethod, string paddingAlgorithm
where
  // Retrieve the padding algorithm identifier from the implementation
  paddingAlgorithm = paddingMethod.getPaddingName()
  // Exclude implementations that use secure padding methods
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select paddingMethod, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm