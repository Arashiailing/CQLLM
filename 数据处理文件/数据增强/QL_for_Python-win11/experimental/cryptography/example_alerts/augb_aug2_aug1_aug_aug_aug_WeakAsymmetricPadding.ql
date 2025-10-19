/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * security standards. This analysis identifies potentially vulnerable padding configurations
 * by allowing only the most robust padding methods (OAEP, KEM, PSS) and marking
 * all other schemes as potential security risks.
 * 
 * The query specifically targets padding implementations that could be susceptible
 * to cryptographic attacks when used in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the collection of cryptographically secure padding schemes for asymmetric encryption
// These padding techniques are widely recognized as secure for asymmetric encryption
from AsymmetricPadding insecurePaddingScheme, string paddingAlgorithm
where
  // Extract the padding algorithm identifier from the implementation
  paddingAlgorithm = insecurePaddingScheme.getPaddingName()
  // Filter out implementations that employ secure padding methods
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select insecurePaddingScheme, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingAlgorithm