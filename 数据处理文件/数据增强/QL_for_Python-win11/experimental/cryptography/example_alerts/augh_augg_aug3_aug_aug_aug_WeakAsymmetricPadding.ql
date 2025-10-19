/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly approved by security standards.
 * This query identifies potentially vulnerable padding configurations
 * by excluding only the most secure padding methods (OAEP, KEM, PSS) and marking
 * all other padding schemes as potential security risks.
 * 
 * The analysis targets padding implementations that could be vulnerable to
 * cryptographic attacks when used in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

from AsymmetricPadding paddingImpl, string algoName
where
  // Retrieve the padding algorithm name from the implementation
  algoName = paddingImpl.getPaddingName()
  // Exclude implementations using approved secure padding schemes
  and not algoName = ["OAEP", "KEM", "PSS"]
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + algoName