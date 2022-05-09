#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import os
from azclient import login,wait_node,get_exec_id
from check_notification import get_yesterday

def check_ods(dt, session_id, exec_id):
    """
    检查ODS层数据质量

    :param dt: 日期
    :param session_id: 和azkaban通讯的session_id
    :param exec_id: 指定的执行ID
    :return: None
    """
    if wait_node(session_id, exec_id, "hdfs_to_ods_db") and wait_node(session_id, exec_id, "hdfs_to_ods_log"):
        os.system("bash check_ods.sh " + dt)

if __name__ == '__main__':
    argv = sys.argv
    # 获取session_id
    session_id = login()

    # 获取执行ID。只有在原Flow正在执行时才能获取
    exec_id = get_exec_id(session_id)

    # 获取日期，如果不存在取昨天
    if len(argv) >= 2:
        dt = argv[1]
    else:
        dt = get_yesterday()

    # 检查各层数据质量
    if exec_id:
        check_ods(dt, session_id, exec_id)
