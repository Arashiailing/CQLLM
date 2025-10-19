/**
 * @name Detection of Insecure Asymmetric Encryption Padding
 * @description
 * Identifies asymmetric encryption padding methods that are considered
 * cryptographically weak or not explicitly verified as secure.
 * The analysis excludes recognized secure padding schemes (OAEP, KEM, PSS)
 * and flags any alternative padding methods as potential security risks.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding schemes
string getSecurePaddingMethods() {
  result = "OAEP"
  or
  result = "KEM"
  or
  result = "PSS"
}

// Locate asymmetric encryption implementations that utilize insecure padding
from AsymmetricPadding asymmetricPaddingImpl, string paddingMethodName
where
  // Retrieve the padding method name from the implementation
  paddingMethodName = asymmetricPaddingImpl.getPaddingName()
  // Exclude implementations using approved secure padding methods
  and not paddingMethodName = getSecurePaddingMethods()
select asymmetricPaddingImpl, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingMethodName