# Online Library Management System

> **This repository is a CSE6364 (Software Evolution & Maintenance, MMU, Term 2610) maintenance fork by Group 5 of the upstream project at https://github.com/vinitshahdeo/Library-Management-System.**
>
> Six enhancements have been applied to the borrow/return workflow and to PHP 8 compatibility. The original upstream README content is preserved below for attribution; the new setup steps live in [Group 5 fork setup](#group-5-fork-setup-cse6364-2026) — read that first.
>
> Evidence index: [`cse6364/evidence/MANIFEST.md`](cse6364/evidence/MANIFEST.md)
> Test matrix:    [`cse6364/testing/test-matrix.md`](cse6364/testing/test-matrix.md)

---

## Group 5 fork setup (CSE6364 2026)

The upstream "How to run?" section below is outdated against modern PHP/MariaDB. Use these steps instead.

### Prerequisites

| Tool | Tested version | Why |
|------|----------------|-----|
| **XAMPP** (or equivalent Apache + MariaDB bundle) | XAMPP 8.2.12 (PHP 8.2.12, MariaDB 10.4, Apache 2.4.58) | Local dev environment |
| **Git** | any modern | Branch / merge / rollback |
| **Default credentials** | `admin` / `admin` | Built into the seed `users` table |

### 1. Clone into your web root

```bash
cd /c/xampp/htdocs/
git clone <fork-url> Library-Management-System
cd Library-Management-System
```

### 2. Create the database and import the seed schema

```bash
# Pick the port your local MariaDB listens on (default 3306, ours is 3307)
mysql -u root --port=3306 -e "CREATE DATABASE jnv;"
mysql -u root --port=3306 jnv < eb_lms.sql
```

Note: the seed file is named `eb_lms.sql` but actually creates a database named `jnv`. The four `dbcon.php` copies have all been unified on `jnv`; the upstream naming mismatch was fixed in commit `f44ac4a [setup] unify dbcon.php database name to jnv`.

### 3. Apply the schema upgrade migration

This converts `borrow` and `borrowdetails` from MyISAM/varchar(dates) to InnoDB with proper `DATE` / `DATETIME` columns and foreign keys. Without this step the E1 server-side validation will accept `due_date` values that silently coerce to `'0000-00-00'`.

```bash
# Back up first in case something goes wrong
mysqldump -u root --port=3306 jnv > /tmp/jnv-before-migration.sql

# Apply the migration
mysql -u root --port=3306 jnv < cse6364/migrations/001_schema_upgrade.sql

# Verify
mysql -u root --port=3306 jnv -e "SHOW CREATE TABLE borrow\\G SHOW CREATE TABLE borrowdetails\\G"
```

A pre-migration backup is also committed at `cse6364/migrations/backups/jnv_clean_2026-05-24.sql` for reproducibility.

### 4. Configure `dbcon.php` for your local DB host / port

There are four `dbcon.php` copies (the upstream codebase duplicates the `librarian/` and `library/` folders). All four currently hardcode `127.0.0.1` and port `3307` because that is what our development environment uses:

```php
$con = mysqli_connect('127.0.0.1', 'root', '', 'jnv', 3307);
```

If your MariaDB listens on the default port `3306` and accepts `localhost`, change those values in all four files:

```
dbcon.php
librarian/dbcon.php
library/dbcon.php
library/librarian/dbcon.php
```

### 5. Run

Start Apache + MariaDB in XAMPP, then open:

```
http://localhost/Library-Management-System/librarian/
```

Login with `admin` / `admin`.

---

## What changed in this fork

Six enhancements were applied on `evo-main`, each on its own feature branch merged with `--no-ff`:

| # | Branch | Type | What |
|---|--------|------|------|
| **E1** | `feat/E1-server-validation` | Corrective | Server-side validation in `borrow_save.php` (count, member, book exists, book available, duplicates, due_date format) with `$_SESSION['flash_error']` user feedback |
| **E2** | `feat/E2-transaction-safe-save` | Corrective | `mysqli_begin_transaction` + `mysqli_insert_id` + rollback-on-failure (replaces race-prone `SELECT … ORDER BY borrow_id DESC`) |
| **E3** | `feat/E3-schema-upgrade` | Perfective | Schema upgrade: varchar dates → `DATETIME`/`DATE`, MyISAM → InnoDB, three foreign keys with `ON DELETE RESTRICT` |
| **E4** | `feat/E4-safer-return` | Corrective + Preventive | `return_save.php`: POST-only, CSRF token, prepared statements, status check (rejects already-returned rows) |
| **E5** | `feat/E5-efficient-availability` | Perfective | `books.php` collapsed from 36 queries to 1 via single `LEFT JOIN ... GROUP BY` |
| **E6** | `feat/E6-php8-mysqli` | Adaptive | `mysql_*` → `mysqli_*` migration across all 217 PHP files so the codebase runs on PHP 8 (it was removed from PHP 7+ in 2015) |

```bash
git log --oneline --graph --decorate evo-main      # see the merge structure
git diff baseline-before-evo..evo-main             # full enhancement diff (excludes [env] commits)
```

The `baseline-before-evo` tag points at the unmodified upstream commit; any "before vs after" comparison uses that tag as ground zero.

## Original upstream README (preserved for attribution)

#### An interactive web portal for automating various manual processes done by librarian.

[![GitHub repo size](https://img.shields.io/github/repo-size/vinitshahdeo/Library-Management-System.svg?logo=github&style=social)](https://vinitshahdeo.github.io/Library-Management-System/) [![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/vinitshahdeo/Library-Management-System.svg?logo=git&style=social)](https://vinitshahdeo.github.io/Library-Management-System/) [![GitHub license](https://img.shields.io/github/license/vinitshahdeo/Library-Management-System.svg?style=social&logo=github)](https://github.com/vinitshahdeo/Library-Management-System/blob/master/LICENSE)

## Abstract

![Library Management System](https://img.shields.io/badge/library--management-system-orange.svg?style=flat-square) 
![DBMS Project](https://img.shields.io/badge/DBMS-project-yellowgreen.svg?style=flat-square)
![Open Source Programming](https://img.shields.io/badge/open--source-programming-ff69b4.svg?style=flat-square)

Manual process of keeping student records, book records, account details, managing employee is very difficult. There are various problems also faced by the student in library such as finding any particular book, information whether book is available or not, for what time this book will be available, searching of books using ISBN number etc. To eliminate this manual system, **Library Management System** has been developed.

[![PPT](https://img.shields.io/static/v1.svg?label=Project&message=PPT&logo=microsoft-powerpoint&style=social)](https://github.com/vinitshahdeo/Library-Management-System/raw/master/PPTs/ONLINE%20LIBRARY%20MANAGEMENT%20SYSTEM.pptx) [![report](https://img.shields.io/static/v1.svg?label=Project&message=Report&logo=microsoft-word&style=social)](https://github.com/vinitshahdeo/Library-Management-System/raw/master/PROJECT%20REPORT/LIBRARY%20Management%20System%20Report.pdf)

> **You can download the report [here](https://github.com/vinitshahdeo/Library-Management-System/raw/master/PROJECT%20REPORT/LIBRARY%20Management%20System%20Report.pdf). To download the presentation, [click here](https://github.com/vinitshahdeo/Library-Management-System/raw/master/PPTs/ONLINE%20LIBRARY%20MANAGEMENT%20SYSTEM.pptx).**

> **You can check the screenshots of User Interface [here](https://github.com/vinitshahdeo/Library-Management-System/tree/master/screenshots).**

## Core Features

![admin](https://img.shields.io/badge/admin-login-teal.svg?style=flat-square) 
![search](https://img.shields.io/badge/seacrh-books-yellowgreen.svg?style=flat-square)
![issue](https://img.shields.io/badge/issue-books-ff69b4.svg?style=flat-square)
![member](https://img.shields.io/badge/add-member-dodgerblue.svg?style=flat-square) 
![add](https://img.shields.io/badge/add-books-orange.svg?style=flat-square) 

- **Searching** of books
- **Issuing** and **returning** books
- Check fines(if any)
- Librarian can read information about any member
- Librarian can track the books issued by a particular student
- Librarian can **add/remove any member**(student).
- Librarian can **add/delete books**
- Librarian can update the availability status of the books

## Additional Features

**Admin Dashboard** deal with the following : 

- Displaying all members records.

- Displaying all books records.

- Update Book Records.

- Delete Book Records

- Add Book Records

- Add Member/Student Records

- Delete Member/Student Records

- Update Member/Student Records.

## Modules

- Admin login
- Search Books
- Add and Update Books
- Add and Remove Members
- Issue Books

## Technology Stack Used

![HTML](https://img.shields.io/badge/frontend-html-orange.svg?logo=html5&style=flat-square) 
![CSS](https://img.shields.io/badge/frontend-css-yellowgreen.svg?logo=css3&style=flat-square)
![JavaScript](https://img.shields.io/badge/frontend-js-ff69b4.svg?logo=javascript&style=flat-square)
![PHP](https://img.shields.io/badge/backend-php-blue.svg?logo=php&style=flat-square) 
![MYSQL](https://img.shields.io/badge/database-mysql-lightgray.svg?logo=mysql&logoColor=white&style=flat-square) 

- Front End - **HTML**, **CSS**, **JavaScript**
- Back End - **PHP**
- Database - **MySql**

## Requirements

[![PHP](https://img.shields.io/static/v1.svg?label=Source%20Code&message=php&logo=php&style=social)](https://vinitshahdeo.github.io/Library-Management-System/)

The source code of this project is written in **PHP**. So, you'll require **WAMP/XAMPP/MAMP** to run this project.

## Installing 

[![wamp](https://img.shields.io/badge/wamp-server-red.svg?style=flat-square)](http://www.wampserver.com/en/) [![xampp](https://img.shields.io/badge/xampp-server-blue.svg?style=flat-square)](https://www.apachefriends.org/download.html) [![mamp](https://img.shields.io/badge/mamp-server-lightgrey.svg?style=flat-square)](https://www.mamp.info/en/)

- Download [WAMP](http://www.wampserver.com/en/)
- Download [XAMPP](https://www.apachefriends.org/download.html)
- Download [MAMP](https://www.mamp.info/en/)

## How to run?

1. Download this repo and extract it in your **www/htdocs** directory. 
2. Import the [database] from **db** folder. 
3. Configure `dbcon.php` 
4. Run **`localhost/{YOUR FOLDER NAME}`**

## Need help?

```javascript

  if (needHelp === true) {
     var emailId = "vinitshahdeo@gmail.com";
     // email is the best way to reach out to me.
     sendEmail(emailId);
  }

```

Feel free to contact me via [Facebook](https://www.facebook.com/vinit.shahdeo).

Invite me to connect on [LinkedIn](https://www.linkedin.com/in/vinitshahdeo/).

[![Facebook](https://img.shields.io/static/v1.svg?label=follow&message=@vinit.shahdeo&color=9cf&logo=facebook&style=flat&logoColor=white&colorA=informational)](https://www.facebook.com/vinit.shahdeo)  [![Instagram](https://img.shields.io/static/v1.svg?label=follow&message=@vinitshahdeo&color=grey&logo=instagram&style=flat&logoColor=white&colorA=critical)](https://www.instagram.com/vinitshahdeo/) [![LinkedIn](https://img.shields.io/static/v1.svg?label=connect&message=@vinitshahdeo&color=success&logo=linkedin&style=flat&logoColor=white&colorA=blue)](https://www.linkedin.com/in/vinitshahdeo/)

## Are you a [VITian](http://www.vit.ac.in/)?

Looking for the **"J" Component** stuffs, you've landed at right place!

[![dbms report](https://img.shields.io/static/v1.svg?label=DBMS&message=Report&logo=microsoft-word&style=social)](https://github.com/vinitshahdeo/Library-Management-System/raw/master/PROJECT%20REPORT/LMS-DBMS%20Report-Vinit%20Shahdeo.pdf) [![PPT](https://img.shields.io/static/v1.svg?label=Project&message=PPT&logo=microsoft-powerpoint&style=social)](https://github.com/vinitshahdeo/Library-Management-System/raw/master/PPTs/ONLINE%20LIBRARY%20MANAGEMENT%20SYSTEM.pptx) [![OSP report](https://img.shields.io/static/v1.svg?label=OSP&message=Report&logo=microsoft-word&style=social)](https://github.com/vinitshahdeo/Library-Management-System/raw/master/PROJECT%20REPORT/LIBRARY%20Management%20System%20Report.pdf)

- [Download](https://github.com/vinitshahdeo/Library-Management-System/raw/master/PROJECT%20REPORT/LMS-DBMS%20Report-Vinit%20Shahdeo.pdf) DBMS report
- [Download](https://github.com/vinitshahdeo/Library-Management-System/raw/master/PROJECT%20REPORT/LIBRARY%20Management%20System%20Report.pdf) OSP report
- [Download](https://github.com/vinitshahdeo/Library-Management-System/raw/master/PPTs/ONLINE%20LIBRARY%20MANAGEMENT%20SYSTEM.pdf) presentation

> You can use [this](https://github.com/vinitshahdeo/Library-Management-System) project for the following courses : 

| Course Name  | Course Code  |
|:-:|:-:|
| Database Management Systems | ITE1003 |
| Open Source Programming | ITE1008 |
| Object Oriented Analysis and Design  | ITE1007 |
| Software Engineering-Principles and Practices	| ITE1005 |

## License

[![GitHub license](https://img.shields.io/github/license/vinitshahdeo/Library-Management-System.svg?style=social&logo=github)](https://github.com/vinitshahdeo/Library-Management-System/blob/master/LICENSE) [![Author](https://img.shields.io/static/v1.svg?label=Author&message=@vinitshahdeo&logo=github&style=social)](https://github.com/vinitshahdeo)

**MIT &copy; [Vinit Shahdeo](https://github.com/vinitshahdeo/Library-Management-System/blob/master/LICENSE)**

[![](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/images/0)](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/links/0)[![](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/images/1)](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/links/1)[![](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/images/2)](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/links/2)[![](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/images/3)](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/links/3)[![](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/images/4)](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/links/4)[![](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/images/5)](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/links/5)[![](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/images/6)](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/links/6)[![](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/images/7)](https://sourcerer.io/fame/vinitshahdeo/vinitshahdeo/Library-Management-System/links/7)

<a href="https://twitter.com/Vinit_Shahdeo"><img src="images5/twitter.png" width="32px" height="32px"></a> <a href="https://www.facebook.com/vinit.shahdeo"><img src="images5/facebook.png" width="32px" height="32px"></a> <a href="https://www.linkedin.com/in/vinitshahdeo/"><img src="images5/linkedin.png" width="32px" height="32px"></a>

## Oh, Thanks!

[![saythanks](https://img.shields.io/badge/say-thanks-ff69b4.svg)](https://facebook.com/vinit.shahdeo) 
[![Twitter](https://img.shields.io/twitter/url/https/github.com/vinitshahdeo/Library-Management-System.svg?style=social)](https://twitter.com/intent/tweet?text=Library%20Management%20System%20by@Vinit_Shahdeo%20:&url=https://github.com/vinitshahdeo/Library-Management-System)

Thank you for being here!
This project has saved me and my friends for many times in college.

```bash

   ____ _           _   _                   
  / ___| | __ _  __| | | |_ ___             
 | |  _| |/ _` |/ _` | | __/ _ \            
 | |_| | | (_| | (_| | | || (_) |           
  \____|_|\__,_|\__,_|  \__\___/            
  ___  ___  ___                             
 / __|/ _ \/ _ \                            
 \__ \  __/  __/                            
 |___/\___|\___|      _                   _ 
  _   _  ___  _   _  | |__   ___ _ __ ___| |
 | | | |/ _ \| | | | | '_ \ / _ \ '__/ _ \ |
 | |_| | (_) | |_| | | | | |  __/ | |  __/_|
  \__, |\___/ \__,_| |_| |_|\___|_|  \___(_)
  |___/                                     


```

**Share your story([vinitshahdeo@gmail.com](https://mail.google.com/mail/))** if you're using this repo for your mini/course project. I will be more than happy to know how does this project helped you.

[![GMAIL](https://img.shields.io/static/v1.svg?label=send&message=vinitshahdeo@gmail.com&color=red&logo=gmail&style=social)](https://www.github.com/vinitshahdeo) [![GitHub followers](https://img.shields.io/github/followers/vinitshahdeo.svg?label=Follow&style=social)](https://github.com/vinitshahdeo/)

------

```javascript

  if (isAwesome) {
    // thanks in advance :p
    starThisRepository();
  }
  
```

-------
