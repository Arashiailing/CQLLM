/**
 * @deprecated  
 * @name Duplicated lines in files  
 * @description Quantifies duplicate line occurrences across files, including code, 
 *              comments, and whitespace lines that appear in multiple locations.  
 * @kind treemap  
 * @treemap.warnOn highValues  
 * @metricType file  
 * @metricAggregate avg sum max  
 * @tags testability  
 * @id py/duplicated-lines-in-files  
 */

import python  

// Define query variables with semantic naming
from File targetFile, int duplicationCount  

// Apply deprecated query logic (no results returned)
where none()  

// Output results ordered by duplication severity
select targetFile, duplicationCount order by duplicationCount desc