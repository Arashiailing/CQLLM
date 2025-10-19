/**
 * @deprecated
 * @name Duplicate function
 * @description Identical function implementation detected. Refactor by extracting common code to shared modules or base classes.
 * @kind problem
 * @tags testability
 *       useless-code
 *       maintainability
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/duplicate-function
 */

import python

// Query detects duplicate functions but is explicitly disabled
// The none() predicate ensures no results are generated
from Function sourceFunction, string alertMessage, Function replicatedFunction
where none() // Filter prevents any output from being produced
select sourceFunction, alertMessage, replicatedFunction, replicatedFunction.getName()