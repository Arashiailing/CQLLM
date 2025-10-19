/**
 * @name Average number of co-committed files per module
 * @description For each module, calculates the average number of files modified together in commits that affect any file in the module
 * @kind treemap
 * @id py/historical-number-of-co-commits
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

import python
import external.VCS

from Module targetModule
where exists(targetModule.getMetrics().getNumberOfLinesOfCode())
select targetModule,
  avg(Commit commit, int coModifiedCount |
    commit.getAnAffectedFile() = targetModule.getFile() and 
    coModifiedCount = (count(commit.getAnAffectedFile()) - 1)
  | coModifiedCount)