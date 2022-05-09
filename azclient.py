#!/usr/bin/env python
# -*- coding: utf-8 -*-
import time
import urllib
import urllib2
import json

# Azkaban API 接口地址
az_url = "http://node-etl-03:8091/"
# Azkaban用户名
az_username = "atguigu"
# Azkaban密码
az_password = "atguigu"
# 工程名称
project = "gmall"
# flow名称
flow = "gmall"


def post(url, data):
    """
    发送post请求到指定网址

    :param url: 指定网址
    :param data: 请求参数
    :return: 请求结果
    """
    body = urllib.urlencode(data)
    request = urllib2.Request(url, body)
    urlopen = urllib2.urlopen(request).read().decode('utf-8')
    return json.loads(urlopen)


def get(url, data):
    """
    发送get请求到指定网址

    :param url: 指定网址
    :param data: 请求参数
    :return: 请求结果
    """
    body = urllib.urlencode(data)
    urlopen = urllib2.urlopen(url + body).read().decode('utf-8')
    return json.loads(urlopen)


def login():
    """
    使用`Authenticate`API进行azkaban身份认证，获取session ID

    :return: 返回session_id
    """
    data = {
        "action": "login",
        "username": az_username,
        "password": az_password
    }
    auth = post(az_url, data)
    return str(auth.get(u"session.id"))


def get_exec_id(session_id):
    """
    使用`Fetch Running Executions of a Flow`API获取正在执行的Flow的ExecId

    :param session_id: 和azkaban通讯的session_id
    :param project: 项目名称
    :param flow: 工作流名称
    :return: 执行ID
    """
    data = {
        "session.id": session_id,
        "ajax": "getRunning",
        "project": project,
        "flow": flow
    }
    execs = get(az_url + "executor?", data).get(u"execIds")
    if execs:
        return str(execs[0])
    else:
        return None


def wait_node(session_id, exec_id, node_id):
    """
    循环使用`Fetch a Flow Execution`API获取指定Flow中的某个节点(job)的执行状态，直到其执行完成

    :param session_id: 和azkaban通讯的session_id
    :param exec_id: 执行ID
    :param node_id: 指定节点(job)
    :return: 该节点是否成功执行完毕
    """
    data = {
        "session.id": session_id,
        "ajax": "fetchexecflow",
        "execid": exec_id
    }
    status = None

    # 若指定Flow中的指定Node(job)的执行状态是未完成的状态，就一直循环
    while status not in ["SUCCEEDED", "FAILED", "CANCELLED", "SKIPPED", "KILLED"]:
        # 获取指定Flow的当前的执行信息
        flow_exec = get(az_url + "executor?", data)
        # 从该Flow的执行信息中获取nodes字段的值，并遍历寻找特定的节点(job)信息，进而获取该节点(job)的状态
        for node in flow_exec.get(u"nodes"):
            if unicode(node_id) == node.get(u"id"):
                status = str(node.get(u"status"))
        print " ".join([node_id, status])
        # 等待1s，进入下一轮循环判断
        time.sleep(1)
    return status == "SUCCEEDED"
