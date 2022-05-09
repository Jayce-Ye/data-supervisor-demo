/*
 Navicat Premium Data Transfer

 Source Server         : node-etl-01
 Source Server Type    : MySQL
 Source Server Version : 50736
 Source Host           : 192.168.32.128:3306
 Source Schema         : data_supervisor

 Target Server Type    : MySQL
 Target Server Version : 50736
 File Encoding         : 65001

 Date: 09/05/2022 16:58:43
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for day_on_day
-- ----------------------------
DROP TABLE IF EXISTS `day_on_day`;
CREATE TABLE `day_on_day`  (
  `dt` date NOT NULL COMMENT '日期',
  `tbl` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '表名',
  `value` double NULL DEFAULT NULL COMMENT '环比增长百分比',
  `value_min` double NULL DEFAULT NULL COMMENT '增长上限',
  `value_max` double NULL DEFAULT NULL COMMENT '增长上限',
  `notification_level` int(11) NULL DEFAULT NULL COMMENT '警告级别',
  PRIMARY KEY (`dt`, `tbl`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '环比增长指标表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of day_on_day
-- ----------------------------

-- ----------------------------
-- Table structure for duplicate
-- ----------------------------
DROP TABLE IF EXISTS `duplicate`;
CREATE TABLE `duplicate`  (
  `dt` date NOT NULL COMMENT '日期',
  `tbl` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '表名',
  `col` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '列名',
  `value` int(11) NULL DEFAULT NULL COMMENT '重复值个数',
  `value_min` int(11) NULL DEFAULT NULL COMMENT '下限',
  `value_max` int(11) NULL DEFAULT NULL COMMENT '上限',
  `notification_level` int(11) NULL DEFAULT NULL COMMENT '警告级别',
  PRIMARY KEY (`dt`, `tbl`, `col`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '重复值指标表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of duplicate
-- ----------------------------

-- ----------------------------
-- Table structure for null_id
-- ----------------------------
DROP TABLE IF EXISTS `null_id`;
CREATE TABLE `null_id`  (
  `dt` date NOT NULL COMMENT '日期',
  `tbl` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '表名',
  `col` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '列名',
  `value` int(11) NULL DEFAULT NULL COMMENT '空ID个数',
  `value_min` int(11) NULL DEFAULT NULL COMMENT '下限',
  `value_max` int(11) NULL DEFAULT NULL COMMENT '上限',
  `notification_level` int(11) NULL DEFAULT NULL COMMENT '警告级别',
  PRIMARY KEY (`dt`, `tbl`, `col`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '空值指标表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of null_id
-- ----------------------------

-- ----------------------------
-- Table structure for rng
-- ----------------------------
DROP TABLE IF EXISTS `rng`;
CREATE TABLE `rng`  (
  `dt` date NOT NULL COMMENT '日期',
  `tbl` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '表名',
  `col` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '列名',
  `value` int(11) NULL DEFAULT NULL COMMENT '超出预定值域个数',
  `range_min` int(11) NULL DEFAULT NULL COMMENT '值域下限',
  `range_max` int(11) NULL DEFAULT NULL COMMENT '值域上限',
  `value_min` int(11) NULL DEFAULT NULL COMMENT '下限',
  `value_max` int(11) NULL DEFAULT NULL COMMENT '上限',
  `notification_level` int(11) NULL DEFAULT NULL COMMENT '警告级别',
  PRIMARY KEY (`dt`, `tbl`, `col`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '值域指标表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rng
-- ----------------------------

-- ----------------------------
-- Table structure for week_on_week
-- ----------------------------
DROP TABLE IF EXISTS `week_on_week`;
CREATE TABLE `week_on_week`  (
  `dt` date NOT NULL COMMENT '日期',
  `tbl` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '表名',
  `value` double NULL DEFAULT NULL COMMENT '同比增长百分比',
  `value_min` double NULL DEFAULT NULL COMMENT '增长上限',
  `value_max` double NULL DEFAULT NULL COMMENT '增长上限',
  `notification_level` int(11) NULL DEFAULT NULL COMMENT '警告级别',
  PRIMARY KEY (`dt`, `tbl`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '同比增长指标表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of week_on_week
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
