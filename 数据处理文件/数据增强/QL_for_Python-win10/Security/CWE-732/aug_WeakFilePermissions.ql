/**
 * @name Overly permissive file permissions
 * @description Allowing files to be readable or writable by users other than the owner may allow sensitive information to be accessed.
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

// Calculate world permissions (other users' access level) from a permission mask
bindingset[perm]
int world_permission(int perm) { result = perm % 8 }

// Calculate group permissions from a permission mask
bindingset[perm]
int group_permission(int perm) { result = (perm / 8) % 8 }

// Convert permission value to readable access description
bindingset[perm]
string access(int perm) {
  perm % 4 >= 2 and result = "writable"  // Writable if last 2 bits >= 2
  or
  perm % 4 < 2 and perm != 0 and result = "readable"  // Readable if last 2 bits < 2 and non-zero
}

// Generate permission description for overly permissive settings
bindingset[perm]
string permissive_permission(int perm) {
  result = "world " + access(world_permission(perm))  // Check world permissions first
  or
  world_permission(perm) = 0 and result = "group " + access(group_permission(perm))  // Fallback to group if world is 0
}

// Match os.chmod API calls and extract permission parameters
predicate chmod_call(API::CallNode apiCall, string funcName, int modeValue) {
  apiCall = API::moduleImport("os").getMember("chmod").getACall() and
  modeValue = apiCall.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  funcName = "chmod"
}

// Match os.open API calls and extract permission parameters
predicate open_call(API::CallNode apiCall, string funcName, int modeValue) {
  apiCall = API::moduleImport("os").getMember("open").getACall() and
  modeValue = apiCall.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  funcName = "open"
}

// Find API calls with overly permissive file permissions
from API::CallNode apiCall, string funcName, int modeValue, string permDesc
where
  (chmod_call(apiCall, funcName, modeValue) or open_call(apiCall, funcName, modeValue)) and
  permDesc = permissive_permission(modeValue)
select apiCall, "Overly permissive mask in " + funcName + " sets file to " + permDesc + "."