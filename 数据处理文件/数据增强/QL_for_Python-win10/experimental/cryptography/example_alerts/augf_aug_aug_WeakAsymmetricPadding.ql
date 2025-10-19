/**
 * @name Vulnerable asymmetric encryption padding
 * @description
 * Identifies asymmetric encryption padding implementations that utilize
 * cryptographically insecure or non-standardized padding algorithms.
 * The query filters out industry-approved secure padding techniques (OAEP, KEM, PSS)
 * and highlights all remaining padding methods as potential security risks.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding implementations using insecure algorithms
from AsymmetricPadding asymmetricPadding, string paddingAlgorithm
where
  // Extract padding algorithm name from implementation
  paddingAlgorithm = asymmetricPadding.getPaddingName()
  // Filter out secure padding algorithms (OAEP, KEM, PSS)
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select asymmetricPadding, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm