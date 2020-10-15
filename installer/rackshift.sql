/*
Navicat MySQL Data Transfer

Source Server         : 192.168.2.13
Source Server Version : 50731
Source Host           : 192.168.2.13:3306
Source Database       : rackshift

Target Server Type    : MYSQL
Target Server Version : 50731
File Encoding         : 65001

Date: 2020-09-25 22:22:08
*/
CREATE DATABASE rackshift;
USE rackshift;

set character_set_client = utf8;
set character_set_server = utf8;
set character_set_connection = utf8;
set character_set_database = utf8;
set character_set_results = utf8;
set collation_connection = utf8_general_ci;
set collation_database = utf8_general_ci;
set collation_server = utf8_general_ci;


SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `bare_metal`
-- ----------------------------
DROP TABLE IF EXISTS `bare_metal`;
CREATE TABLE `bare_metal` (
  `id` varchar(64) NOT NULL,
  `endpoint_id` varchar(50) NOT NULL DEFAULT '' COMMENT 'enpoint id',
  `hostname` varchar(50) NOT NULL DEFAULT '' COMMENT '物理机hostname',
  `machine_type` varchar(64) DEFAULT NULL COMMENT '裸金属种类，compute，pdu...',
  `cpu` int(8) DEFAULT NULL COMMENT '几颗cpu',
  `cpu_type` varchar(45) DEFAULT NULL COMMENT 'cpu型号',
  `cpu_fre` varchar(10) NOT NULL DEFAULT '' COMMENT 'CPU频率',
  `core` int(11) NOT NULL DEFAULT '1' COMMENT '一个cpu的核心数',
  `thread` int(11) NOT NULL DEFAULT '1' COMMENT '一个cpu的核心的线程数',
  `memory` int(8) DEFAULT NULL COMMENT '内存总容量GB',
  `memory_type` varchar(45) DEFAULT NULL COMMENT '内存种类',
  `disk_type` varchar(45) DEFAULT NULL COMMENT '磁盘种类',
  `disk` int(8) DEFAULT NULL COMMENT '磁盘总容量GB',
  `management_ip` varchar(15) DEFAULT NULL COMMENT '带外管理地址',
  `bmc_mac` varchar(20) DEFAULT NULL COMMENT 'bmc网卡mac地址',
  `ip_array` varchar(500) DEFAULT NULL COMMENT '业务ip地址',
  `os_type` varchar(128) DEFAULT NULL COMMENT ' os',
  `os_version` varchar(50) DEFAULT '' COMMENT 'os版本',
  `machine_brand` varchar(64) DEFAULT NULL COMMENT '机器品牌',
  `machine_model` varchar(45) DEFAULT NULL COMMENT '机器型号',
  `server_id` varchar(64) DEFAULT NULL COMMENT '对应rackhdid',
  `machine_sn` varchar(64) DEFAULT NULL COMMENT '序列号',
  `status` varchar(20) DEFAULT NULL COMMENT '状态',
  `power` varchar(10) NOT NULL DEFAULT 'on' COMMENT '开关机状态',
  `workspace_id` varchar(64) DEFAULT NULL,
  `recycled_time` bigint(20) DEFAULT '0',
  `ssh_user` varchar(50) DEFAULT NULL,
  `ssh_pwd` varchar(100) DEFAULT NULL,
  `ssh_port` int(10) DEFAULT '22',
  `provider_id` varchar(64) DEFAULT NULL,
  `rule_id` varchar(64) NOT NULL,
  `apply_user` varchar(50) DEFAULT '' COMMENT '申请人',
  `create_time` bigint(20) DEFAULT NULL,
  `update_time` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bare_metal_management_ip_index` (`management_ip`) USING BTREE,
  KEY `bare_metal_provider_id_index` (`provider_id`) USING BTREE,
  KEY `bare_metal_rule_id_index` (`rule_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of bare_metal
-- ----------------------------
INSERT INTO `bare_metal` VALUES ('dbde4e6d-c489-47fc-800e-e1a57d734895', 'd2d64a00-e106-462f-9222-cc0284df3ccb', '', null, '2', 'Intel(R) Xeon(R) CPU E5-2609 v4 @ 1.70GHz', '1700 MHz', '8', '8', '16', '<OUT OF SPEC>', null, '2400', '192.168.1.250', '6c:92:bf:b4:85:0d', null, null, '', 'Inspur', 'Inspur NF5280M4', '5f6b68ff92113201000923de', '400005018', 'ready', 'unknown', 'root', '0', null, null, '22', 'rackhd', 'rackhd', '', '1600906554502', '1600906554502');

-- ----------------------------
-- Table structure for `bare_metal_rule`
-- ----------------------------
DROP TABLE IF EXISTS `bare_metal_rule`;
CREATE TABLE `bare_metal_rule` (
  `id` varchar(64) COLLATE utf8_bin NOT NULL,
  `name` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `start_ip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `end_ip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `mask` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `provider_id` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `credential_param` longtext COLLATE utf8_bin,
  `sync_status` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT 'PENDING',
  `last_sync_timestamp` bigint(20) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `bare_metal_ip_sync_status_index` (`sync_status`) USING BTREE,
  KEY `bare_metal_ip_start_ip_index` (`start_ip`) USING BTREE,
  KEY `bare_metal_ip_end_ip_index` (`end_ip`) USING BTREE,
  KEY `bare_metal_rule_provider_id_index` (`provider_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- ----------------------------
-- Records of bare_metal_rule
-- ----------------------------

-- ----------------------------
-- Table structure for `cpu`
-- ----------------------------
DROP TABLE IF EXISTS `cpu`;
CREATE TABLE `cpu` (
  `id` varchar(50) NOT NULL,
  `bare_metal_id` varchar(50) NOT NULL DEFAULT '' COMMENT '物理机id',
  `proc_name` varchar(200) NOT NULL DEFAULT '' COMMENT 'cpu型号',
  `proc_socket` varchar(20) NOT NULL DEFAULT '1' COMMENT '插槽号',
  `proc_status` varchar(20) DEFAULT 'OP_STATUS_OK' COMMENT '状态',
  `proc_speed` varchar(200) DEFAULT '' COMMENT '主频',
  `proc_num_cores_enabled` varchar(200) DEFAULT '' COMMENT '开启的核心数',
  `proc_num_cores` varchar(200) DEFAULT '' COMMENT '核心数',
  `proc_num_threads` varchar(200) DEFAULT '' COMMENT '线程数',
  `proc_mem_technology` varchar(20) NOT NULL DEFAULT '64-bit Capable' COMMENT '全部线程数',
  `proc_num_l1cache` varchar(20) DEFAULT '' COMMENT '1级缓存大小 kb',
  `proc_num_l2cache` varchar(20) DEFAULT '' COMMENT '2级缓存大小 kb',
  `proc_num_l3cache` varchar(20) DEFAULT '' COMMENT '3级缓存大小 kb',
  `sync_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '同步时间',
  `sn` varchar(50) DEFAULT '' COMMENT '序列号',
  `status` tinyint(4) DEFAULT '0' COMMENT '硬件状态:0 存量，1 新增， 2 删除',
  PRIMARY KEY (`id`),
  KEY `bare_metal_id` (`bare_metal_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of cpu
-- ----------------------------
INSERT INTO `cpu` VALUES ('1048cd22-8e87-47fe-bbd1-bef102018fc3', 'dbde4e6d-c489-47fc-800e-e1a57d734895', 'Intel(R) Xeon(R) CPU E5-2609 v4 @ 1.70GHz', 'SOCKET0', 'OP_STATUS_OK', '1700', '8', '8', '8', '64-bit Capable', '', '', '', '1600906554550', '', '0');
INSERT INTO `cpu` VALUES ('1c17c90a-9c28-42ed-a4fd-8f5b4bfe36b3', '88ddee5e-666b-4935-a026-bc9a07aea5ad', 'Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz', '2', 'OP_STATUS_OK', '2400', '6', '6', '12', '64-bit Capable', '', '', '', '1600325989330', '', '0');
INSERT INTO `cpu` VALUES ('28e3746c-6157-4367-bd29-f9a49148b334', '4d6923ce-9b86-4076-a179-b4d73863701b', 'Intel(R) Xeon(R) CPU E5-2620 v2 @ 2.10GHz', '1', 'OP_STATUS_OK', '2100', '6', '6', '12', '64-bit Capable', '', '', '', '1600913075555', '', '0');
INSERT INTO `cpu` VALUES ('4c5c0182-38b2-4c8b-9399-cea595766b4d', '88ddee5e-666b-4935-a026-bc9a07aea5ad', 'Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz', '1', 'OP_STATUS_OK', '2400', '6', '6', '12', '64-bit Capable', '', '', '', '1600325989330', '', '0');
INSERT INTO `cpu` VALUES ('55e33b43-3d56-45d4-9137-c2191a7f4773', '6f655753-c192-453f-a2ec-1d3e132450fa', 'Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz', '2', 'OP_STATUS_OK', '2400', '6', '6', '12', '64-bit Capable', '', '', '', '1600325989301', '', '0');
INSERT INTO `cpu` VALUES ('62cb7198-e6c7-409b-be4d-dfe17361ee3a', '4d6923ce-9b86-4076-a179-b4d73863701b', 'Intel(R) Xeon(R) CPU E5-2620 v2 @ 2.10GHz', '2', 'OP_STATUS_OK', '2100', '6', '6', '12', '64-bit Capable', '', '', '', '1600913075555', '', '0');
INSERT INTO `cpu` VALUES ('6bc6e659-8c67-414e-b9fe-57d183a2a358', '6f655753-c192-453f-a2ec-1d3e132450fa', 'Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz', '1', 'OP_STATUS_OK', '2400', '6', '6', '12', '64-bit Capable', '', '', '', '1600325989301', '', '0');
INSERT INTO `cpu` VALUES ('6e34fb44-f86a-41ca-b852-37e5895a9bcd', '766540f9-da9f-4ad5-89e8-3757b88f55fe', 'Intel(R) Xeon(R) CPU E5-2609 v4 @ 1.70GHz', 'SOCKET0', 'OP_STATUS_OK', '1700', '8', '8', '8', '64-bit Capable', '', '', '', '1600325989362', '', '0');
INSERT INTO `cpu` VALUES ('72ceb6c6-e907-439a-8b82-b4537b6e1b5f', 'dc685422-f495-466d-a453-1f9ce25efd23', 'Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz', '1', 'OP_STATUS_OK', '2400', '6', '6', '12', '64-bit Capable', '', '', '', '1600913075617', '', '0');
INSERT INTO `cpu` VALUES ('77c9100f-e8ac-44be-8db8-1c95b2ca10f1', 'dc685422-f495-466d-a453-1f9ce25efd23', 'Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz', '2', 'OP_STATUS_OK', '2400', '6', '6', '12', '64-bit Capable', '', '', '', '1600913075617', '', '0');
INSERT INTO `cpu` VALUES ('79ec4ea6-cb68-4796-942d-25ce481cbf76', '999961d8-efaf-44fe-b007-317b8650e28f', 'Intel(R) Xeon(R) CPU E5-2609 v4 @ 1.70GHz', 'SOCKET0', 'OP_STATUS_OK', '1700', '8', '8', '8', '64-bit Capable', '', '', '', '1599577724420', '', '0');
INSERT INTO `cpu` VALUES ('8434c81c-9b16-4073-befa-8283408de267', '518dff15-4adc-4586-8f28-b33a6c27d7d7', 'Intel(R) Xeon(R) CPU E5-2620 v2 @ 2.10GHz', '2', 'OP_STATUS_OK', '2100', '6', '6', '12', '64-bit Capable', '', '', '', '1600325989268', '', '0');
INSERT INTO `cpu` VALUES ('85123490-f31e-4ee8-9ee3-321a79d86d9d', '21709c84-eb20-4873-a7ff-6a94f2959750', 'Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz', '1', 'OP_STATUS_OK', '2400', '6', '6', '12', '64-bit Capable', '', '', '', '1600913075587', '', '0');
INSERT INTO `cpu` VALUES ('9d0d7723-6949-4b7d-aca5-c6e67bdf6dab', '21709c84-eb20-4873-a7ff-6a94f2959750', 'Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz', '2', 'OP_STATUS_OK', '2400', '6', '6', '12', '64-bit Capable', '', '', '', '1600913075587', '', '0');
INSERT INTO `cpu` VALUES ('aaca927d-e54a-4dbd-bc63-b841e07b72a9', '518dff15-4adc-4586-8f28-b33a6c27d7d7', 'Intel(R) Xeon(R) CPU E5-2620 v2 @ 2.10GHz', '1', 'OP_STATUS_OK', '2100', '6', '6', '12', '64-bit Capable', '', '', '', '1600325989268', '', '0');
INSERT INTO `cpu` VALUES ('fa827dfb-8a55-4643-84b8-5184f76a0c84', '1df66ab3-e959-4d04-af4d-3887817430f3', 'Intel(R) Xeon(R) CPU E5-2609 v4 @ 1.70GHz', 'SOCKET0', 'OP_STATUS_OK', '1700', '8', '8', '8', '64-bit Capable', '', '', '', '1600913075643', '', '0');

-- ----------------------------
-- Table structure for `disk`
-- ----------------------------
DROP TABLE IF EXISTS `disk`;
CREATE TABLE `disk` (
  `id` varchar(50) NOT NULL,
  `bare_metal_id` varchar(50) NOT NULL DEFAULT '' COMMENT '物理机id',
  `enclosure_id` int(11) NOT NULL DEFAULT '0' COMMENT '用于组raid的enclosure_id，需要使用perccli或者storcli工具去获取,raid使用',
  `controller_id` int(11) NOT NULL DEFAULT '0' COMMENT '磁盘控制器id，一般是0，如果有多块raid卡数值可能不一样,raid使用',
  `drive` varchar(200) DEFAULT '' COMMENT '插槽',
  `type` char(10) NOT NULL DEFAULT 'SAS' COMMENT ' 磁盘类型',
  `size` varchar(10) NOT NULL DEFAULT '' COMMENT '磁盘容量（GB）',
  `raid` varchar(20) DEFAULT '' COMMENT 'raid类型',
  `virtual_disk` varchar(100) DEFAULT NULL COMMENT '虚拟磁盘',
  `manufactor` varchar(20) DEFAULT '' COMMENT '制造商',
  `sync_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '同步时间',
  `sn` varchar(50) DEFAULT '' COMMENT '磁盘序列号',
  `model` varchar(50) DEFAULT '' COMMENT '磁盘型号',
  `status` tinyint(4) DEFAULT '0' COMMENT '硬件状态:0 存量，1 新增， 2 删除',
  PRIMARY KEY (`id`),
  KEY `bare_metal_id` (`bare_metal_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of disk
-- ----------------------------
INSERT INTO `disk` VALUES ('012f6433-2c64-4198-aad5-1ace9063f9fc', '1df66ab3-e959-4d04-af4d-3887817430f3', '0', '1', '1', 'HDD', '600 GB', '', null, 'SEAGATE', '1600913075643', '', '', '0');
INSERT INTO `disk` VALUES ('07e83d3e-bfdb-4e00-9c2a-4f1798fedbe1', '1df66ab3-e959-4d04-af4d-3887817430f3', '0', '1', '3', 'HDD', '600 GB', '', null, 'SEAGATE', '1600913075643', '', '', '0');
INSERT INTO `disk` VALUES ('1252beab-1f21-40f3-8728-76d4d07e85c9', 'dc685422-f495-466d-a453-1f9ce25efd23', '32', '0', '1', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600913075617', '', '', '0');
INSERT INTO `disk` VALUES ('15820370-7b3d-4aac-a2ad-2e356eb68132', 'dc685422-f495-466d-a453-1f9ce25efd23', '32', '0', '3', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600913075617', '', '', '0');
INSERT INTO `disk` VALUES ('1a1495f0-0d26-47da-a77d-6132c1ef5311', 'dbde4e6d-c489-47fc-800e-e1a57d734895', '0', '1', '0', 'HDD', '600 GB', '10', null, 'SEAGATE', '1600906554550', '', '', '0');
INSERT INTO `disk` VALUES ('265c8dde-3e51-47d1-bce7-c172fef4e9c1', '766540f9-da9f-4ad5-89e8-3757b88f55fe', '0', '1', '1', 'HDD', '600 GB', '', null, 'SEAGATE', '1600325989362', '', '', '0');
INSERT INTO `disk` VALUES ('334f42c4-aab0-46d3-aa57-aabd1653688d', '4d6923ce-9b86-4076-a179-b4d73863701b', '32', '0', '3', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600913075555', '', '', '0');
INSERT INTO `disk` VALUES ('3c031041-9f0b-4daa-bd8f-ff499020bc21', 'dc685422-f495-466d-a453-1f9ce25efd23', '32', '0', '0', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600913075617', '', '', '0');
INSERT INTO `disk` VALUES ('3ee13492-9ab0-4028-9bc1-6a42c7ed51d0', '1df66ab3-e959-4d04-af4d-3887817430f3', '0', '1', '0', 'HDD', '600 GB', '', null, 'SEAGATE', '1600913075643', '', '', '0');
INSERT INTO `disk` VALUES ('40d4dbc2-ff78-440f-932c-ee9a45417579', '4d6923ce-9b86-4076-a179-b4d73863701b', '32', '0', '1', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600913075555', '', '', '0');
INSERT INTO `disk` VALUES ('5201c0d5-4b9d-4f72-85f5-a479dbcfa390', '21709c84-eb20-4873-a7ff-6a94f2959750', '0', '0', '1I:3:3', 'SAS', '500 GB', '0', null, '', '1600913075587', '9XF1S7FZ00009302YSCV', 'SEAGATE ST9500620SS', '0');
INSERT INTO `disk` VALUES ('5f6bd36e-3383-4145-b720-c0ba99f5b3b2', '518dff15-4adc-4586-8f28-b33a6c27d7d7', '32', '0', '1', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600325989268', '', '', '0');
INSERT INTO `disk` VALUES ('623d2bfa-59b0-49af-8cba-a3828acb5d53', '21709c84-eb20-4873-a7ff-6a94f2959750', '0', '0', '1I:3:2', 'SAS', '500 GB', '1', null, '', '1600913075587', '9XF20P2000009317H6K3', 'SEAGATE ST9500620SS', '0');
INSERT INTO `disk` VALUES ('655d67a7-fb0a-4a79-b8ea-6aabf8c88635', '999961d8-efaf-44fe-b007-317b8650e28f', '0', '1', '3', 'HDD', '600 GB', '', null, 'SEAGATE', '1599577724420', '', '', '0');
INSERT INTO `disk` VALUES ('6616db5a-0d52-413a-96d5-61525284e078', '4d6923ce-9b86-4076-a179-b4d73863701b', '32', '0', '0', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600913075555', '', '', '0');
INSERT INTO `disk` VALUES ('67d715a5-2a3f-438b-b9c0-259eba592c39', '88ddee5e-666b-4935-a026-bc9a07aea5ad', '32', '0', '0', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600325989330', '', '', '0');
INSERT INTO `disk` VALUES ('69d921ce-7f5f-4d39-931d-ce03eeb12b4c', '1df66ab3-e959-4d04-af4d-3887817430f3', '0', '1', '2', 'HDD', '600 GB', '', null, 'SEAGATE', '1600913075643', '', '', '0');
INSERT INTO `disk` VALUES ('73586954-fe6b-4e85-a474-69904b7e6079', 'dc685422-f495-466d-a453-1f9ce25efd23', '32', '0', '2', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600913075617', '', '', '0');
INSERT INTO `disk` VALUES ('83ec3f3b-be76-4e91-baf5-b50a5d787eec', '88ddee5e-666b-4935-a026-bc9a07aea5ad', '32', '0', '1', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600325989330', '', '', '0');
INSERT INTO `disk` VALUES ('88d6dd2f-5467-4843-82b3-379f9f6096e8', '766540f9-da9f-4ad5-89e8-3757b88f55fe', '0', '1', '0', 'HDD', '600 GB', '', null, 'SEAGATE', '1600325989362', '', '', '0');
INSERT INTO `disk` VALUES ('8c7bdf99-1d6c-4589-8ac6-a83dfa1e319b', '999961d8-efaf-44fe-b007-317b8650e28f', '0', '1', '0', 'HDD', '600 GB', '', null, 'SEAGATE', '1599577724420', '', '', '0');
INSERT INTO `disk` VALUES ('92389929-4d38-4d23-b8e0-9649386047f8', '518dff15-4adc-4586-8f28-b33a6c27d7d7', '32', '0', '0', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600325989268', '', '', '0');
INSERT INTO `disk` VALUES ('955d5cea-3f2e-449e-adca-17469c068aa5', '6f655753-c192-453f-a2ec-1d3e132450fa', '0', '0', '1I:3:4', 'SAS', '500 GB', '', null, '', '1600325989301', '9XF216VE00009315XGPW', 'SEAGATE ST9500620SS', '0');
INSERT INTO `disk` VALUES ('969f6095-616f-40e3-8d74-d08c0f0fbfbf', '4d6923ce-9b86-4076-a179-b4d73863701b', '32', '0', '2', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600913075555', '', '', '0');
INSERT INTO `disk` VALUES ('a3d8d24c-2b99-4748-948d-75d8437e59d7', '766540f9-da9f-4ad5-89e8-3757b88f55fe', '0', '1', '2', 'HDD', '600 GB', '', null, 'SEAGATE', '1600325989362', '', '', '0');
INSERT INTO `disk` VALUES ('ba23fc18-c70c-4b0e-a8d9-00cf0d449972', '518dff15-4adc-4586-8f28-b33a6c27d7d7', '32', '0', '3', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600325989268', '', '', '0');
INSERT INTO `disk` VALUES ('c75e8131-d976-4c8c-91ac-b28f88f54dce', 'dbde4e6d-c489-47fc-800e-e1a57d734895', '0', '1', '1', 'HDD', '600 GB', '10', null, 'SEAGATE', '1600906554550', '', '', '0');
INSERT INTO `disk` VALUES ('ca2d35d3-4b55-4c68-8d86-4397d782f366', '6f655753-c192-453f-a2ec-1d3e132450fa', '0', '0', '1I:3:3', 'SAS', '500 GB', '0', null, '', '1600325989301', '9XF1S7FZ00009302YSCV', 'SEAGATE ST9500620SS', '0');
INSERT INTO `disk` VALUES ('d0f76443-bcc5-4db3-9078-20c9696e8da0', '88ddee5e-666b-4935-a026-bc9a07aea5ad', '32', '0', '2', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600325989330', '', '', '0');
INSERT INTO `disk` VALUES ('d100f5b3-43b2-40b8-bb41-3db35f8e19d0', '6f655753-c192-453f-a2ec-1d3e132450fa', '0', '0', '1I:3:1', 'SAS', '500 GB', '1', null, '', '1600325989301', '9XF1VD5X00009308P8LZ', 'SEAGATE ST9500620SS', '0');
INSERT INTO `disk` VALUES ('d7f96df8-47f8-49fa-9fd4-ae90a3982e0f', '21709c84-eb20-4873-a7ff-6a94f2959750', '0', '0', '1I:3:4', 'SAS', '500 GB', '', null, '', '1600913075587', '9XF216VE00009315XGPW', 'SEAGATE ST9500620SS', '0');
INSERT INTO `disk` VALUES ('da53ed83-18fa-479e-b551-4a90319472ec', 'dbde4e6d-c489-47fc-800e-e1a57d734895', '0', '1', '3', 'HDD', '600 GB', '10', null, 'SEAGATE', '1600906554550', '', '', '0');
INSERT INTO `disk` VALUES ('dbc59e13-e285-4b10-9a60-105c7f0d6efa', '88ddee5e-666b-4935-a026-bc9a07aea5ad', '32', '0', '3', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600325989330', '', '', '0');
INSERT INTO `disk` VALUES ('dc9a6502-9f1e-4fd3-92fe-6346128444ee', '21709c84-eb20-4873-a7ff-6a94f2959750', '0', '0', '1I:3:1', 'SAS', '500 GB', '1', null, '', '1600913075587', '9XF1VD5X00009308P8LZ', 'SEAGATE ST9500620SS', '0');
INSERT INTO `disk` VALUES ('e2f9b394-e21b-4b93-a105-d8c59e75de33', 'dbde4e6d-c489-47fc-800e-e1a57d734895', '0', '1', '2', 'HDD', '600 GB', '10', null, 'SEAGATE', '1600906554550', '', '', '0');
INSERT INTO `disk` VALUES ('e9cd2cf3-34ad-412b-af2a-abd472b8e1ed', '6f655753-c192-453f-a2ec-1d3e132450fa', '0', '0', '1I:3:2', 'SAS', '500 GB', '1', null, '', '1600325989301', '9XF20P2000009317H6K3', 'SEAGATE ST9500620SS', '0');
INSERT INTO `disk` VALUES ('eed49962-f820-4012-8939-cf27fb0aa49d', '999961d8-efaf-44fe-b007-317b8650e28f', '0', '1', '1', 'HDD', '600 GB', '', null, 'SEAGATE', '1599577724420', '', '', '0');
INSERT INTO `disk` VALUES ('f3f30e8f-5b30-4cbd-8e60-610457dd6253', '999961d8-efaf-44fe-b007-317b8650e28f', '0', '1', '2', 'HDD', '600 GB', '', null, 'SEAGATE', '1599577724420', '', '', '0');
INSERT INTO `disk` VALUES ('f4e0fadf-6b29-40e1-b036-784107fbaa50', '766540f9-da9f-4ad5-89e8-3757b88f55fe', '0', '1', '3', 'HDD', '600 GB', '', null, 'SEAGATE', '1600325989362', '', '', '0');
INSERT INTO `disk` VALUES ('fb8bb7ca-6400-4e13-b8cb-989c0caeb13d', '518dff15-4adc-4586-8f28-b33a6c27d7d7', '32', '0', '2', 'SAS', '500 GB', 'RAID5', 'VD0', '', '1600325989268', '', '', '0');

-- ----------------------------
-- Table structure for `endpoint`
-- ----------------------------
DROP TABLE IF EXISTS `endpoint`;
CREATE TABLE `endpoint` (
  `id` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '名称',
  `type` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '类型main_endpoint,slave_endpoint',
  `ip` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT 'ip地址',
  `status` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '状态, 1 在线，2 离线',
  `create_time` bigint(13) NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='rackshift端点';

-- ----------------------------
-- Records of endpoint
-- ----------------------------
INSERT INTO `endpoint` VALUES ('d2d64a00-e106-462f-9222-cc0284df3ccb', '主节点', 'main_endpoint', '172.31.128.1', 'Online', '1600906515255');

-- ----------------------------
-- Table structure for `execution_log`
-- ----------------------------
DROP TABLE IF EXISTS `execution_log`;
CREATE TABLE `execution_log` (
  `id` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
  `user` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '用户名',
  `status` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '状态',
  `create_time` bigint(13) NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='执行日志';

-- ----------------------------
-- Records of execution_log
-- ----------------------------

-- ----------------------------
-- Table structure for `execution_log_details`
-- ----------------------------
DROP TABLE IF EXISTS `execution_log_details`;
CREATE TABLE `execution_log_details` (
  `id` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
  `user` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '用户名',
  `operation` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '操作',
  `log_id` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '外键id',
  `bare_metal_id` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '裸金属id',
  `out_put` mediumtext CHARACTER SET utf8mb4 COMMENT '输出',
  `status` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '状态',
  `create_time` bigint(13) NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='执行日志详情';

-- ----------------------------
-- Records of execution_log_details
-- ----------------------------
INSERT INTO `execution_log_details` VALUES ('23d27fa0-ac45-44b1-8550-d43f79aa4137', 'admin', 'ERROR', 'b2414416-ef0a-49d9-ae65-ba827f04af95', '518dff15-4adc-4586-8f28-b33a6c27d7d7', '错误：event:下发安装系统workflow:worflow:Graph.InstallCentOS,参数:{\"options\":{\"defaults\":{\"version\":\"7\",\"rootPassword\":\"RackShift\",\"hostname\":\"rackshift-node\",\"networkDevices\":[{\"ipv4\":{\"ipAddr\":\"192.168.1.10\",\"gateway\":\"192.168.1.1\",\"netmask\":\"255.255.255.0\"}}],\"installDisk\":\"/dev/sda\",\"installPartitions\":[{\"mountPoint\":\"/\",\"size\":\"auto\",\"fsType\":\"ext3\"},{\"mountPoint\":\"swap\",\"size\":\"4096\",\"fsType\":\"swap\"},{\"mountPoint\":\"/boot\",\"size\":\"4096\",\"fsType\":\"ext3\"},{\"mountPoint\":\"biosboot\",\"size\":\"1\",\"fsType\":\"biosboot\"}]}}},回滚状态至ready', '', '1600856655700');
INSERT INTO `execution_log_details` VALUES ('42a83b2f-4740-4b50-8d58-e73627dca4e3', 'admin', 'ERROR', '87f1ed72-2645-47fb-a07c-993dd9be9ae7', '518dff15-4adc-4586-8f28-b33a6c27d7d7', '错误：Exception:\njava.lang.RuntimeException: HttpClient查询失败:HttpClient查询失败,fileName:RackHDHttpClientUtil.java,className:io.rackshift.utils.RackHDHttpClientUtil,methodName:post,lineNumber:149\n,fileName:RackHDHttpClientUtil.java,className:io.rackshift.utils.RackHDHttpClientUtil,methodName:post,lineNumber:167\n,fileName:RackHDService.java,className:io.rackshift.service.RackHDService,methodName:postWorkflow,lineNumber:722\n,fileName:OsWorkflowStartHandler.java,className:io.rackshift.strategy.statemachine.handler.OsWorkflowStartHandler,methodName:handleYourself,lineNumber:44\n,fileName:AbstractHandler.java,className:io.rackshift.strategy.statemachine.AbstractHandler,methodName:handle,lineNumber:83\n,fileName:WorkflowTask.java,className:io.rackshift.job.WorkflowTask,methodName:run,lineNumber:47\n', '', '1600856611785');
INSERT INTO `execution_log_details` VALUES ('511d362a-e3d1-4fa6-b1a3-4a251f5f4283', 'admin', 'ERROR', '87f1ed72-2645-47fb-a07c-993dd9be9ae7', '518dff15-4adc-4586-8f28-b33a6c27d7d7', '错误：event:下发安装系统workflow:worflow:Graph.InstallCentOS,参数:{\"options\":{\"defaults\":{\"version\":\"7\",\"rootPassword\":\"RackShift\",\"hostname\":\"rackshift-node\",\"networkDevices\":[{\"ipv4\":{\"ipAddr\":\"192.168.1.10\",\"gateway\":\"192.168.1.1\",\"netmask\":\"255.255.255.0\"}}],\"installDisk\":\"/dev/sda\",\"installPartitions\":[{\"mountPoint\":\"/\",\"size\":\"auto\",\"fsType\":\"ext3\"},{\"mountPoint\":\"swap\",\"size\":\"4096\",\"fsType\":\"swap\"},{\"mountPoint\":\"/boot\",\"size\":\"4096\",\"fsType\":\"ext3\"},{\"mountPoint\":\"biosboot\",\"size\":\"1\",\"fsType\":\"biosboot\"}]}}},回滚状态至ready', '', '1600856616512');
INSERT INTO `execution_log_details` VALUES ('7a870371-225e-445a-adca-1fd4f0d0188a', 'admin', 'START', '876d3dbc-3af0-42ca-b399-60de1c276241', 'dbde4e6d-c489-47fc-800e-e1a57d734895', '执行event:补充OBM信息:worflow:无,参数:{\"outband\":{\"bareMetalId\":\"dbde4e6d-c489-47fc-800e-e1a57d734895\",\"ip\":\"192.168.1.250\",\"pwd\":\"Fit2cloud@2019\",\"userName\":\"admin\"}}', '', '1600902921697');
INSERT INTO `execution_log_details` VALUES ('83d4f5b5-899d-43be-950d-f15bcb031e70', 'admin', 'END', '876d3dbc-3af0-42ca-b399-60de1c276241', 'dbde4e6d-c489-47fc-800e-e1a57d734895', '执行event:补充OBM信息:worflow:无,参数:{\"outband\":{\"bareMetalId\":\"dbde4e6d-c489-47fc-800e-e1a57d734895\",\"id\":\"a82b388f-90c2-44ef-aa7f-2a27352947fe\",\"ip\":\"192.168.1.250\",\"pwd\":\"Fit2cloud@2019\",\"updateTime\":1600902928590,\"userName\":\"admin\"}}', '', '1600902928629');
INSERT INTO `execution_log_details` VALUES ('9c3a546c-6178-4bee-8e4c-184183b0bfd8', 'admin', 'START', 'b2414416-ef0a-49d9-ae65-ba827f04af95', '518dff15-4adc-4586-8f28-b33a6c27d7d7', '执行event:下发安装系统workflow:worflow:Graph.InstallCentOS,参数:{\"options\":{\"defaults\":{\"version\":\"7\",\"rootPassword\":\"RackShift\",\"hostname\":\"rackshift-node\",\"networkDevices\":[{\"ipv4\":{\"ipAddr\":\"192.168.1.10\",\"gateway\":\"192.168.1.1\",\"netmask\":\"255.255.255.0\"}}],\"installDisk\":\"/dev/sda\",\"installPartitions\":[{\"mountPoint\":\"/\",\"size\":\"auto\",\"fsType\":\"ext3\"},{\"mountPoint\":\"swap\",\"size\":\"4096\",\"fsType\":\"swap\"},{\"mountPoint\":\"/boot\",\"size\":\"4096\",\"fsType\":\"ext3\"},{\"mountPoint\":\"biosboot\",\"size\":\"1\",\"fsType\":\"biosboot\"}]}}}', '', '1600856629669');
INSERT INTO `execution_log_details` VALUES ('a732cd53-b90a-47f4-b3fd-fd51ea3176ef', 'admin', 'START', '87f1ed72-2645-47fb-a07c-993dd9be9ae7', '518dff15-4adc-4586-8f28-b33a6c27d7d7', '执行event:下发安装系统workflow:worflow:Graph.InstallCentOS,参数:{\"options\":{\"defaults\":{\"version\":\"7\",\"rootPassword\":\"RackShift\",\"hostname\":\"rackshift-node\",\"networkDevices\":[{\"ipv4\":{\"ipAddr\":\"192.168.1.10\",\"gateway\":\"192.168.1.1\",\"netmask\":\"255.255.255.0\"}}],\"installDisk\":\"/dev/sda\",\"installPartitions\":[{\"mountPoint\":\"/\",\"size\":\"auto\",\"fsType\":\"ext3\"},{\"mountPoint\":\"swap\",\"size\":\"4096\",\"fsType\":\"swap\"},{\"mountPoint\":\"/boot\",\"size\":\"4096\",\"fsType\":\"ext3\"},{\"mountPoint\":\"biosboot\",\"size\":\"1\",\"fsType\":\"biosboot\"}]}}}', '', '1600856590119');
INSERT INTO `execution_log_details` VALUES ('e1943a6d-0c5c-4267-82dc-b0c40e9c30cb', 'admin', 'ERROR', 'b2414416-ef0a-49d9-ae65-ba827f04af95', '518dff15-4adc-4586-8f28-b33a6c27d7d7', '错误：Exception:\njava.lang.RuntimeException: HttpClient查询失败:HttpClient查询失败,fileName:RackHDHttpClientUtil.java,className:io.rackshift.utils.RackHDHttpClientUtil,methodName:post,lineNumber:149\n,fileName:RackHDHttpClientUtil.java,className:io.rackshift.utils.RackHDHttpClientUtil,methodName:post,lineNumber:167\n,fileName:RackHDService.java,className:io.rackshift.service.RackHDService,methodName:postWorkflow,lineNumber:722\n,fileName:OsWorkflowStartHandler.java,className:io.rackshift.strategy.statemachine.handler.OsWorkflowStartHandler,methodName:handleYourself,lineNumber:44\n,fileName:AbstractHandler.java,className:io.rackshift.strategy.statemachine.AbstractHandler,methodName:handle,lineNumber:83\n,fileName:WorkflowTask.java,className:io.rackshift.job.WorkflowTask,methodName:run,lineNumber:47\n', '', '1600856655698');

-- ----------------------------
-- Table structure for `image`
-- ----------------------------
DROP TABLE IF EXISTS `image`;
CREATE TABLE `image` (
  `id` varchar(50) NOT NULL,
  `endpoint_id` varchar(50) NOT NULL DEFAULT '' COMMENT 'enpoint id',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '镜像名称',
  `os` varchar(50) DEFAULT NULL COMMENT '操作系统',
  `os_version` varchar(50) DEFAULT NULL COMMENT '操作系统版本',
  `url` varchar(250) DEFAULT NULL COMMENT 'url',
  `original_name` varchar(250) DEFAULT NULL COMMENT '文件原名',
  `file_path` varchar(250) DEFAULT NULL COMMENT '上传后存在的绝对路径',
  `mount_path` varchar(250) DEFAULT NULL COMMENT '挂载的绝对路径',
  `ext_properties` longtext COMMENT '其他属性',
  `update_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '同步时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of image
-- ----------------------------

-- ----------------------------
-- Table structure for `ip`
-- ----------------------------
DROP TABLE IF EXISTS `ip`;
CREATE TABLE `ip` (
  `id` varchar(50) NOT NULL,
  `ip` varchar(36) NOT NULL DEFAULT '' COMMENT 'IP地址',
  `mask` varchar(45) DEFAULT NULL COMMENT '子网掩码',
  `gateway` varchar(45) DEFAULT NULL COMMENT '网关',
  `dns1` varchar(45) DEFAULT NULL COMMENT 'DNS1',
  `dns2` varchar(45) DEFAULT NULL COMMENT 'DNS2',
  `region` varchar(45) DEFAULT NULL COMMENT '区域',
  `network_id` varchar(50) NOT NULL DEFAULT '' COMMENT '网络ID',
  `resource_type` varchar(45) DEFAULT NULL COMMENT '资源类型',
  `resource_id` varchar(45) DEFAULT NULL COMMENT '资源ID',
  `order_item_id` varchar(50) DEFAULT NULL COMMENT '订单项ID',
  `status` varchar(45) NOT NULL DEFAULT 'available' COMMENT '状态',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNQ_PID_IP` (`ip`,`network_id`) USING BTREE,
  KEY `IDX_PID` (`network_id`) USING BTREE,
  KEY `IDX_IP` (`ip`) USING BTREE,
  KEY `IDX_RID` (`resource_id`) USING BTREE,
  KEY `IDX_RTYPE` (`resource_type`) USING BTREE,
  KEY `IDX_STATUE` (`status`) USING BTREE,
  KEY `IDX_OID` (`order_item_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物理机ip';

-- ----------------------------
-- Records of ip
-- ----------------------------

-- ----------------------------
-- Table structure for `memory`
-- ----------------------------
DROP TABLE IF EXISTS `memory`;
CREATE TABLE `memory` (
  `id` varchar(50) NOT NULL,
  `bare_metal_id` varchar(50) NOT NULL DEFAULT '' COMMENT '物理机id',
  `mem_cpu_num` varchar(200) DEFAULT '' COMMENT '对应的cpu号',
  `mem_mod_num` varchar(200) DEFAULT '' COMMENT '插槽号 与CPU一起构成唯一主键 mem_cpu_num:mem_mod_num',
  `mem_mod_size` varchar(20) NOT NULL DEFAULT '' COMMENT '容量',
  `mem_mod_type` varchar(200) DEFAULT '' COMMENT '类型',
  `mem_mod_frequency` varchar(200) DEFAULT '' COMMENT '频率',
  `mem_mod_part_num` varchar(200) DEFAULT '' COMMENT '型号',
  `mem_mod_min_volt` varchar(200) DEFAULT '' COMMENT '最低电压',
  `sn` varchar(50) DEFAULT '' COMMENT '序列号',
  `sync_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '同步时间',
  `status` tinyint(4) DEFAULT '0' COMMENT '硬件状态:0 存量，1 新增， 2 删除',
  PRIMARY KEY (`id`),
  KEY `bare_metal_id` (`bare_metal_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of memory
-- ----------------------------
INSERT INTO `memory` VALUES ('0464a0fb-d6c8-47b9-8412-85c89c86f1db', '999961d8-efaf-44fe-b007-317b8650e28f', '', '', '16', '<OUT OF SPEC>', '2400 ', 'HMA82GR7AFR4N-UH', '1.200', '2A89FDB2', '1599577724420', '0');
INSERT INTO `memory` VALUES ('17a75791-c6ae-445b-b2c8-104685ff3899', '21709c84-eb20-4873-a7ff-6a94f2959750', '1', '12', '16', '<OUT OF SPEC>', '2133 ', 'NOT AVAILABLE', '1.200', 'Not Specified', '1600913075587', '0');
INSERT INTO `memory` VALUES ('1aaa887f-f971-486f-b95e-2b39c829658f', 'dc685422-f495-466d-a453-1f9ce25efd23', '', '', '16', '<OUT OF SPEC>', '2133 ', '36ASF2G72PZ-2G1A2', '1.200', '10487718', '1600913075617', '0');
INSERT INTO `memory` VALUES ('1ed076f5-ecd2-4463-8cc2-82d8d797b05a', '518dff15-4adc-4586-8f28-b33a6c27d7d7', '', '', '8', 'DDR3', '1333 ', 'M393B1K70DH0-YH9', '', '83A9C71A', '1600325989268', '0');
INSERT INTO `memory` VALUES ('2014c986-ce6c-4ad2-98d2-51ffa1b145e5', 'dbde4e6d-c489-47fc-800e-e1a57d734895', '', '', '16', '<OUT OF SPEC>', '2400 ', 'HMA82GR7AFR4N-UH', '1.200', '2A89FDB2', '1600906554550', '0');
INSERT INTO `memory` VALUES ('308073fb-1ce3-4ef9-aac0-3c8f2249ead6', '88ddee5e-666b-4935-a026-bc9a07aea5ad', '', '', '16', '<OUT OF SPEC>', '2133 ', '36ASF2G72PZ-2G1A2', '1.200', '10487718', '1600325989330', '0');
INSERT INTO `memory` VALUES ('4de759aa-7d80-4884-8eee-6ba08c46f3de', '766540f9-da9f-4ad5-89e8-3757b88f55fe', '', '', '16', '<OUT OF SPEC>', '2400 ', 'HMA82GR7AFR4N-UH', '1.200', '2A89FDB2', '1600325989362', '0');
INSERT INTO `memory` VALUES ('673e650e-da83-4044-9be2-7edbed750187', '518dff15-4adc-4586-8f28-b33a6c27d7d7', '', '', '8', 'DDR3', '1333 ', 'M393B1K70DH0-YH9', '', '213CE0BB', '1600325989268', '0');
INSERT INTO `memory` VALUES ('6e987dc5-e77c-474a-817e-c611723913fb', 'dc685422-f495-466d-a453-1f9ce25efd23', '', '', '16', '<OUT OF SPEC>', '2133 ', '36ASF2G72PZ-2G1A2', '1.200', '104D7693', '1600913075617', '0');
INSERT INTO `memory` VALUES ('739cdac8-220e-4c84-8339-1a2b4914cae5', '6f655753-c192-453f-a2ec-1d3e132450fa', '1', '12', '16', '<OUT OF SPEC>', '2133 ', 'NOT AVAILABLE', '1.200', 'Not Specified', '1600325989301', '0');
INSERT INTO `memory` VALUES ('7fcfd36c-a6d0-421a-aee7-84be73d49d0c', '1df66ab3-e959-4d04-af4d-3887817430f3', '', '', '16', '<OUT OF SPEC>', '2400 ', 'HMA82GR7AFR4N-UH', '1.200', '2A89FDB2', '1600913075643', '0');
INSERT INTO `memory` VALUES ('a836c191-48e1-4666-a88d-5f0084a5aca2', '6f655753-c192-453f-a2ec-1d3e132450fa', '2', '12', '16', '<OUT OF SPEC>', '2133 ', 'NOT AVAILABLE', '1.200', 'Not Specified', '1600325989301', '0');
INSERT INTO `memory` VALUES ('ca0e1962-a636-4dc0-83f6-3af1ec6b74e9', '4d6923ce-9b86-4076-a179-b4d73863701b', '', '', '8', 'DDR3', '1333 ', 'M393B1K70DH0-YH9', '', '213CE0BB', '1600913075555', '0');
INSERT INTO `memory` VALUES ('cc4dfc41-a07b-474a-8f30-6f7aef295b60', '21709c84-eb20-4873-a7ff-6a94f2959750', '2', '12', '16', '<OUT OF SPEC>', '2133 ', 'NOT AVAILABLE', '1.200', 'Not Specified', '1600913075587', '0');
INSERT INTO `memory` VALUES ('db66c08d-b166-4379-a4d5-17a5df355c84', '88ddee5e-666b-4935-a026-bc9a07aea5ad', '', '', '16', '<OUT OF SPEC>', '2133 ', '36ASF2G72PZ-2G1A2', '1.200', '104D7693', '1600325989330', '0');
INSERT INTO `memory` VALUES ('ed12f807-4716-4cf5-bfd2-a7d31eca346a', '4d6923ce-9b86-4076-a179-b4d73863701b', '', '', '8', 'DDR3', '1333 ', 'M393B1K70DH0-YH9', '', '83A9C71A', '1600913075555', '0');

-- ----------------------------
-- Table structure for `network`
-- ----------------------------
DROP TABLE IF EXISTS `network`;
CREATE TABLE `network` (
  `id` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
  `endpoint_id` varchar(50) COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT 'enpoint id',
  `name` varchar(45) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '名称',
  `vlan_id` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT 'VLANID',
  `start_ip` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT 'start_ip',
  `end_ip` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT 'end_ip',
  `netmask` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT 'netmask',
  `dhcp_enable` bit(1) DEFAULT b'0' COMMENT '是否开启DHCP',
  `pxe_enable` bit(1) DEFAULT b'0' COMMENT '是否开启PXE',
  `create_time` bigint(13) NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='IP池管理';

-- ----------------------------
-- Records of network
-- ----------------------------

-- ----------------------------
-- Table structure for `network_card`
-- ----------------------------
DROP TABLE IF EXISTS `network_card`;
CREATE TABLE `network_card` (
  `id` varchar(255) NOT NULL COMMENT 'ID',
  `vlan_id` varchar(255) DEFAULT NULL COMMENT 'VlanId',
  `ip` varchar(255) DEFAULT NULL COMMENT 'IP地址',
  `number` varchar(255) DEFAULT NULL COMMENT '编号',
  `bare_metal_id` varchar(255) DEFAULT NULL COMMENT '物理机ID',
  `mac` varchar(255) DEFAULT NULL COMMENT 'mac地址',
  `sync_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '同步时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of network_card
-- ----------------------------
INSERT INTO `network_card` VALUES ('0b080446-3260-44c9-af72-09ecb157a42e', null, null, 'eth2', '88ddee5e-666b-4935-a026-bc9a07aea5ad', '90:B1:1C:54:D4:3B', '1600325989330');
INSERT INTO `network_card` VALUES ('1e366242-0aaf-45b5-9110-43c2c88abfd5', null, '10.0.0.101', 'eth1', '1df66ab3-e959-4d04-af4d-3887817430f3', '6c:92:bf:b4:85:0b', '1600913075643');
INSERT INTO `network_card` VALUES ('1ec75cbd-7bd3-41f6-8edb-44a8af5b00ed', null, '192.168.1.102', 'eth0', '999961d8-efaf-44fe-b007-317b8650e28f', '6c:92:bf:b4:85:0a', '1599577724420');
INSERT INTO `network_card` VALUES ('2f1f1617-cc7d-4e71-9d6a-238b2231a04f', null, null, 'eth0', '6f655753-c192-453f-a2ec-1d3e132450fa', '3C:A8:2A:0A:5C:30', '1600325989301');
INSERT INTO `network_card` VALUES ('302542cc-fc3c-4bac-9b24-9a87ea2e0ab8', null, null, 'eth3', '6f655753-c192-453f-a2ec-1d3e132450fa', '3C:A8:2A:0A:5C:33', '1600325989301');
INSERT INTO `network_card` VALUES ('324fd260-008e-43d3-999b-330e4295d2c9', null, null, 'eth1', '4d6923ce-9b86-4076-a179-b4d73863701b', 'D4:AE:52:B5:E6:96', '1600913075555');
INSERT INTO `network_card` VALUES ('395f3f9a-611e-4aef-ac2c-747c7ead724a', null, null, 'eth0', '21709c84-eb20-4873-a7ff-6a94f2959750', '3C:A8:2A:0A:5C:30', '1600913075587');
INSERT INTO `network_card` VALUES ('419869af-95db-4d11-b61b-6abf7247edfb', null, null, 'eth2', '6f655753-c192-453f-a2ec-1d3e132450fa', '3C:A8:2A:0A:5C:32', '1600325989301');
INSERT INTO `network_card` VALUES ('45b798c1-d820-47b2-9f84-5a1e2bc7524f', null, null, 'eth1', '88ddee5e-666b-4935-a026-bc9a07aea5ad', '90:B1:1C:54:D4:3A', '1600325989330');
INSERT INTO `network_card` VALUES ('4b271df9-79f6-4577-a41a-a502c9e88856', null, null, 'eth1', 'dc685422-f495-466d-a453-1f9ce25efd23', '90:B1:1C:54:D4:3A', '1600913075617');
INSERT INTO `network_card` VALUES ('4c96bcbe-7d5c-443a-a33a-02b4cf8c4f5b', null, null, 'eth2', '21709c84-eb20-4873-a7ff-6a94f2959750', '3C:A8:2A:0A:5C:32', '1600913075587');
INSERT INTO `network_card` VALUES ('4cbcc466-f690-4709-aa2d-652d2226b355', null, null, 'eth2', '518dff15-4adc-4586-8f28-b33a6c27d7d7', 'D4:AE:52:B5:E6:97', '1600325989268');
INSERT INTO `network_card` VALUES ('510c7794-9eb0-4488-bc23-e1ad8aecd433', null, '192.168.1.102', 'eth0', '766540f9-da9f-4ad5-89e8-3757b88f55fe', '6c:92:bf:b4:85:0a', '1600325989362');
INSERT INTO `network_card` VALUES ('66d3de49-91b5-4d94-a0d9-4a80ba3bab6c', null, null, 'eth0', '88ddee5e-666b-4935-a026-bc9a07aea5ad', '90:B1:1C:54:D4:39', '1600325989330');
INSERT INTO `network_card` VALUES ('6bb3d15f-be5f-49d9-b9f6-c13448238779', null, null, 'eth1', '21709c84-eb20-4873-a7ff-6a94f2959750', '3C:A8:2A:0A:5C:31', '1600913075587');
INSERT INTO `network_card` VALUES ('7ad34841-8ea3-4bb4-a53c-e61a4cfe7c5f', null, '192.168.1.102', 'eth0', '1df66ab3-e959-4d04-af4d-3887817430f3', '6c:92:bf:b4:85:0a', '1600913075643');
INSERT INTO `network_card` VALUES ('7ade4fec-10d7-42e9-920d-84a2b1503133', null, '10.0.0.101', 'eth1', 'dbde4e6d-c489-47fc-800e-e1a57d734895', '6c:92:bf:b4:85:0b', '1600906554550');
INSERT INTO `network_card` VALUES ('8afe121e-b022-4c2d-bbea-49ad7d34b196', null, null, 'eth0', '4d6923ce-9b86-4076-a179-b4d73863701b', 'D4:AE:52:B5:E6:95', '1600913075555');
INSERT INTO `network_card` VALUES ('8e004055-eafb-4756-8ea9-072604a26b02', null, '10.0.0.101', 'eth1', '999961d8-efaf-44fe-b007-317b8650e28f', '6c:92:bf:b4:85:0b', '1599577724420');
INSERT INTO `network_card` VALUES ('95105940-1a04-4572-b302-9ccf4f4cdbd1', null, null, 'eth3', '518dff15-4adc-4586-8f28-b33a6c27d7d7', 'D4:AE:52:B5:E6:98', '1600325989268');
INSERT INTO `network_card` VALUES ('97cd13d3-178d-4376-a88f-9837e97d1f17', null, null, 'eth0', 'dc685422-f495-466d-a453-1f9ce25efd23', '90:B1:1C:54:D4:39', '1600913075617');
INSERT INTO `network_card` VALUES ('a7b955b3-f1fa-4600-9572-770d04c11262', null, null, 'eth2', '4d6923ce-9b86-4076-a179-b4d73863701b', 'D4:AE:52:B5:E6:97', '1600913075555');
INSERT INTO `network_card` VALUES ('b198c0bc-51d5-454b-8f39-e388488800e5', null, null, 'eth1', '6f655753-c192-453f-a2ec-1d3e132450fa', '3C:A8:2A:0A:5C:31', '1600325989301');
INSERT INTO `network_card` VALUES ('b4738152-09a9-4477-8374-aafbb332cc3c', null, '192.168.1.102', 'eth0', 'dbde4e6d-c489-47fc-800e-e1a57d734895', '6c:92:bf:b4:85:0a', '1600906554550');
INSERT INTO `network_card` VALUES ('bbb111d6-cd30-455b-8b37-9ea8ef65e538', null, null, 'eth3', 'dc685422-f495-466d-a453-1f9ce25efd23', '90:B1:1C:54:D4:3C', '1600913075617');
INSERT INTO `network_card` VALUES ('c6ad489c-09dc-4cb8-b1aa-dd56ef757c51', null, '10.0.0.101', 'eth1', '766540f9-da9f-4ad5-89e8-3757b88f55fe', '6c:92:bf:b4:85:0b', '1600325989362');
INSERT INTO `network_card` VALUES ('ce66f67f-5ebc-42b8-a30a-74533459d419', null, null, 'eth3', '4d6923ce-9b86-4076-a179-b4d73863701b', 'D4:AE:52:B5:E6:98', '1600913075555');
INSERT INTO `network_card` VALUES ('d62e1fb6-4954-43c6-b535-94ae99f84231', null, null, 'eth3', '21709c84-eb20-4873-a7ff-6a94f2959750', '3C:A8:2A:0A:5C:33', '1600913075587');
INSERT INTO `network_card` VALUES ('de25b6f8-c957-4eaf-922a-82c65e80a200', null, null, 'eth1', '518dff15-4adc-4586-8f28-b33a6c27d7d7', 'D4:AE:52:B5:E6:96', '1600325989268');
INSERT INTO `network_card` VALUES ('e2275bfc-68a8-45b5-8b31-4b1ec6f59a5a', null, null, 'eth3', '88ddee5e-666b-4935-a026-bc9a07aea5ad', '90:B1:1C:54:D4:3C', '1600325989330');
INSERT INTO `network_card` VALUES ('ed0fa485-ce67-4749-955e-05aa18a0c0aa', null, null, 'eth0', '518dff15-4adc-4586-8f28-b33a6c27d7d7', 'D4:AE:52:B5:E6:95', '1600325989268');
INSERT INTO `network_card` VALUES ('fb3736e4-47da-429c-b895-2e0554512d57', null, null, 'eth2', 'dc685422-f495-466d-a453-1f9ce25efd23', '90:B1:1C:54:D4:3B', '1600913075617');

-- ----------------------------
-- Table structure for `operation_log`
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
  `id` varchar(64) NOT NULL,
  `workspace_id` varchar(64) NOT NULL DEFAULT '' COMMENT '工作空间ID',
  `workspace_name` varchar(100) NOT NULL DEFAULT '' COMMENT '工作空间名称',
  `resource_user_id` varchar(64) NOT NULL DEFAULT '' COMMENT '资源拥有者ID',
  `resource_user_name` varchar(100) NOT NULL DEFAULT '' COMMENT '资源拥有者名称',
  `resource_type` varchar(45) NOT NULL DEFAULT '' COMMENT '资源类型',
  `resource_id` varchar(64) DEFAULT NULL COMMENT '资源ID',
  `resource_name` varchar(64) DEFAULT NULL COMMENT '资源名称',
  `operation` varchar(45) NOT NULL DEFAULT '' COMMENT '操作',
  `time` bigint(13) NOT NULL COMMENT '操作时间',
  `message` mediumtext COMMENT '操作信息',
  `module` varchar(20) DEFAULT 'management-center' COMMENT '模块',
  `source_ip` varchar(15) DEFAULT NULL COMMENT '操作方IP',
  PRIMARY KEY (`id`),
  KEY `IDX_OWNER_ID` (`workspace_id`) USING BTREE,
  KEY `IDX_USER_ID` (`resource_user_id`) USING BTREE,
  KEY `IDX_OP` (`operation`) USING BTREE,
  KEY `IDX_RES_ID` (`resource_id`) USING BTREE,
  KEY `IDX_RES_NAME` (`resource_name`) USING BTREE,
  KEY `IDX_USER_NAME` (`resource_user_name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of operation_log
-- ----------------------------
INSERT INTO `operation_log` VALUES ('1dae4564-2b7a-459c-8d6f-d7997d7a5240', '', '', 'admin', '', '', null, 'ipmi命令', '执行', '1600902939072', '192.168.1.250执行命令:power on 失败！', 'management-center', null);
INSERT INTO `operation_log` VALUES ('aa6f4b32-33e5-4487-a1d9-9be0998905b3', '', '', 'admin', '', '', null, 'ipmi命令', '执行', '1600903018338', '192.168.1.250执行命令:power on 失败！', 'management-center', null);
INSERT INTO `operation_log` VALUES ('c9f3bffb-7a84-4840-94fb-8d47b2adb597', '', '', 'admin', '', '', null, 'ipmi命令', '执行', '1600902932141', '192.168.1.250执行命令:power on 失败！', 'management-center', null);
INSERT INTO `operation_log` VALUES ('eb4a1554-faa2-4ea2-85c2-dcf85494727c', '', '', 'admin', '', '', null, 'ipmi命令', '执行', '1600904024132', '192.168.1.250执行命令:power on 失败！', 'management-center', null);

-- ----------------------------
-- Table structure for `out_band`
-- ----------------------------
DROP TABLE IF EXISTS `out_band`;
CREATE TABLE `out_band` (
  `id` varchar(200) NOT NULL,
  `bare_metal_id` varchar(50) NOT NULL DEFAULT '' COMMENT '物理机id',
  `endpoint_id` varchar(50) NOT NULL DEFAULT '' COMMENT 'enpoint id',
  `mac` varchar(200) NOT NULL DEFAULT '',
  `ip` varchar(35) NOT NULL DEFAULT '',
  `user_name` varchar(100) NOT NULL DEFAULT '' COMMENT '带外管理用户名',
  `pwd` varchar(200) NOT NULL DEFAULT '' COMMENT '带外管理密码',
  `status` varchar(10) NOT NULL DEFAULT 'off' COMMENT '机器是否在线，网络是否连通，on:在线,off:离线',
  `update_time` bigint(20) NOT NULL COMMENT '更新时间',
  `origin` tinyint(4) DEFAULT '0' COMMENT '来源,1:手动录入，2：导入，3：RackHD主动发现，4:RackHD扫描纳管，5：RackHD扫描感知',
  `asset_id` varchar(100) DEFAULT NULL COMMENT '资产ID',
  `machine_room` varchar(100) DEFAULT NULL COMMENT '机房',
  `machine_rack` varchar(100) DEFAULT NULL COMMENT '机柜',
  `u_number` varchar(50) DEFAULT NULL COMMENT 'U数',
  `remark` varchar(1000) DEFAULT NULL COMMENT '备注',
  `apply_user` varchar(100) DEFAULT NULL COMMENT '申请人',
  `optimistic_lock_version` int(11) NOT NULL DEFAULT '0' COMMENT '乐观锁',
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_OUT_BOUND_IP` (`ip`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of out_band
-- ----------------------------

-- ----------------------------
-- Table structure for `plugin`
-- ----------------------------
DROP TABLE IF EXISTS `plugin`;
CREATE TABLE `plugin` (
  `id` varchar(255) NOT NULL COMMENT 'ID',
  `name` varchar(255) DEFAULT NULL COMMENT '名称',
  `platform` varchar(255) DEFAULT NULL COMMENT '支持的品牌',
  `icon` varchar(255) DEFAULT NULL COMMENT 'icon',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of plugin
-- ----------------------------

-- ----------------------------
-- Table structure for `rackshift_version`
-- ----------------------------
DROP TABLE IF EXISTS `rackshift_version`;
CREATE TABLE `rackshift_version` (
  `installed_rank` int(11) NOT NULL,
  `version` varchar(50) DEFAULT NULL,
  `description` varchar(200) NOT NULL,
  `type` varchar(20) NOT NULL,
  `script` varchar(1000) NOT NULL,
  `checksum` int(11) DEFAULT NULL,
  `installed_by` varchar(100) NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `execution_time` int(11) NOT NULL,
  `success` tinyint(1) NOT NULL,
  PRIMARY KEY (`installed_rank`),
  KEY `rackshift_version_s_idx` (`success`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of rackshift_version
-- ----------------------------
INSERT INTO `rackshift_version` VALUES ('1', '0', '<< Flyway Baseline >>', 'BASELINE', '<< Flyway Baseline >>', null, 'root', '2020-09-02 10:08:40', '0', '1');
INSERT INTO `rackshift_version` VALUES ('2', '1', 'init', 'SQL', 'V1__init.sql', '2140813912', 'root', '2020-09-02 10:08:41', '5', '1');
INSERT INTO `rackshift_version` VALUES ('3', '2', 'rackshift ddl', 'SQL', 'V2__rackshift_ddl.sql', '-1752244030', 'root', '2020-09-02 10:08:41', '50', '1');
INSERT INTO `rackshift_version` VALUES ('4', '3', 'init data', 'SQL', 'V3__init_data.sql', '-565465555', 'root', '2020-09-02 10:09:18', '23', '1');

-- ----------------------------
-- Table structure for `role`
-- ----------------------------
DROP TABLE IF EXISTS `role`;
CREATE TABLE `role` (
  `id` varchar(50) NOT NULL COMMENT 'Role ID',
  `name` varchar(64) NOT NULL COMMENT 'Role name',
  `description` varchar(255) DEFAULT NULL COMMENT 'Role description',
  `type` varchar(50) DEFAULT NULL COMMENT 'Role type, (system|organization|workspace)',
  `create_time` bigint(13) NOT NULL COMMENT 'Create timestamp',
  `update_time` bigint(13) NOT NULL COMMENT 'Update timestamp',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of role
-- ----------------------------
INSERT INTO `role` VALUES ('1', 'admin', null, 'admin', '1600902879286', '1600902879286');

-- ----------------------------
-- Table structure for `system_parameter`
-- ----------------------------
DROP TABLE IF EXISTS `system_parameter`;
CREATE TABLE `system_parameter` (
  `param_key` varchar(64) NOT NULL COMMENT 'Parameter name',
  `param_value` varchar(255) DEFAULT NULL COMMENT 'Parameter value',
  `type` varchar(100) NOT NULL DEFAULT 'text' COMMENT 'Parameter type',
  `sort` int(5) DEFAULT NULL COMMENT 'Sort',
  PRIMARY KEY (`param_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of system_parameter
-- ----------------------------
INSERT INTO `system_parameter` VALUES ('main_endpoint', '192.168.43.14', 'endpoint', null);

-- ----------------------------
-- Table structure for `user`
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'User ID',
  `name` varchar(64) NOT NULL COMMENT 'User name',
  `email` varchar(64) NOT NULL COMMENT 'E-Mail address',
  `password` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `status` varchar(50) NOT NULL COMMENT 'User status',
  `create_time` bigint(13) NOT NULL COMMENT 'Create timestamp',
  `update_time` bigint(13) NOT NULL COMMENT 'Update timestamp',
  `language` varchar(30) DEFAULT NULL,
  `last_workspace_id` varchar(50) DEFAULT NULL,
  `last_organization_id` varchar(50) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL COMMENT 'Phone number of user',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('admin', 'admin', 'admin', '202cb962ac59075b964b07152d234b70', '1', '1599813075967', '1599813075967', null, null, null, null);

-- ----------------------------
-- Table structure for `user_role`
-- ----------------------------
DROP TABLE IF EXISTS `user_role`;
CREATE TABLE `user_role` (
  `id` varchar(50) NOT NULL COMMENT 'ID of user''s role info',
  `user_id` varchar(50) NOT NULL COMMENT 'User ID of this user-role info',
  `role_id` varchar(50) NOT NULL COMMENT 'Role ID of this user-role info',
  `source_id` varchar(50) DEFAULT NULL COMMENT 'The (system|organization|workspace) ID of this user-role info',
  `create_time` bigint(13) NOT NULL COMMENT 'Create timestamp',
  `update_time` bigint(13) NOT NULL COMMENT 'Update timestamp',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of user_role
-- ----------------------------
INSERT INTO `user_role` VALUES ('1', 'admin', '1', '', '1', '1');
INSERT INTO `user_role` VALUES ('2', 'admin', '1', null, '1599554996261', '1599554996261');

-- ----------------------------
-- Table structure for `workflow`
-- ----------------------------
DROP TABLE IF EXISTS `workflow`;
CREATE TABLE `workflow` (
  `id` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT 'user' COMMENT '类型，system，user',
  `injectable_name` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT 'workflow注入名称',
  `friendly_name` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT 'workflow友好名称',
  `event_type` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '执行workflow触发事件',
  `brands` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '支持的裸金属服务器品牌',
  `settable` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '是否需要配置payload参数',
  `default_params` mediumtext COLLATE utf8mb4_bin COMMENT '默认参数，这个和settable不冲突',
  `status` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '状态, 1 可用，2 停用',
  `create_time` bigint(13) NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='对RackHD的workflow的抽象';

-- ----------------------------
-- Records of workflow
-- ----------------------------
INSERT INTO `workflow` VALUES ('1', 'system', 'Graph.InstallCentOS', '安装Centos7 64位版', 'POST_OS_WORKFLOW_START', '[\'DELL\', \'HP\', \'Inspur\']', 'true', 0x7B0D0A2020202020202020226F7074696F6E73223A207B0D0A202020202020202020202264656661756C7473223A207B0D0A2020202020202020202020202276657273696F6E223A202237222C0D0A202020202020202020202020227265706F223A206E756C6C2C0D0A20202020202020202020202022726F6F7450617373776F7264223A20225261636B5368696674222C0D0A20202020202020202020202022686F73746E616D65223A20227261636B73686966742D6E6F6465222C0D0A202020202020202020202020226E6574776F726B44657669636573223A205B0D0A20202020202020202020202020207B0D0A2020202020202020202020202020202022646576696365223A206E756C6C2C0D0A202020202020202020202020202020202269707634223A207B0D0A20202020202020202020202020202020202022697041646472223A20223139322E3136382E312E3130222C0D0A2020202020202020202020202020202020202267617465776179223A20223139322E3136382E312E31222C0D0A202020202020202020202020202020202020226E65746D61736B223A20223235352E3235352E3235352E30220D0A202020202020202020202020202020207D0D0A20202020202020202020202020207D0D0A2020202020202020202020205D2C0D0A20202020202020202020202022696E7374616C6C4469736B223A20222F6465762F736461222C0D0A20202020202020202020202022696E7374616C6C506172746974696F6E73223A205B0D0A20202020202020202020202020207B0D0A20202020202020202020202020202020226D6F756E74506F696E74223A20222F222C0D0A202020202020202020202020202020202273697A65223A20226175746F222C0D0A2020202020202020202020202020202022667354797065223A202265787433220D0A20202020202020202020202020207D2C0D0A20202020202020202020202020207B0D0A20202020202020202020202020202020226D6F756E74506F696E74223A202273776170222C0D0A202020202020202020202020202020202273697A65223A202234303936222C0D0A2020202020202020202020202020202022667354797065223A202273776170220D0A20202020202020202020202020207D2C0D0A20202020202020202020202020207B0D0A20202020202020202020202020202020226D6F756E74506F696E74223A20222F626F6F74222C0D0A202020202020202020202020202020202273697A65223A202234303936222C0D0A2020202020202020202020202020202022667354797065223A202265787433220D0A20202020202020202020202020207D2C0D0A20202020202020202020202020207B0D0A20202020202020202020202020202020226D6F756E74506F696E74223A202262696F73626F6F74222C0D0A202020202020202020202020202020202273697A65223A202231222C0D0A2020202020202020202020202020202022667354797065223A202262696F73626F6F74220D0A20202020202020202020202020207D0D0A2020202020202020202020205D0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020207D, 'enable', '20200902100753');
INSERT INTO `workflow` VALUES ('2', 'system', 'Graph.Dell.perccli.Catalog', '搜集Dell服务器磁盘Raid信息', 'POST_OTHER_WORKFLOW_START', '[\'DELL\']', 'false', 0x7B0D0A202022626F6F7473747261702D72616E63686572223A207B0D0A2020202022646F636B657246696C65223A20227365637572652E65726173652E646F636B65722E7461722E787A220D0A20207D0D0A7D, 'enable', '20200902100753');
INSERT INTO `workflow` VALUES ('3', 'system', 'Graph.Raid.Delete.MegaRAID', '清空Dell服务器磁盘和Raid信息', 'POST_OTHER_WORKFLOW_START', '[\'DELL\']', 'false', 0x7B0D0A202022626F6F7473747261702D72616E63686572223A207B0D0A2020202022646F636B657246696C65223A20227365637572652E65726173652E646F636B65722E7461722E787A220D0A20207D0D0A7D, 'enable', '20200902100753');
INSERT INTO `workflow` VALUES ('4', 'system', 'Graph.Raid.Create.PercRAID', '创建Dell服务器磁盘Raid虚拟磁盘', 'POST_OTHER_WORKFLOW_START', '[\'DELL\']', 'true', 0x7B0D0A2020202020202020226F7074696F6E73223A207B0D0A2020202020202020202022626F6F7473747261702D72616E63686572223A207B0D0A20202020202020202020202022646F636B657246696C65223A20227365637572652E65726173652E646F636B65722E7461722E787A220D0A202020202020202020207D2C0D0A20202020202020202020226372656174652D72616964223A207B0D0A2020202020202020202020202263726561746544656661756C74223A2066616C73652C0D0A20202020202020202020202022636F6E74726F6C6C6572223A20302C0D0A2020202020202020202020202270617468223A20222F6F70742F4D656761524149442F70657263636C692F70657263636C693634222C0D0A20202020202020202020202022726169644C697374223A205B0D0A20202020202020202020202020207B0D0A2020202020202020202020202020202022656E636C6F73757265223A2033322C0D0A202020202020202020202020202020202274797065223A206E756C6C2C0D0A2020202020202020202020202020202022647269766573223A205B5D2C0D0A20202020202020202020202020202020226E616D65223A2022564430220D0A20202020202020202020202020207D0D0A2020202020202020202020205D0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020207D, 'enable', '20200902100753');

-- ----------------------------
-- Table structure for `workflow_param_templates`
-- ----------------------------
DROP TABLE IF EXISTS `workflow_param_templates`;
CREATE TABLE `workflow_param_templates` (
  `id` varchar(50) NOT NULL,
  `user_id` varchar(50) DEFAULT NULL,
  `bare_metal_id` varchar(50) DEFAULT NULL,
  `workflow_name` varchar(250) NOT NULL COMMENT 'workflow name',
  `params_template` longtext NOT NULL COMMENT '参数模板',
  `extra_params` longtext COMMENT '默认参数模板',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of workflow_param_templates
-- ----------------------------
