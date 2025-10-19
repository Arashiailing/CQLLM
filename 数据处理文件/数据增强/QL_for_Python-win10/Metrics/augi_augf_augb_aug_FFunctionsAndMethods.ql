/**
 * @name Module Function Population Analysis
 * @description Analyzes the distribution of functions and methods within Python modules to provide 
 *              insights into code structure complexity and module organization patterns.
 * @kind treemap
 * @id py/function-density-per-module
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// Retrieve all Python modules and their associated function populations
from Module targetModule, int funcPopulation
// Calculate the aggregate count of named functions (excluding lambdas) for each module
where funcPopulation = count(Function funcEntity | 
       funcEntity.getEnclosingModule() = targetModule and 
       funcEntity.getName() != "lambda")
// Output modules with their respective function populations, sorted in descending order
select targetModule, funcPopulation order by funcPopulation desc