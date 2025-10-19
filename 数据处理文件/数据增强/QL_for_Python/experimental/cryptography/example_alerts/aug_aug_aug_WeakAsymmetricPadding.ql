/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly approved by security standards.
 * This analysis focuses on detecting potentially vulnerable padding configurations
 * by excluding only the most secure padding methods (OAEP, KEM, PSS) and flagging
 * all other padding schemes as potential security risks.
 * 
 * The query targets padding implementations that could be susceptible to various
 * cryptographic attacks when used in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding schemes
// These padding methods are considered safe for asymmetric encryption
from AsymmetricPadding paddingImplementation, string paddingAlgorithm
where
  // Extract the specific padding algorithm name from the implementation
  paddingAlgorithm = paddingImplementation.getPaddingName()
  // Filter out implementations using secure padding schemes
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select paddingImplementation, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm