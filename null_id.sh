#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# 检查id空值
# 解析参数
while getopts "t:d:c:s:x:l:" arg; do
  case $arg in
  # 要处理的表名
  t)
    TABLE=$OPTARG
    ;;
  # 日期
  d)
    DT=$OPTARG
    ;;
  # 要计算空值的列名
  c)
    COL=$OPTARG
    ;;
  # 空值指标下限
  s)
    MIN=$OPTARG
    ;;
  # 空值指标上限
  x)
    MAX=$OPTARG
    ;;
  # 告警级别
  l)
    LEVEL=$OPTARG
    ;;
  ?)
    echo "unkonw argument"
    exit 1
    ;;
  esac
done

#如果dt和level没有设置，那么默认值dt是昨天 告警级别是0
[ "$DT" ] || DT=$(date -d '-1 day' +%F)
[ "$LEVEL" ] || LEVEL=0

# 数仓DB名称
HIVE_DB=gmall

# 查询引擎
HIVE_ENGINE=hive

# MySQL相关配置
mysql_user="root"
mysql_passwd="000000"
mysql_host="hadoop102"
mysql_DB="data_supervisor"
mysql_tbl="null_id"

# 认证为hive用户，如在非安全(Hadoop未启用Kerberos认证)环境中，则无需认证
kinit -kt /etc/security/keytab/hive.keytab hive

# 空值个数
RESULT=$($HIVE_ENGINE -e "set hive.cli.print.header=false;select count(1) from $HIVE_DB.$TABLE where dt='$DT' and $COL is null;")

#结果插入MySQL
mysql -h"$mysql_host" -u"$mysql_user" -p"$mysql_passwd" \
  -e"INSERT INTO $mysql_DB.$mysql_tbl VALUES('$DT', '$TABLE', '$COL', $RESULT, $MIN, $MAX, $LEVEL)
ON DUPLICATE KEY UPDATE \`value\`=$RESULT, value_min=$MIN, value_max=$MAX, notification_level=$LEVEL;"
