/**
 * @name Python file comment density assessment
 * @description Computes the ratio of comment lines to total lines in Python source files.
 *              Docstrings are not included in comment line counts and are evaluated separately.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

from Module fileModule, 
     int totalLines, 
     int commentLines
where totalLines = fileModule.getMetrics().getNumberOfLines() and
      totalLines > 0 and
      commentLines = fileModule.getMetrics().getNumberOfLinesOfComments()
select fileModule, 
       100.0 * commentLines / totalLines as commentLineRatio
order by commentLineRatio desc