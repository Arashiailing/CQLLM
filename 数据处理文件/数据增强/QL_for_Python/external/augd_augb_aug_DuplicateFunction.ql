/**
 * @name Duplicate function identification
 * @description Detects functions with identical implementations across the codebase.
 *              Such duplication should be consolidated into shared modules or base classes
 *              to enhance code reusability and maintainability.
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

from Function sourceFunc, Function targetFunc, string duplicateMessage
where
  exists(Function func1, Function func2 |
    func1 != func2 and
    func1.getBody() = func2.getBody() and
    sourceFunc = func1 and
    targetFunc = func2 and
    (
      sourceFunc.getLocation().getFile().getAbsolutePath() < targetFunc.getLocation().getFile().getAbsolutePath()
      or
      (
        sourceFunc.getLocation().getFile().getAbsolutePath() = targetFunc.getLocation().getFile().getAbsolutePath() and
        sourceFunc.getName() < targetFunc.getName()
      )
    ) and
    duplicateMessage = "This function is a duplicate of " + targetFunc.getName() + "."
  )
select sourceFunc, duplicateMessage, targetFunc, targetFunc.getName()