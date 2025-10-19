/**
 * @name Symmetric Padding Schemes Detection
 * @description Identifies cryptographic padding schemes used with symmetric encryption algorithms.
 *              This query helps detect specific padding methods that may impact security posture,
 *              particularly in quantum readiness assessments and CBOM analysis.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding scheme
select scheme, 
       "Use of algorithm " + scheme.getPaddingName()