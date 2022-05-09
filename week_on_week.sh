#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# 计算一张表一周数据量同比增长值
# 参数解析
while getopts "t:d:s:x:l:" arg; do
  case $arg in
  # 要处理的表名
  t)
    TABLE=$OPTARG
    ;;
  # 日期
  d)
    DT=$OPTARG
    ;;
  # 同比增长指标下限
  s)
    MIN=$OPTARG
    ;;
  # 同比增长指标上限
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
mysql_tbl="week_on_week"

# 认证为hive用户，如在非安全(Hadoop未启用Kerberos认证)环境中，则无需认证
kinit -kt /etc/security/keytab/hive.keytab hive

# 上周数据量
LASTWEEK=$($HIVE_ENGINE -e "set hive.cli.print.header=false;select count(1) from $HIVE_DB.$TABLE where dt=date_add('$DT',-7);")

# 本周数据量
THISWEEK=$($HIVE_ENGINE -e "set hive.cli.print.header=false;select count(1) from $HIVE_DB.$TABLE where dt='$DT';")

# 计算增长
if [ $LASTWEEK -ne 0 ]; then
  RESULT=$(awk "BEGIN{print ($THISWEEK-$LASTWEEK)/$LASTWEEK*100}")
else
  RESULT=10000
fi

# 将结果写入MySQL
mysql -h"$mysql_host" -u"$mysql_user" -p"$mysql_passwd" \
  -e"INSERT INTO $mysql_DB.$mysql_tbl VALUES('$DT', '$TABLE', $RESULT, $MIN, $MAX, $LEVEL)
ON DUPLICATE KEY UPDATE \`value\`=$RESULT, value_min=$MIN, value_max=$MAX, notification_level=$LEVEL;"
