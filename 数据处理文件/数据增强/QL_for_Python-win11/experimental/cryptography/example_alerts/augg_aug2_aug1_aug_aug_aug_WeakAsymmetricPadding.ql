/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * security standards. This analysis identifies potentially vulnerable padding configurations
 * by allowing only the most robust padding methods (OAEP, KEM, PSS) and flagging
 * all other schemes as potential security risks.
 * 
 * The query targets padding implementations that could be susceptible
 * to cryptographic attacks when used in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the list of approved secure padding schemes for asymmetric encryption
// Only these specific padding techniques are considered secure
from AsymmetricPadding insecurePaddingScheme, string paddingAlgorithmName
where
  // Extract the padding algorithm identifier from the implementation
  paddingAlgorithmName = insecurePaddingScheme.getPaddingName()
  // Filter out implementations that use approved secure padding methods
  and not paddingAlgorithmName = ["OAEP", "KEM", "PSS"]
select insecurePaddingScheme, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingAlgorithmName