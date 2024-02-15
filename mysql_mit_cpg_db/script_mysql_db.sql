-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mit
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mit
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mit` ;
USE `mit` ;

-- -----------------------------------------------------
-- Table `mit`.`Distribution_Centres`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mit`.`Distribution_Centres` (
  `DC_PK` VARCHAR(45) NOT NULL,
  `LatDC` DECIMAL(9,6) NOT NULL,
  `LonDC` DECIMAL(9,6) NULL,
  `ServedByPlant` VARCHAR(45) NULL,
  `DaysTransit` INT NULL,
  `TypeTransit` ENUM('Normal', 'Black Haul') NULL,
  `StoresServed` INT NULL,
  PRIMARY KEY (`DC_PK`),
  UNIQUE INDEX `ServedByPlant_UNIQUE` (`ServedByPlant` ASC) VISIBLE,
  UNIQUE INDEX `DC_PK_UNIQUE` (`DC_PK` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mit`.`Zipcodes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mit`.`Zipcodes` (
  `GEOID_PK` VARCHAR(10) NOT NULL,
  `INTPTLAT` DECIMAL(9,6) NULL,
  `INTPTLONG` DECIMAL(9,6) NULL,
  PRIMARY KEY (`GEOID_PK`),
  UNIQUE INDEX `GEOID_ZIPCODE_PK_UNIQUE` (`GEOID_PK` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mit`.`Stores`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mit`.`Stores` (
  `Store_PK` VARCHAR(45) NOT NULL,
  `Zone` INT NULL,
  `StoreVolume` ENUM('Very Low', 'Low', 'Med', 'High', 'Very High', 'Ultra High') NULL,
  `Delivery` CHAR(1) NULL,
  `Samples` CHAR(1) NULL,
  `Urban` FLOAT NULL,
  `AfricanAmerican` FLOAT NULL,
  `Asian` FLOAT NULL,
  `Caucasian` FLOAT NULL,
  `Hispanic` FLOAT NULL,
  `MedianAge` FLOAT NULL,
  `MedianHHSize` FLOAT NULL,
  `MedianIncome` FLOAT NULL,
  `LatStore` DECIMAL(9,6) NULL,
  `LonStore` DECIMAL(9,6) NULL,
  `Distribution_Centres_DC_FK` VARCHAR(45) NULL,
  `Zipcodes_GEOID_ZIPCODE_Store_FK` VARCHAR(10) NULL,
  PRIMARY KEY (`Store_PK`),
  INDEX `DC_idx` (`Distribution_Centres_DC_FK` ASC) VISIBLE,
  UNIQUE INDEX `Store_PK_UNIQUE` (`Store_PK` ASC) VISIBLE,
  INDEX `GEOID_ZIPCODE_idx` (`Zipcodes_GEOID_ZIPCODE_Store_FK` ASC) VISIBLE,
  CONSTRAINT `DC`
    FOREIGN KEY (`Distribution_Centres_DC_FK`)
    REFERENCES `mit`.`Distribution_Centres` (`DC_PK`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `GEOID_ZIPCODE`
    FOREIGN KEY (`Zipcodes_GEOID_ZIPCODE_Store_FK`)
    REFERENCES `mit`.`Zipcodes` (`GEOID_PK`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mit`.`Products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mit`.`Products` (
  `SKU_PK` VARCHAR(45) NOT NULL,
  `ProductCategory` ENUM('Beer', "Snacks") NOT NULL,
  `ProductType` VARCHAR(45) NULL,
  `PcntAlcohol` DECIMAL(2) NULL,
  `RetailPrice` DECIMAL(3) NULL,
  `Quantity` INT NULL,
  PRIMARY KEY (`SKU_PK`),
  UNIQUE INDEX `SKU_PK_UNIQUE` (`SKU_PK` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mit`.`Transactions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mit`.`Transactions` (
  `Products_SKU_FK` VARCHAR(45) NOT NULL,
  `Stores_Store_FK` VARCHAR(45) NOT NULL,
  `SalesDate_PK` DATETIME NOT NULL,
  `UnitSold` INT NULL,
  `UnitPriceAvg` DECIMAL(2) NULL,
  `InvEndOfDay` INT NULL,
  PRIMARY KEY (`Products_SKU_FK`, `Stores_Store_FK`, `SalesDate_PK`),
  INDEX `Sore_idx` (`Stores_Store_FK` ASC) VISIBLE,
  UNIQUE INDEX `Stores_Store_FK_UNIQUE` (`Stores_Store_FK` ASC) VISIBLE,
  UNIQUE INDEX `Products_SKU_FK_UNIQUE` (`Products_SKU_FK` ASC) VISIBLE,
  UNIQUE INDEX `SalesDate_PK_UNIQUE` (`SalesDate_PK` ASC) VISIBLE,
  CONSTRAINT `SKU`
    FOREIGN KEY (`Products_SKU_FK`)
    REFERENCES `mit`.`Products` (`SKU_PK`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Stores`
    FOREIGN KEY (`Stores_Store_FK`)
    REFERENCES `mit`.`Stores` (`Store_PK`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mit`.`Census_Income_By_Zipcodes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mit`.`Census_Income_By_Zipcodes` (
  `ZipcodesGeoid_PK_FK` VARCHAR(10) NOT NULL,
  `Total_Income` DECIMAL NULL,
  `LessThanHighSchool` INT NULL,
  `HighSchoolGraduate` INT NULL,
  `SomeCollegeOrAssociate` INT NULL,
  `BachelorsDegree` INT NULL,
  `GraduateOrProfessionalDegree` INT NULL,
  PRIMARY KEY (`ZipcodesGeoid_PK_FK`),
  UNIQUE INDEX `ZIPCODE_UNIQUE` (`ZipcodesGeoid_PK_FK` ASC) VISIBLE,
  CONSTRAINT `ZIPCODE`
    FOREIGN KEY (`ZipcodesGeoid_PK_FK`)
    REFERENCES `mit`.`Zipcodes` (`GEOID_PK`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
