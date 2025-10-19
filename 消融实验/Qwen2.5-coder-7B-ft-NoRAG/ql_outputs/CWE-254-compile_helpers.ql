/**
 * @name CWE-254: Insecure Sensitive Data Exposure Through Log Files
 * @description Exposing sensitive information through log files may allow attackers to gain insights into system internals.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.0
 * @precision high
 * @id py/sensitive-data-in-logs
 * @tags security
 *       external/cwe/cwe-254
 */
import python
import semmle.python.security.dataflow.SensitiveDataExposureQuery

from LogMessage logMsg, SensitiveData sensData
where SensitiveDataExposureQuery.flowPath(logMsg, sensData)
select logMsg, sensData, "Sensitive data '$@' is exposed through a log file.", sensData.getData()