USE [master];
GO

DROP DATABASE IF EXISTS [development];
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'db_admin_test_user' AND type = 'S')
BEGIN
    DROP LOGIN db_admin_test_user;
END

CREATE DATABASE [development] collate SQL_Latin1_General_CP1_CI_AS;
GO

ALTER DATABASE [development] SET COMPATIBILITY_LEVEL = 140
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
BEGIN
    EXEC [development].[dbo].[sp_fulltext_database] @action = 'enable'
END
GO

ALTER DATABASE [development] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [development] SET ANSI_NULLS OFF
GO
ALTER DATABASE [development] SET ANSI_PADDING OFF
GO
ALTER DATABASE [development] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [development] SET ARITHABORT OFF
GO
ALTER DATABASE [development] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [development] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [development] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [development] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [development] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [development] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [development] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [development] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [development] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [development] SET  DISABLE_BROKER
GO
ALTER DATABASE [development] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [development] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [development] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [development] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [development] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [development] SET RECOVERY FULL
GO
ALTER DATABASE [development] SET  MULTI_USER
GO
ALTER DATABASE [development] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [development] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF )
GO
ALTER DATABASE [development] SET TARGET_RECOVERY_TIME = 60 SECONDS
GO
ALTER DATABASE [development] SET DELAYED_DURABILITY = DISABLED
GO
ALTER DATABASE [development] SET QUERY_STORE = OFF
GO

--- Create logins

USE [development];
GO

-- Create an admin login

CREATE LOGIN [db_admin_test_user] WITH PASSWORD = 'admin$Pass';
GO

-- Create a user for the admin login
CREATE USER [db_admin_test_user] FOR LOGIN [db_admin_test_user] WITH DEFAULT_SCHEMA=[dbo];
GO

--- Create users

CREATE LOGIN [db_exchange_test_user] WITH PASSWORD = 'user$Pass';
GO

-- Create a user for the application login
CREATE USER [db_exchange_test_user] FOR LOGIN [db_exchange_test_user] WITH DEFAULT_SCHEMA=[dbo];
GO

-- Assign the 'db_owner' role to the admin user
-- This role can manage all aspects of the database

-- Alternatively,
-- Grant the application user access to the database
-- ALTER ROLE db_datareader ADD MEMBER db_exchange_test_user;

EXEC sp_addrolemember 'db_owner','db_admin_test_user';
EXEC sp_addrolemember 'db_datareader', 'db_admin_test_user';
EXEC sp_addrolemember 'db_datawriter', 'db_admin_test_user';
EXEC sp_addrolemember 'db_ddladmin', 'db_admin_test_user';
EXEC sp_addrolemember 'db_backupoperator', 'db_admin_test_user';
GO

-- Assign specific roles to the application user
-- Granting 'db_datareader' and 'db_datawriter' roles for basic data access
EXEC sp_addrolemember 'db_owner', 'db_exchange_test_user';
EXEC sp_addrolemember 'db_datareader', 'db_exchange_test_user';
EXEC sp_addrolemember 'db_datawriter', 'db_exchange_test_user';
GO

-- Optionally, grant execute permissions to the application user
-- This allows the user to execute stored procedures
GRANT EXECUTE TO [db_exchange_test_user];
GRANT SELECT, INSERT, UPDATE, DELETE TO [db_exchange_test_user];
GO

GRANT CONNECT ON DATABASE::[development] TO [db_exchange_test_user];
GO
GRANT CONNECT ON DATABASE::[development] TO [db_admin_test_user];
GO
