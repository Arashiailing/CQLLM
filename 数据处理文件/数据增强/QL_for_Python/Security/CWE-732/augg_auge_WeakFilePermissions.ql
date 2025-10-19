/**
 * @name Overly permissive file permissions
 * @description Detects file permission settings that grant excessive access rights to non-owner users
 * @kind problem
 * @id py/overly-permissive-file
 * @problem.severity warning
 * @security-severity 7.8
 * @sub-severity high
 * @precision medium
 * @tags external/cwe/cwe-732
 *       security
 */

import python
import semmle.python.ApiGraphs

/**
 * Extracts the world-accessible permission bits (least significant 3 bits) from a file permission value.
 * @param permValue The complete permission value (e.g., 0o777)
 * @return The world permission component (0-7)
 */
bindingset[permValue]
int getWorldPermBits(int permValue) { 
  result = permValue % 8 
}

/**
 * Extracts the group-accessible permission bits (middle 3 bits) from a file permission value.
 * @param permValue The complete permission value (e.g., 0o777)
 * @return The group permission component (0-7)
 */
bindingset[permValue]
int getGroupPermBits(int permValue) { 
  result = (permValue / 8) % 8 
}

/**
 * Generates a textual description of permission access levels.
 * @param permBits The permission component to describe (0-7)
 * @return "writable" if write access is granted, "readable" if only read access is granted
 */
bindingset[permBits]
string getPermAccessDesc(int permBits) {
  permBits % 4 >= 2 and result = "writable"
  or
  permBits % 4 < 2 and permBits != 0 and result = "readable"
}

/**
 * Identifies overly permissive permission components within a file permission value.
 * @param permValue The complete permission value to analyze
 * @return Description of the permissive component (e.g., "world writable")
 */
bindingset[permValue]
string findPermissiveComponent(int permValue) {
  result = "world " + getPermAccessDesc(getWorldPermBits(permValue))
  or
  getWorldPermBits(permValue) = 0 and 
  result = "group " + getPermAccessDesc(getGroupPermBits(permValue))
}

/**
 * Matches file permission API calls and extracts the permission mode parameter.
 * @param apiCall The API call node
 * @param methodName The name of the API method ("chmod" or "open")
 * @param permMode The permission mode value
 */
predicate isFilePermCall(API::CallNode apiCall, string methodName, int permMode) {
  (methodName = "chmod" and
   apiCall = API::moduleImport("os").getMember("chmod").getACall() and
   permMode = apiCall.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue())
  or
  (methodName = "open" and
   apiCall = API::moduleImport("os").getMember("open").getACall() and
   permMode = apiCall.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue())
}

// Identify file permission API calls with overly permissive access modes
from API::CallNode apiCall, string methodName, int permMode, string permIssue
where
  isFilePermCall(apiCall, methodName, permMode) and
  permIssue = findPermissiveComponent(permMode)
select apiCall, "Overly permissive mask in " + methodName + " sets file to " + permIssue + "."