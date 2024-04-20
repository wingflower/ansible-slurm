CREATE USER 'slurm'@'%' IDENTIFIED BY 'qwe123!@#';
CREATE USER 'slurm'@'slurm-db-01' IDENTIFIED BY 'qwe123!@#';
CREATE USER 'slurm'@'192.168.%.%' IDENTIFIED BY 'qwe123!@#';
GRANT ALL PRIVILEGES ON *.* to 'slurm'@'%' IDENTIFIED BY 'qwe123!@#';
GRANT ALL PRIVILEGES ON `slurm_acct_db`.* TO 'slurm'@'%';
FLUSH PRIVILEGES;
CREATE DATABASE slurm_acct_db;
