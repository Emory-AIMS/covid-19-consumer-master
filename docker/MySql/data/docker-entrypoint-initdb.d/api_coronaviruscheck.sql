CREATE SCHEMA IF NOT EXISTS api_coronaviruscheck;

USE api_coronaviruscheck;

CREATE TABLE IF NOT EXISTS `devices_hs_id`
(
    `id`                  bigint unsigned NOT NULL AUTO_INCREMENT,
    `hs_id`               varchar(255)    NOT NULL,
    `os_name`             varchar(255)             DEFAULT NULL,
    `os_version`          varchar(255)             DEFAULT NULL,
    `device_manufacturer` varchar(255)             DEFAULT NULL,
    `device_model`        varchar(255)             DEFAULT NULL,
    `created_at`          timestamp       NULL     DEFAULT CURRENT_TIMESTAMP,
    `notification_id`     varchar(255)             DEFAULT NULL,
    `active`              int             NOT NULL DEFAULT '1',
    `token`               varchar(255)             DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `hd_is_idx` (`hs_id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 3
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `patient_statuses`
(
    `id`            int       NOT NULL AUTO_INCREMENT,
    `patient_id`    int       NOT NULL,
    `old_status`    int       NOT NULL,
    `actual_status` int       NOT NULL,
    `updated_at`    timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `patient_id__index` (`id`)
    -- KEY `patient_up_by__index` (`updated_by`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `infected_devices`
(
    `device_id`    int       NOT NULL,
    `infection_timestamp`    timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_analysis_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `healed_timestamp` timestamp,
    PRIMARY KEY (`device_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;





