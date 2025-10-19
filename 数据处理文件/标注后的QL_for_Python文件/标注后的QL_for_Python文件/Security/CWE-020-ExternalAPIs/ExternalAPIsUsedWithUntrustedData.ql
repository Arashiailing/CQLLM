/**
 * @name Frequency counts for external APIs that are used with untrusted data
 * @description This reports the external APIs that are used with untrusted data, along with how
 *              frequently the API is called, and how many unique sources of untrusted data flow
 *              to it.
 * @id py/count-untrusted-data-external-api
 * @kind table
 * @tags security external/cwe/cwe-20
 */

import python  // 导入python库，用于分析Python代码
import ExternalAPIs  // 导入外部API库，用于识别外部API调用

// 从ExternalApiUsedWithUntrustedData类中选择externalApi对象
from ExternalApiUsedWithUntrustedData externalApi

// 查询语句：选择externalApi对象，计算其被调用的次数以及不信任数据源的数量
select externalApi, count(externalApi.getUntrustedDataNode()) as numberOfUses,
  externalApi.getNumberOfUntrustedSources() as numberOfUntrustedSources order by
    numberOfUntrustedSources desc  // 按不信任数据源数量降序排列结果
