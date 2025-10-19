/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding mechanisms that are either
 * cryptographically insecure or not explicitly endorsed by security standards.
 * This query identifies potentially vulnerable padding configurations
 * by excluding only the most robust padding methods (OAEP, KEM, PSS) and flagging
 * all other padding schemes as possible security threats.
 * 
 * The analysis targets padding implementations that could be susceptible to
 * cryptographic attacks when utilized in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

from AsymmetricPadding paddingImpl, string algorithmName
where
  // Retrieve the algorithm name from the padding implementation
  algorithmName = paddingImpl.getPaddingName()
  // Filter out implementations employing approved secure padding schemes
  and not algorithmName = ["OAEP", "KEM", "PSS"]
select paddingImpl, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + algorithmName