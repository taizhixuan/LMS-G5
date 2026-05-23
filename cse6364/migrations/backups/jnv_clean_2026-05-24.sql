-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: jnv
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `book`
--

DROP TABLE IF EXISTS `book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `book` (
  `book_id` int(11) NOT NULL AUTO_INCREMENT,
  `book_title` varchar(100) NOT NULL,
  `category_id` int(50) NOT NULL,
  `author` varchar(50) NOT NULL,
  `book_copies` int(11) NOT NULL,
  `book_pub` varchar(100) NOT NULL,
  `publisher_name` varchar(100) NOT NULL,
  `isbn` varchar(50) NOT NULL,
  `copyright_year` int(11) NOT NULL,
  `date_receive` varchar(20) NOT NULL,
  `date_added` datetime NOT NULL,
  `status` varchar(30) NOT NULL,
  PRIMARY KEY (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book`
--

LOCK TABLES `book` WRITE;
/*!40000 ALTER TABLE `book` DISABLE KEYS */;
INSERT INTO `book` VALUES (15,'Natural Resources',8,'Robin Kerrod',15,'Marshall Cavendish Corporation','Marshall','1-85435-628-3',1997,'','2013-12-11 06:34:27','New'),(16,'Encyclopedia Americana',5,'Grolier',20,'Connecticut','Grolier Incorporation','0-7172-0119-8',1988,'','2013-12-11 06:36:23','Archive'),(17,'Algebra 1',3,'Carolyn Bradshaw, Michael Seals',35,'Pearson Education, Inc','Prentice Hall, New Jersey','0-13-125087-6',2004,'','2013-12-11 06:39:17','Damage'),(18,'The Philippine Daily Inquirer',7,'..',3,'Pasay City','..','..',2013,'','2013-12-11 06:41:53','New'),(19,'Science in our World',4,'Brian Knapp',25,'Regency Publishing Group','Prentice Hall, Inc','0-13-050841-1',1996,'','2013-12-11 06:44:44','Lost'),(20,'Literature',9,'Greg Glowka',20,'Regency Publishing Group','Prentice Hall, Inc','0-13-050841-1',2001,'','2013-12-11 06:47:44','Old'),(21,'Lexicon Universal Encyclopedia',5,'Lexicon',10,'Lexicon Publication','Pulication Inc., Lexicon','0-7172-2043-5',1993,'','2013-12-11 06:49:53','Old'),(22,'Science and Invention Encyclopedia',5,'Clarke Donald, Dartford Mark',16,'H.S. Stuttman inc. Publishing','Publisher , Westport Connecticut','0-87475-450-x',1992,'','2013-12-11 06:52:58','New'),(23,'Integrated Science Textbook ',4,'Merde C. Tan',15,'Vibal Publishing House Inc.','12536. Araneta Avenue Corner Ma. Clara St., Quezon City','971-570-124-8',2009,'','2013-12-11 06:55:27','New'),(24,'Algebra 2',3,'Glencoe McGraw Hill',15,'The McGrawHill Companies Inc.','McGrawhill','978-0-07-873830-2',2008,'','2013-12-11 06:57:35','New'),(25,'Wiki at Panitikan ',7,'Lorenza P. Avera',28,'JGM & S Corporation','JGM & S Corporation','971-07-1574-7',2000,'','2013-12-11 06:59:24','Damage'),(26,'English Expressways TextBook for 4th year',9,'Virginia Bermudez Ed. O. et al',23,'SD Publications, Inc.','Gregorio Araneta Avenue, Quezon City','978-971-0315-33-8',2007,'','2013-12-11 07:01:25','New'),(27,'Asya Pag-usbong Ng Kabihasnan ',8,'Ricardo T. Jose, Ph . D.',21,'Vibal Publishing House Inc.','Araneta Avenue . Cor. Maria Clara St., Quezon City','971-07-2324-3',2008,'','2013-12-11 07:02:56','New'),(28,'Literature (the readers choice)',9,'Glencoe McGraw Hill',20,'..','the McGrawHill Companies Inc','0-02-817934-x',2001,'','2013-12-11 07:05:25','Damage'),(29,'Beloved a Novel',9,'Toni Morrison',13,'..','Alfred A. Knoff, Inc','0-394-53597-9',1987,'','2013-12-11 07:07:02','Old'),(30,'Silver Burdett Engish',2,'Judy Brim',12,'Silver Burdett Company','Silver','0-382-03575-5',1985,'','2013-12-11 09:22:50','Old'),(31,'The Corporate Warriors (Six Classic Cases in American Business)',8,'Douglas K. Ramsey',8,'Houghton Miffin Company','..','0-395-35487-0',1987,'','2013-12-11 09:25:32','Old'),(32,'Introduction to Information System',9,'Cristine Redoblo',10,'CHMSC','Brian INC','123-132',2013,'','2014-01-17 19:00:10','New');
/*!40000 ALTER TABLE `book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `borrow`
--

DROP TABLE IF EXISTS `borrow`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrow` (
  `borrow_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` bigint(50) NOT NULL,
  `date_borrow` varchar(100) NOT NULL,
  `due_date` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`borrow_id`),
  KEY `borrowerid` (`member_id`),
  KEY `borrowid` (`borrow_id`)
) ENGINE=MyISAM AUTO_INCREMENT=485 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `borrow`
--

LOCK TABLES `borrow` WRITE;
/*!40000 ALTER TABLE `borrow` DISABLE KEYS */;
INSERT INTO `borrow` VALUES (484,55,'2014-03-20 23:50:27','21/03/2014'),(483,55,'2014-03-20 23:49:34','21/03/2014'),(482,52,'2014-03-20 23:38:22','03/01/2014');
/*!40000 ALTER TABLE `borrow` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `borrowdetails`
--

DROP TABLE IF EXISTS `borrowdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrowdetails` (
  `borrow_details_id` int(11) NOT NULL AUTO_INCREMENT,
  `book_id` int(11) NOT NULL,
  `borrow_id` int(11) NOT NULL,
  `borrow_status` varchar(50) NOT NULL,
  `date_return` varchar(100) NOT NULL,
  PRIMARY KEY (`borrow_details_id`)
) ENGINE=MyISAM AUTO_INCREMENT=170 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `borrowdetails`
--

LOCK TABLES `borrowdetails` WRITE;
/*!40000 ALTER TABLE `borrowdetails` DISABLE KEYS */;
INSERT INTO `borrowdetails` VALUES (164,16,484,'pending',''),(162,15,482,'pending',''),(163,15,483,'returned','2014-03-21 00:30:51');
/*!40000 ALTER TABLE `borrowdetails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category` (
  `category_id` int(11) NOT NULL AUTO_INCREMENT,
  `classname` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `category_id` (`category_id`),
  KEY `classid` (`category_id`)
) ENGINE=MyISAM AUTO_INCREMENT=801 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'Periodical'),(2,'English'),(3,'Math'),(4,'Science'),(5,'Encyclopedia'),(6,'Filipiniana'),(7,'Newspaper'),(8,'General'),(9,'References');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lost_book`
--

DROP TABLE IF EXISTS `lost_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lost_book` (
  `Book_ID` int(11) NOT NULL AUTO_INCREMENT,
  `ISBN` int(11) NOT NULL,
  `Member_No` varchar(50) NOT NULL,
  `Date Lost` date NOT NULL,
  PRIMARY KEY (`Book_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lost_book`
--

LOCK TABLES `lost_book` WRITE;
/*!40000 ALTER TABLE `lost_book` DISABLE KEYS */;
/*!40000 ALTER TABLE `lost_book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member`
--

DROP TABLE IF EXISTS `member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member` (
  `member_id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(100) NOT NULL,
  `lastname` varchar(100) NOT NULL,
  `gender` varchar(10) NOT NULL,
  `address` varchar(100) NOT NULL,
  `contact` varchar(100) NOT NULL,
  `type` varchar(100) NOT NULL,
  `year_level` varchar(100) NOT NULL,
  `status` varchar(100) NOT NULL,
  PRIMARY KEY (`member_id`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member`
--

LOCK TABLES `member` WRITE;
/*!40000 ALTER TABLE `member` DISABLE KEYS */;
INSERT INTO `member` VALUES (52,'Mark','Sanchez','Male','Talisay','212010','Teacher','Faculty','Active'),(53,'April Joy','Aguilar','Female','E.B. Magalona','00','Student','Second Year','Banned'),(54,'Alfonso','Pancho','Male','E.B. Magalona','009','Student','First Year','Active'),(55,'Jonathan ','Antanilla','Male','E.B. Magalona','0032','Student','Fourth Year','Active'),(56,'Renzo Bryan','Pedroso','Male','Silay City','03030','Student','Third Year','Active'),(57,'Eleazar','Duterte','Male','E.B. Magalona','90902','Student','Second Year','Active'),(58,'Ellen Mae','Espino','Female','E.B. Magalona','123','Student','First Year','Active'),(59,'Ruth','Magbanua','Female','E.B. Magalona','9340','Student','Second Year','Active'),(60,'Shaina Marie','Gabino','Female','Silay City','132134','Student','Second Year','Active'),(62,'Chairty Joy','Punzalan','Female','E.B. Magalona','12423','Teacher','Faculty','Active'),(63,'Kristine May','Dela Rosa','Female','Silay City','1321','Student','Second Year','Active'),(64,'Chinie marie','Laborosa','Female','E.B. Magalona','902101','Student','Second Year','Active'),(65,'Ruby','Morante','Female','E.B. Magalona','','Teacher','Faculty','Active');
/*!40000 ALTER TABLE `member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `type`
--

DROP TABLE IF EXISTS `type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowertype` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `borrowertype` (`borrowertype`),
  KEY `id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=42 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `type`
--

LOCK TABLES `type` WRITE;
/*!40000 ALTER TABLE `type` DISABLE KEYS */;
INSERT INTO `type` VALUES (2,'Teacher'),(20,'Employee'),(21,'Non-Teaching'),(22,'Student'),(32,'Contruction');
/*!40000 ALTER TABLE `type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `firstname` varchar(100) NOT NULL,
  `lastname` varchar(100) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (2,'admin','admin','john','smith');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'jnv'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-24  3:15:52
