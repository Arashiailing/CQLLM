/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly approved by security standards.
 * This query flags potentially vulnerable padding configurations
 * by excluding only the most secure padding methods (OAEP, KEM, PSS) and marking
 * all other padding schemes as potential security risks.
 * 
 * The analysis focuses on padding implementations that might be vulnerable to
 * cryptographic attacks when used in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

from AsymmetricPadding paddingScheme, string paddingAlgorithm
where
  // Extract the name of the padding algorithm from the implementation
  paddingAlgorithm = paddingScheme.getPaddingName()
  // Exclude implementations using approved secure padding schemes
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select paddingScheme, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm