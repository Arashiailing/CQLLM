import python

/**
 * 检测服务器端模板注入漏洞
 * 查找使用用户控制数据直接构造模板的情况
 */
from method_call call, StringLiteral str_lit, Parameter param
where 
  call.getMethodName() = "render_template" and
  call.getFileName() = "flask/app.py" and
  param.getName() = "template" and
  param.getValue() = str_lit.getString()
  and str_lit.getString().matches(".*{{.*}}")  // 匹配模板语法
select call, "发现潜在的服务器端模板注入漏洞: 用户输入直接用于模板构造"