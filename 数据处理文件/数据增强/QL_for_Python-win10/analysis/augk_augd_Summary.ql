/**
 * 收集并展示数据库快照的关键元数据指标
 * 包括版本信息、构建时间、环境配置和代码统计等
 */

import python

// 从键值对中检索快照元数据指标
from string metricKey, string metricVal
where
  // 获取提取器版本号
  metricKey = "Extractor version" and py_flags_versioned("extractor.version", metricVal, _)
  or
  // 获取快照构建日期并格式化为字符串
  metricKey = "Snapshot build time" and
  exists(date snapshotCreationDate | 
    snapshotDate(snapshotCreationDate) and metricVal = snapshotCreationDate.toString()
  )
  or
  // 组合Python解释器的主版本和次版本号
  metricKey = "Interpreter version" and
  exists(string pythonMajorVersion, string pythonMinorVersion |
    py_flags_versioned("extractor_python_version.major", pythonMajorVersion, _) and
    py_flags_versioned("extractor_python_version.minor", pythonMinorVersion, _) and
    metricVal = pythonMajorVersion + "." + pythonMinorVersion
  )
  or
  // 将原始平台标识符映射为用户友好的平台名称
  metricKey = "Build platform" and
  exists(string platformIdentifier | 
    py_flags_versioned("sys.platform", platformIdentifier, _) |
    if platformIdentifier = "win32"
    then metricVal = "Windows"
    else
      if platformIdentifier = "linux2"
      then metricVal = "Linux"
      else
        if platformIdentifier = "darwin"
        then metricVal = "OSX"
        else metricVal = platformIdentifier
  )
  or
  // 获取源代码根目录路径
  metricKey = "Source location" and sourceLocationPrefix(metricVal)
  or
  // 计算所有模块的源代码行数总和（仅包含有相对路径的文件）
  metricKey = "Lines of code (source)" and
  metricVal =
    sum(ModuleMetrics moduleMetrics | 
      exists(moduleMetrics.getFile().getRelativePath()) | 
      moduleMetrics.getNumberOfLinesOfCode()
    ).toString()
  or
  // 计算所有模块的总行数（包括所有文件）
  metricKey = "Lines of code (total)" and
  metricVal = sum(ModuleMetrics moduleMetrics | any() | moduleMetrics.getNumberOfLinesOfCode()).toString()
select metricKey, metricVal