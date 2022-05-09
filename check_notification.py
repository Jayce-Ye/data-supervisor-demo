#!/usr/bin/env python
# -*- coding: utf-8 -*-

import mysql.connector
import sys
import smtplib
from email.mime.text import MIMEText
from email.header import Header
import datetime
import urllib
import urllib2
import random


def get_yesterday():
    """
    :return: 前一天的日期
    """
    today = datetime.date.today()
    one_day = datetime.timedelta(days=1)
    yesterday = today - one_day
    return str(yesterday)


def read_table(table, dt):
    """
    :param table:读取的表名
    :param dt:读取的数据日期
    :return:表中的异常数据(统计结果超出规定上下限的数据)
    """

    # mysql必要参数设置，需根据实际情况作出修改
    mysql_user = "root"
    mysql_password = "000000"
    mysql_host = "hadoop102"
    mysql_schema = "data_supervisor"

    # 获取Mysql数据库连接
    connect = mysql.connector.connect(user=mysql_user, password=mysql_password, host=mysql_host, database=mysql_schema)
    cursor = connect.cursor()

    # 查询表头
    # ['dt', 'tbl', 'col', 'value', 'value_min', 'value_max', 'notification_level']
    query = "desc " + table
    cursor.execute(query)
    head = map(lambda x: str(x[0]), cursor.fetchall())

    # 查询异常数据(统计结果超出规定上下限的数据)
    # [(datetime.date(2021, 7, 16), u'dim_user_info', u'id', 7, 0, 5, 1),
    # (datetime.date(2021, 7, 16), u'dwd_order_id', u'id', 10, 0, 5, 1)]
    query = ("select * from " + table + " where dt='" + dt + "' and `value` not between value_min and value_max")
    cursor.execute(query)
    cursor_fetchall = cursor.fetchall()

    # 将指标和表头映射成为dict数组
    #[{'notification_level': 1, 'value_min': 0, 'value': 7, 'col': u'id', 'tbl': u'dim_user_info', 'dt': datetime.date(2021, 7, 16), 'value_max': 5},
    # {'notification_level': 1, 'value_min': 0, 'value': 10, 'col': u'id', 'tbl': u'dwd_order_id', 'dt': datetime.date(2021, 7, 16), 'value_max': 5}]
    fetchall = map(lambda x: dict(x), map(lambda x: zip(head, x), cursor_fetchall))
    return fetchall


def one_alert(line):
    """
    集成第三方告警平台睿象云，使用其提供的通知媒介发送告警信息
    :param line: 一个等待通知的异常记录，{'notification_level': 1, 'value_min': 0, 'value': 7, 'col': u'id', 'tbl': u'dim_user_info', 'dt': datetime.date(2021, 7, 16), 'value_max': 5}
    """

    # 集成睿象云需要使用的rest接口，和APP KEY，须在睿象云平台获取
    one_alert_key = "c2030c9a-7896-426f-bd64-59a8889ac8e3"
    one_alert_host = "http://api.aiops.com/alert/api/event"

    # 根据睿象云的rest api要求，传入必要的参数
    data = {
        "app": one_alert_key,
        "eventType": "trigger",
        "eventId": str(random.randint(10000, 99999)),
        "alarmName": "".join(["表格", str(line["tbl"]), "数据异常."]),
        "alarmContent": "".join(["指标", str(line["norm"]), "值为", str(line["value"]),
                                 ", 应为", str(line["value_min"]), "-", str(line["value_max"]),
                                 ", 参考信息：" + str(line["col"]) if line.get("col") else ""]),
        "priority": line["notification_level"] + 1
    }

    # 使用urllib和urllib2向睿象云的rest结构发送请求，从而触发睿象云的通知策略
    body = urllib.urlencode(data)
    request = urllib2.Request(one_alert_host, body)
    urlopen = urllib2.urlopen(request).read().decode('utf-8')
    print urlopen


def mail_alert(line):
    """
    使用电子邮件的方式发送告警信息
    :param line: 一个等待通知的异常记录，{'notification_level': 1, 'value_min': 0, 'value': 7, 'col': u'id', 'tbl': u'dim_user_info', 'dt': datetime.date(2021, 7, 16), 'value_max': 5}
    """

    # smtp协议发送邮件的必要设置
    mail_host = "smtp.qq.com"
    mail_user = "2023851094@qq.com"
    mail_pass = "ffeyrdvmhvpmcjff"

    # 告警内容
    message = ["".join(["表格", str(line["tbl"]), "数据异常."]),
               "".join(["指标", str(line["norm"]), "值为", str(line["value"]),
                        ", 应为", str(line["value_min"]), "-", str(line["value_max"]),
                        ", 参考信息：" + str(line["col"]) if line.get("col") else ""])]
    # 告警邮件，发件人
    sender = mail_user

    # 告警邮件，收件人
    receivers = [mail_user]

    # 将邮件内容转为html格式
    mail_content = MIMEText("".join(["<html>", "<br>".join(message), "</html>"]), "html", "utf-8")
    mail_content["from"] = sender
    mail_content["to"] = receivers[0]
    mail_content["Subject"] = Header(message[0], "utf-8")

    # 使用smtplib发送邮件
    try:
        smtp = smtplib.SMTP_SSL()
        smtp.connect(mail_host, 465)
        smtp.login(mail_user, mail_pass)
        content_as_string = mail_content.as_string()
        smtp.sendmail(sender, receivers, content_as_string)
    except smtplib.SMTPException as e:
        print e


def main(argv):
    """
    :param argv: 系统参数，共三个，第一个为python脚本本身，第二个为告警方式，第三个为日期
    """

    # 如果没有传入日期参数，将日期定为昨天
    if len(argv) >= 3:
        dt = argv[2]
    else:
        dt = get_yesterday()

    notification_level = 0

    # 通过参数设置告警方式，默认是睿象云
    alert = None
    if len(argv) >= 2:
        alert = {
            "mail": mail_alert,
            "one": one_alert
        }[argv[1]]
    if not alert:
        alert = one_alert

    # 遍历所有表，查询所有错误内容，如果大于设定警告等级，就发送警告
    for table in ["day_on_day", "duplicate", "null_id", "rng", "week_on_week"]:
        for line in read_table(table, dt):
            if line["notification_level"] >= notification_level:
                line["norm"] = table
                alert(line)


if __name__ == "__main__":
    # 两个命令行参数
    # 第一个为警告类型：one或者mail
    # 第二个为日期，留空取昨天
    main(sys.argv)
