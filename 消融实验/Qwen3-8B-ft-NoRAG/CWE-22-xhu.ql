import python
from Call call, New new, Variable var
where call.getTarget() = new and new.getKind() = "str" and call.getFunction() = "input"
select var, "This variable is obtained from user input."

import python
from Call call, Variable var
where call.getFunction() = "str.concat" and call.getArgument(0) = var
select var, "Variable used in string concatenation."

import python
from Call call, Variable var
where call.getFunction() = "str.concat" and call.getArgument(0) = var or call.getArgument(1) = var
select call, "String concatenation with user input variable."

import python
from Call call, Variable var
where call.getFunction() = "open" and call.getArgument(0) = var
select call, "Open call with user input variable as path."

import python
from FunctionCall fc, Variable var
where fc.getFunction() = "input"
select var, "User input variable."

import python
from Call call, Variable var
where call.getFunction() = "open" and call.getArgument(0) = var
select call, "Open call with user input variable as path."

import python
from Call call, Variable var
where call.getFunction() = "str.concat" and call.getArgument(0) = var or call.getArgument(1) = var
select call, "String concatenation with user input variable."

import python
from Call call, Variable var
where call.getFunction() = "os.path.join" and call.getArgument(0) = var or call.getArgument(1) = var
select call, "os.path.join with user input variable."

import python
from Call inputCall, Variable userInputVar, Call pathCall
where inputCall.getFunction() = "input"
  and pathCall.getArgument(0) = userInputVar
select pathCall, "Potential path injection due to user input in path."

import python
from Call inputCall, Variable userInputVar, Call pathCall
where inputCall.getFunction() = "input"
  and pathCall.getArgument(0) = userInputVar
select pathCall, "Potential path injection due to user input in path."

import python
from Call inputCall, Variable userInputVar, Call pathCall
where inputCall.getFunction() = "input"
  and pathCall.getArgument(0) = userInputVar
select pathCall, "Potential path injection due to user input in path."

import python
from Call inputCall, Variable userInputVar, Call pathCall
where inputCall.getFunction() = "input"
  and (pathCall.getFunction() = "open" or pathCall.getFunction() = "os.path.join")
  and pathCall.getArgument(0) = userInputVar
select pathCall, "Potential path injection due to user input in path."

import python
from Call inputCall, Variable userInputVar, Call pathCall
where inputCall.getFunction() = "input"
  and pathCall.getArgument(0) = userInputVar
select pathCall, "Potential path injection due to user input in path."

import python
from Call inputCall, Variable userInputVar, Call pathCall
where inputCall.getFunction() = "input"
  and (pathCall.getFunction() = "open" or pathCall.getFunction() = "os.path.join" or pathCall.getFunction() = "str.concat")
  and pathCall.getArgument(0) = userInputVar
select pathCall, "Potential path injection due to user input in path."

import python
from Call inputCall, Variable userInputVar, Call pathCall
where inputCall.getFunction() = "input"
  and (pathCall.getFunction() = "open" or pathCall.getFunction() = "os.path.join" or pathCall.getFunction() = "str.concat")
  and exists(pathCall.getArgument(i) = userInputVar for i in 0..pathCall.getArgumentCount())
select pathCall, "Potential path injection due to user input in path."

import python
from Call inputCall, Variable userInputVar, Call pathCall
where inputCall.getFunction() = "input"
  and pathCall.getArgument(0) = userInputVar
  and (pathCall.getFunction() = "open" or pathCall.getFunction() = "os.path.join")
select pathCall, "Potential path injection due to user input in path."

import python
from Call inputCall, Variable userInputVar, Call concatCall
where inputCall.getFunction() = "input"
  and concatCall.getFunction() = "str.concat"
  and (concatCall.getArgument(0) = userInputVar or concatCall.getArgument(1) = userInputVar)
select concatCall, "String concatenation with user input variable."

import python
from Call inputCall, Variable userInputVar, Call concatCall, Call openCall
where inputCall.getFunction() = "input"
  and concatCall.getFunction() = "str.concat"
  and (concatCall.getArgument(0) = userInputVar or concatCall.getArgument(1) = userInputVar)
  and openCall.getArgument(0) = concatCall
select openCall, "Potential path injection via string concatenation."

import python
from Call inputCall, Variable userInputVar, Call pathCall
where inputCall.getFunction() = "input"
  and (pathCall.getFunction() = "open" or pathCall.getFunction() = "os.path.join" or pathCall.getFunction() = "str.concat")
  and pathCall.getArgument(0) = userInputVar
select pathCall, "Potential path injection due to user input in path."

import python
from Call inputCall, Variable userInputVar, Call pathCall
where inputCall.getFunction() = "input"
  and pathCall.getArgument(0) = userInputVar
  and (pathCall.getFunction() = "open" or pathCall.getFunction() = "os.path.join")
select pathCall, "Potential path injection due to user input in path."

import python
from Call inputCall, Variable userInputVar, Call pathCall
where inputCall.getFunction() = "input"
  and pathCall.getArgument(0) = userInputVar
  and (pathCall.getFunction() = "open" or pathCall.getFunction() = "os.path.join")
select pathCall, "Potential path injection due to user input in path."

import python
from Call inputCall, Variable userInputVar, Call pathCall
where inputCall.getFunction() = "input"
  and (pathCall.getFunction() = "open" or pathCall.getFunction() = "os.path.join")
  and exists(pathCall.getArgument(i) = userInputVar for i in 0..pathCall.getArgumentCount())
select pathCall, "Potential path injection due to user input in path."