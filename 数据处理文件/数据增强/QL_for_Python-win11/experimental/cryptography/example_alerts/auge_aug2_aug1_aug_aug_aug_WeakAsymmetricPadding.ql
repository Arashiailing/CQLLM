/**
 * @name Weak or unknown asymmetric padding
 * @description
 * This analysis detects asymmetric encryption padding techniques that are either
 * cryptographically insecure or not explicitly validated as secure by recognized
 * security standards. The query identifies potentially vulnerable padding configurations
 * by allowing only industry-standard padding methods (OAEP, KEM, PSS) and flagging
 * all alternative schemes as possible security threats.
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

// Define secure padding schemes for asymmetric cryptographic operations
// These padding techniques are recognized as secure by established standards
from AsymmetricPadding asymmetricPaddingScheme, string paddingAlgorithmName
where
  // Extract the algorithm identifier from the padding implementation
  paddingAlgorithmName = asymmetricPaddingScheme.getPaddingName()
  // Filter out implementations using approved secure padding methods
  and not paddingAlgorithmName = ["OAEP", "KEM", "PSS"]
select asymmetricPaddingScheme, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingAlgorithmName