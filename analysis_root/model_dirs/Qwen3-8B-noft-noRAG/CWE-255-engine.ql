import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.scala.dataflow.DataFlow

// 定义危险函数集（可扩展）
predicate isDangerousFunction(Call call) {
  (call.getTarget().getName() = "os.system" or 
   call.getTarget().getName() = "subprocess.run" or 
   call.getTarget().getName() = "subprocess.call" or 
   call.getTarget().getName() = "subprocess.Popen" or 
   call.getTarget().getName() = "subprocess.check_output" or 
   call.getTarget().getName() = "shlex.split" or 
   call.getTarget().getName() = "eval" or 
   call.getTarget().getName() = "exec") and
  call.getArgumentCount() > 0
}

// 检测命令构造中的用户输入拼接
from Call call, Argument arg, StringLiteral strLit
where isDangerousFunction(call) and
      arg = call.getArgument(0) and
      strLit = arg.getStringValue() and
      strLit.getValue().contains("'$'") or // 直接字符串拼接
      strLit.getValue().contains("{") or    // f-string格式化
      strLit.getValue().contains("%s") or   // 格式化字符串
      strLit.getValue().contains("+" )      // 字符串连接运算符
select call, "Potential unsafe shell command construction detected"