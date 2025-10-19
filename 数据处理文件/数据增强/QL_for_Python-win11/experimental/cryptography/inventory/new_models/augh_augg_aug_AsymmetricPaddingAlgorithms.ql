/**
 * @name Asymmetric Padding Schemes
 * @description Detects cryptographic implementations utilizing asymmetric padding schemes
 *              that are potentially vulnerable to attacks from quantum computers.
 *              These schemes may compromise long-term security in a post-quantum world.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Locate asymmetric cryptographic padding implementations that lack quantum resistance
from AsymmetricPadding paddingWithQuantumRisk

// Construct alert with specifics about the quantum-vulnerable padding scheme discovered
select paddingWithQuantumRisk, 
       "Quantum-vulnerable asymmetric padding scheme identified: " + 
       paddingWithQuantumRisk.getPaddingName() + 
       " (quantum-susceptible)"