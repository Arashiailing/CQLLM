/**
 * @name Asymmetric Padding Schemes
 * @description Identifies cryptographic implementations using asymmetric padding schemes
 *              that may be vulnerable to quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Query for cryptographic implementations that use asymmetric padding schemes
// which are potentially vulnerable to quantum attacks
from AsymmetricPadding quantumVulnerableScheme

// Generate alert with algorithm name and padding scheme details
select quantumVulnerableScheme, 
       "Vulnerable asymmetric padding scheme detected: " + 
       quantumVulnerableScheme.getPaddingName() + 
       " (quantum-susceptible)"