/**
 * @deprecated
 * @name 外部依赖源链接
 * @kind source-link
 * @metricType externalDependency
 * @id py/dependency-source-links
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * 此查询用于构建代码库中外部依赖关系的源链接映射。
 * 
 * 功能描述：
 * 通过分析源代码，识别所有文件对外部包的引用关系，并为每个依赖
 * 关系创建唯一标识符，便于后续的安全分析和依赖跟踪。
 * 
 * 实现细节：
 * - 依赖标识符格式：'/file/path<|>dependency'
 * - '/file/path'表示相对于源代码根目录的文件路径
 * - 路径设计为版本无关，确保跨版本兼容性
 * - 输出的File实体(第二列)用于仪表板数据库中的源链接获取
 *   通过ExternalEntity.getASourceLink()方法实现链接解析
 * 
 * 处理流程：
 * 1. 依赖发现：扫描代码库中的所有源文件
 * 2. 引用验证：确认外部包引用节点位于当前分析的源文件中
 * 3. 标识生成：为每个依赖关系创建唯一标识符
 * 4. 结果输出：返回依赖标识符及其对应的源文件实体
 */

from File codeFile, string dependencyId
where
  exists(PackageObject extPackage, AstNode refNode |
    // 检测代码节点对外部包的引用关系
    dependency(refNode, extPackage) and
    
    // 验证引用节点确实属于当前分析的源文件
    refNode.getLocation().getFile() = codeFile and
    
    // 构建依赖实体唯一标识符，结合文件路径与包信息
    dependencyId = munge(codeFile, extPackage)
  )
select dependencyId, codeFile