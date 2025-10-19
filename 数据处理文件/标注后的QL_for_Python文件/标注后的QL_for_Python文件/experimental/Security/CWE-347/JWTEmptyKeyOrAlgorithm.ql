/**
 * @name JWT encoding using empty key or algorithm
 * @description The application uses an empty secret or algorithm while encoding a JWT Token.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-empty-secret-or-algorithm
 * @tags security
 *       experimental
 */

// 确定精度
import python  // 导入Python库
import experimental.semmle.python.Concepts  // 导入实验性SemMLE Python概念库
import experimental.semmle.python.frameworks.JWT  // 导入实验性SemMLE Python框架中的JWT库

from JwtEncoding jwtEncoding, string affectedComponent  // 从JwtEncoding和受影响的组件中选择数据
where
  affectedComponent = "algorithm" and  // 如果受影响的组件是算法并且
  isEmptyOrNone(jwtEncoding.getAlgorithm())  // JWT编码的算法为空或不存在，或者
  or
  affectedComponent = "key" and  // 如果受影响的组件是密钥并且
  isEmptyOrNone(jwtEncoding.getKey())  // JWT编码的密钥为空或不存在
select jwtEncoding, "This JWT encoding has an empty " + affectedComponent + "."  // 选择JWT编码并返回警告信息，指出该JWT编码具有空的算法或密钥。
