/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either cryptographically weak
 * or not explicitly recognized as secure. This analysis excludes approved padding methods
 * (OAEP, KEM, PSS) and flags all other padding schemes as potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

/**
 * Defines a collection of cryptographically secure padding schemes
 * that are considered safe for asymmetric encryption operations.
 * These padding methods are industry standards and have undergone
 * extensive cryptanalysis to prove their security properties.
 */
string approvedSecurePaddingMethods() {
  result = ["OAEP", "KEM", "PSS"]
}

/**
 * Identifies implementations of asymmetric padding schemes that are not
 * on the approved list of secure padding methods. This query flags any
 * padding that is either known to be weak or not explicitly recognized
 * as secure, which could lead to cryptographic vulnerabilities.
 */
from AsymmetricPadding paddingImplementation, string paddingAlgorithm
where
  // Extract the name of the padding algorithm from the implementation
  paddingAlgorithm = paddingImplementation.getPaddingName()
  // Exclude implementations that use approved secure padding algorithms
  and not paddingAlgorithm = approvedSecurePaddingMethods()
select paddingImplementation, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingAlgorithm