/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly approved by security standards.
 * This query identifies potentially vulnerable padding configurations
 * by excluding only the most secure padding methods (OAEP, KEM, PSS) and flagging
 * all other padding schemes as potential security risks.
 * 
 * The analysis targets padding implementations that could be susceptible to
 * cryptographic attacks when used in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define cryptographically secure padding schemes considered safe for asymmetric encryption
from AsymmetricPadding paddingImpl, string paddingName
where
  // Extract the specific padding algorithm name from the implementation
  paddingName = paddingImpl.getPaddingName()
  // Identify implementations using non-approved padding schemes
  and not paddingName = ["OAEP", "KEM", "PSS"]
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingName