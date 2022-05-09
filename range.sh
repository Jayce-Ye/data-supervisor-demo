#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# 计算某一列异常值个数

while getopts "t:d:l:c:s:x:a:b:" arg; do
  case $arg in
  # 要处理的表名
  t)
    TABLE=$OPTARG
    ;;
  # 日替
  d)
    DT=$OPTARG
    ;;
  # 要处理的列
  c)
    COL=$OPTARG
    ;;
  # 不在规定值域的值的个数下限
  s)
    MIN=$OPTARG
    ;;
  # 不在规定值域的值的个数上限
  x)
    MAX=$OPTARG
    ;;
  # 告警级别
  l)
    LEVEL=$OPTARG
    ;;
  # 规定值域为a-b
  a)
    RANGE_MIN=$OPTARG
    ;;
  b)
    RANGE_MAX=$OPTARG
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
mysql_tbl="rng"

# 认证为hive用户，如在非安全(Hadoop未启用Kerberos认证)环境中，则无需认证
kinit -kt /etc/security/keytab/hive.keytab hive

# 查询不在规定值域的值的个数
RESULT=$($HIVE_ENGINE -e "set hive.cli.print.header=false;select count(1) from $HIVE_DB.$TABLE where dt='$DT' and $COL not between $RANGE_MIN and $RANGE_MAX;")

# 将结果写入MySQL
mysql -h"$mysql_host" -u"$mysql_user" -p"$mysql_passwd" \
  -e"INSERT INTO $mysql_DB.$mysql_tbl VALUES('$DT', '$TABLE', '$COL', $RESULT, $RANGE_MIN, $RANGE_MAX, $MIN, $MAX, $LEVEL)
ON DUPLICATE KEY UPDATE \`value\`=$RESULT, range_min=$RANGE_MIN, range_max=$RANGE_MAX, value_min=$MIN, value_max=$MAX, notification_level=$LEVEL;"
