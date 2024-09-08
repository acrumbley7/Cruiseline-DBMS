-- CS4400: Introduction to Database Systems: Monday, June 10, 2024
-- Simple Cruise Management System Course Project Database TEMPLATE (v0)

-- Team 5
-- Kayla Chiang (kchiang39)
-- Aliyah Crumbley (acrumbley6)
-- Jacob Chien (jchien34)
-- Vasishta Kidambi (nkidambi6)
-- Directions:
-- Please follow all instructions for Phase II as listed on Canvas.
-- Fill in the team number and names and GT usernames for all members above.
-- Create Table statements must be manually written, not taken from an SQL Dump file.
-- This file must run without error for credit.

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'cruise_tracking';
drop database if exists cruise_tracking;
create database if not exists cruise_tracking;
use cruise_tracking;

-- Define the database structures
/* You must enter your tables definitions, along with your primary, unique and foreign key
declarations, and data insertion statements here.  You may sequence them in any order that
works for you.  When executed, your statements must create a functional database that contains
all of the data, and supports as many of the constraints as reasonably possible. */

drop table if exists route; -- Aliyah
create table route (
	routeID char(50) not null,
    primary key (routeID)
);

insert into route (routeID) values
	('americas_one'),
	('americas_three'),
	('americas_two'),
	('big_mediterranean_loop'),
	('euro_north'),
	('euro_south');
    
drop table if exists cruise; -- Aliyah
create table cruise (
	cruiseID char(50) not null,
    cost decimal(9,2) not null,
    routeID char(50) not null,
    primary key (cruiseID),
	constraint fk1 foreign key (routeID) references route(routeID)
);

insert into cruise (cruiseID, cost, routeID) values
	('rc_10', 200, 'americas_one'),
    ('cn_38', 200, 'americas_three'),
    ('dy_61', 200, 'americas_two'),
    ('nw_20', 300, 'euro_north'),
    ('pn_16', 400, 'euro_south'),
    ('rc_51', 100, 'big_mediterranean_loop');
    
drop table if exists location; -- Aliyah
create table location (
	locID char(50) not null,
    surrID char(10),
    primary key (locID),
    key (surrID)
);

insert into location (locID, surrID) values 
	('port_1','p1'),
	('port_2','p2'),
	('port_3','p3'),
	('port_10','p10'),
	('port_17','p17'),
	('ship_1','s1'),
	('ship_5','s5'),
	('ship_8','s8'),
	('ship_13','s13'),
	('ship_20','s20'),
	('port_12','p12'),
	('port_14','p14'),
	('port_15','p15'),
	('port_20','p20'),
	('port_4','p4'),
	('port_16','p16'),
	('port_11','p11'),
	('port_23','p23'),
	('port_7','p7'),
	('port_6','p6'),
	('port_13','p13'),
	('port_21','p21'),
	('port_18','p18'),
	('port_22','p22'),
	('ship_6','s6'),
	('ship_25','s25'),
	('ship_7','s7'),
	('ship_21','s21'),
	('ship_24','s24'),
	('ship_23','s23'),
	('ship_18','s18'),
	('ship_26','s26'),
	('ship_22','s22');


drop table if exists port; -- Aliyah
create table port (
	portID char(50) not null,
    port_name char(50),
    city char(50),
    state char(50),
    country char(50),
    locID char(10),
    primary key (portID),
    constraint fk19 foreign key (locID) references location(surrID) -- port union 
);

insert into port (portID, port_name, city, state, country, locID) values
	('MIA','Port of Miami','Miami','Florida','USA','p1'),
	('EGS','Port Everglades','Fort Lauderdale','Florida','USA','p2'),
	('CZL','Port of Cozumel','Cozumel','Quintana Roo','MEX','p3'),
	('CNL','Port Canaveral','Cape Canaveral','Florida','USA','p4'),
	('NSU','Port of Nassau','Nassau','New Providence ','BHS',NULL),
	('BCA','Port of Barcelona','Barcelona','Catalonia','ESP','p6'),
	('CVA','Port of Civitavecchia','Civitavecchia','Lazio','ITA','p7'),
	('VEN','Port of Venice','Venice','Veneto','ITA','p14'),
	('SHA','Port of Southampton','Southampton',NULL,'GBR',NULL),
	('GVN','Port of Galveston','Galveston','Texas','USA','p10'),
	('SEA','Port of Seattle','Seattle','Washington','USA','p11'),
	('SJN','Port of San Juan','San Juan','Puerto Rico','USA','p12'),
	('NOS','Port of New Orleans','New Orleans','Louisiana','USA','p13'),
	('SYD','Port of Sydney','Sydney','New South Wales','AUS',NULL),
	('TMP','Port of Tampa Bay','Tampa Bay','Florida','USA','p15'),
	('VAN','Port of Vancouver','Vancouver','British Columbia','CAN','p16'),
	('MAR','Port of Marseille','Marseille','Provence-Alpes-Côte d''Azur','FRA','p17'),
	('COP','Port of Copenhagen','Copenhagen','Hovedstaden','DEN','p18'),
	('BRI','Port of Bridgetown','Bridgetown','Saint Michael','BRB',NULL),
	('PIR','Port of Piraeus','Piraeus','Attica','GRC','p20'),
	('STS','Port of St. Thomas','Charlotte Amalie','St. Thomas','USVI','p21'),
	('STM','Port of Stockholm','Stockholm','Stockholm County','SWE','p22'),
	('LAS','Port of Los Angeles','Los Angeles','California','USA','p23');

drop table if exists leg; -- VK
create table leg (
	legID decimal(9,0) not null,
    distance decimal(9,0) not null,
    arrives char(5) not null,
    departs char(5) not null,
    primary key (legID),
    constraint fk2 foreign key (arrives) references port(portID), -- leg arrives at port relationship
    constraint fk3 foreign key (departs) references port(portID) -- leg departs from port relationship
);

insert into leg (legID, departs, arrives, distance) values
	(2, 'MIA', 'NSU', 190),
	(1, 'NSU', 'SJN', 792),
	(31, 'LAS', 'SEA', 1139),
	(14, 'SEA', 'VAN', 126),
	(4, 'MIA', 'EGS', 29),
	(15, 'MAR', 'CVA', 312),
	(27, 'CVA', 'VEN', 941),
	(33, 'VEN', 'PIR', 855),
	(64, 'STM', 'COP', 427),
	(78, 'COP', 'SHA', 803),
	(47, 'BCA', 'MAR', 185);


drop table if exists contains; -- VK
create table contains (
	routeID char(50) not null,
    legID decimal(9,0) not null,
    sequence decimal(9,0) not null,
    primary key (routeID, legID, sequence),
    constraint fk4 foreign key (routeID) references route(routeID),
    constraint fk5 foreign key (legID) references leg(legID)
);

INSERT INTO contains (routeID, legID, sequence) VALUES
	('americas_one', 2, 1),
	('americas_one', 1, 2),
	('americas_three', 31, 1),
	('americas_three', 14, 2),
	('americas_two', 4, 1),
	('big_mediterranean_loop', 47, 1),
	('big_mediterranean_loop', 15, 2),
	('big_mediterranean_loop', 27, 3),
	('big_mediterranean_loop', 33, 4),
	('euro_north', 64, 1),
	('euro_north', 78, 2),
	('euro_south', 47, 1),
	('euro_south', 15, 2);

drop table if exists cruiseline; -- Jacob 
create table cruiseline (
	cruiselineID char(50) not null,
    primary key (cruiselineID)
);

insert into cruiseline(cruiselineID) values
	('Royal Caribbean'),
	('Carnival'),
	('Norwegian'),
	('MSC'),
	('Princess'),
	('Celebrity'),
	('Disney'),
	('Holland America'),
	('Costa'),
	('P&O Cruises'),
	('AIDA'),
	('Viking Ocean'),
	('Silversea'),
	('Regent'),
	('Oceania'),
	('Seabourn'),
	('Cunard'),
	('Azamara'),
	('Windstar'),
	('Hurtigruten'),
	('Paul Gauguin Cruises'),
	('Celestyal Cruises'),
	('Saga Cruises'),
	('Ponant'),
	('Star Clippers'),
	('Marella Cruises');


drop table if exists ship; -- Jacob 
create table ship (
	cruiselineID char(50) not null,
    ship_name char(50) not null,
    max_cap decimal(9,0) not null,
    speed decimal(9,1) not null,
    locID char(10),
    primary key (cruiselineID, ship_name),
    constraint fk6 foreign key (cruiselineID) references cruiseline(cruiselineID),
    constraint fk7 foreign key (locID) references location(surrID)
);

insert into ship (cruiselineID, ship_name, max_cap, speed, locID) values 
	('Royal Caribbean','Symphony of the Seas', 6680,22,'s1'),
	('Carnival','Carnival Vista', 3934,23,'s23'),
	('Norwegian','Norwegian Bliss', 4004,22.5,'s24'),
	('MSC','Meraviglia', 4488,22.7,'s22'),
	('Princess','Crown Princess', 3080,23,'s5'),
	('Celebrity','Celebrity Edge', 2908,22,'s6'),
	('Disney','Disney Dream', 4000,23.5,'s7'),
	('Holland America','MS Nieuw Statendam', 2666,23,'s8'),
	('Costa','Costa Smeralda', 6554,23,NULL),
	('P&O Cruises','Iona', 5200,22.6,NULL),
	('AIDA','AIDAnova', 6600,21.5,NULL),
	('Viking Ocean','Viking Orion', 930,20,NULL),
	('Silversea','Silver Muse', 596,19.8,'s13'),
	('Regent','Seven Seas Explorer', 750,19.5,NULL),
	('Oceania','Marina', 1250,20,NULL),
	('Seabourn','Seabourn Ovation', 604,19,NULL),
	('Cunard','Queen Mary 2', 2691,30,NULL),
	('Azamara','Azamara Quest', 686,18.5,'s18'),
	('Royal Caribbean','Oasis of the Seas', 1325,18,'s25'),
	('Windstar','Wind Surf', 342,15,'s20'),
	('Hurtigruten','MS Roald Amundsen', 530,15.5,'s21'),
	('Paul Gauguin Cruises','Paul Gauguin', 332,18,NULL),
	('Celestyal Cruises','Celestyal Crystal', 1200,18.5,NULL),
	('Saga Cruises','Spirit of Discovery', 999,21,NULL),
	('Ponant','Le Lyrial', 264,16,'s26'),
	('Star Clippers','Royal Clipper', 227,17,NULL),
	('Marella Cruises','Marella Explorer', 1924,21.5,NULL);

drop table if exists river; -- Jacob 
create table river (
	cruiselineID char(50) not null,
    ship_name char(50) not null,
    uses_paddles boolean not null,
    primary key (cruiselineID, ship_name),
    constraint fk8 foreign key (cruiselineID, ship_name) references ship(cruiselineID, ship_name)
);

insert into river (cruiselineID, ship_name, uses_paddles) values
('Azamara', 'Azamara Quest', TRUE),
('Windstar', 'Wind Surf', FALSE),
('Hurtigruten', 'MS Roald Amundsen', TRUE),
('Celestyal Cruises', 'Celestyal Crystal', FALSE),
('Ponant', 'Le Lyrial', TRUE),
('Star Clippers', 'Royal Clipper', TRUE);

drop table if exists oceanliner; -- Jacob 
create table oceanliner (
	cruiselineID char(50) not null,
    ship_name char(50) not null,
    lifeboats int not null,
    primary key (cruiselineID, ship_name),
    constraint fk9 foreign key (cruiselineID, ship_name) references ship(cruiselineID, ship_name)
);

insert into oceanliner (cruiselineID, ship_name, lifeboats) values
	('Royal Caribbean', 'Symphony of the Seas', 20),
	('Carnival', 'Carnival Vista', 20),
	('Norwegian', 'Norwegian Bliss', 15),
	('MSC', 'Meraviglia', 20),
	('Princess', 'Crown Princess', 20),
	('Celebrity', 'Celebrity Edge', 20),
	('Disney', 'Disney Dream', 20),
	('Holland America', 'MS Nieuw Statendam', 30),
	('P&O Cruises', 'Iona', 20),
	('AIDA', 'AIDAnova', 35),
	('Viking Ocean', 'Viking Orion', 20),
	('Silversea', 'Silver Muse', 30),
	('Regent', 'Seven Seas Explorer', 20),
	('Oceania', 'Marina', 25),
	('Seabourn', 'Seabourn Ovation', 20),
	('Cunard', 'Queen Mary 2', 40),
	('Royal Caribbean', 'Oasis of the Seas', 30),
	('Saga Cruises', 'Spirit of Discovery', 2),
	('Marella Cruises', 'Marella Explorer', 2);

drop table if exists person; -- Kayla
create table person (
	personID decimal(9,0) not null,
    first_name char(100) not null,
    last_name char(100) not null,
    primary key (personID)
);

insert into person (personID, first_name, last_name) values
	('15', 'Matt', 'Hunt'),
	('18', 'Esther', 'Pittman'),
	('1', 'Jeanne', 'Nelson'),
	('11', 'Sandra', 'Cruz'),
	('19', 'Doug', 'Fowler'),
	('7', 'Sonya', 'Owens'),
	('14', 'Dana', 'Perry'),
	('13', 'Bryant', 'Figueroa'),
	('20', 'Thomas', 'Olson'),
	('16', 'Edna', 'Brown'),
	('12', 'Dan', 'Ball'),
	('8', 'Bennie', 'Palmer'),
	('6', 'Randal', 'Parks'),
	('3', 'Tanya', 'Nguyen'),
	('10', 'Lawrence', 'Morgan'),
	('4', 'Kendra', 'Jacobs'),
	('2', 'Roxanne', 'Byrd'),
	('17', 'Ruby', 'Burgess'),
	('5', 'Jeff', 'Burton'),
	('9', 'Marlene', 'Warner'),
	('21', 'Mona', 'Harrison'),
	('22', 'Arlene', 'Massey'),
	('23', 'Judith', 'Patrick'),
	('24', 'Reginald', 'Rhodes'),
	('25', 'Vincent', 'Garcia'),
	('26', 'Cheryl', 'Moore'),
	('27', 'Michael', 'Rivera'),
	('28', 'Luther', 'Matthews'),
	('29', 'Moses', 'Parks'),
	('30', 'Ora', 'Steele'),
	('31', 'Antonio', 'Flores'),
	('32', 'Glenn', 'Ross'),
	('33', 'Irma', 'Thomas'),
	('34', 'Ann', 'Maldonado'),
	('35', 'Jeffrey', 'Cruz'),
	('36', 'Sonya', 'Price'),
	('37', 'Tracy', 'Hale'),
	('38', 'Albert', 'Simmons'),
	('39', 'Karen', 'Terry'),
	('40', 'Glen', 'Kelley'),
	('41', 'Brooke', 'Little'),
	('42', 'Daryl', 'Nguyen'),
	('43', 'Judy', 'Willis'),
	('44', 'Marco', 'Klein'),
	('45', 'Angelica', 'Hampton');

drop table if exists passenger; -- Kayla
create table passenger (
	personID decimal(9,0) not null,
    miles int not null default 0, 
    funds decimal(9,2) not null default 0,
    primary key (personID),
    constraint fk13 foreign key (personID) references person(personID)
);

insert into passenger (personID, miles, funds) values
	('21', '771', '700'),
	('22', '374', '200'),
	('23', '414', '400'),
	('24', '292', '500'),
	('25', '390', '300'),
	('26', '302', '600'),
	('27', '470', '400'),
	('28', '208', '400'),
	('29', '292', '700'),
	('30', '686', '500'),
	('31', '547', '400'),
	('32', '257', '500'),
	('33', '564', '600'),
	('34', '211', '200'),
	('35', '233', '500'),
	('36', '293', '400'),
	('37', '552', '700'),
	('38', '812', '700'),
	('39', '541', '400'),
	('40', '441', '700'),
	('41', '875', '300'),
	('42', '691', '500'),
	('43', '572', '300'),
	('44', '572', '500'),
	('45', '663', '500');


drop table if exists booked;  -- VK
create table booked (
	cruiseID char(50) not null,
    personID decimal(9,0) not null,
    primary key (personID, cruiseID),
    constraint fk10 foreign key (cruiseID) references cruise(cruiseID),
    constraint fk11 foreign key (personID) references passenger(personID) -- should we do passenger or person?
);

insert into booked (personID, cruiseID) VALUES
	(21, 'nw_20'),
	(23, 'rc_10'),
	(25, 'rc_10'),
	(37, 'pn_16'),
	(38, 'pn_16');


drop table if exists crew; -- Kayla
create table crew (
	taxID char(50) not null,
    experience int default 0,
    personID decimal(9,0) not null,
    cruiseID char(50),
    primary key (personID), 
    key (taxID),
    constraint fk12 foreign key (personID) references person(personID)
);

insert into crew (taxID, experience, personID, cruiseID) values
	('153-47-8101', '30', '15', ''),
	('250-86-2784', '23', '18', 'rc_51'),
	('330-12-6907', '31', '1', 'rc_10'),
	('369-22-9505', '22', '11', 'pn_16'),
	('386-39-7881', '2', '19', ''),
	('450-25-5617', '13', '7', 'nw_20'),
	('454-71-7847', '13', '14', 'pn_16'),
	('513-40-4168', '24', '13', 'pn_16'),
	('522-44-3098', '28', '20', ''),
	('598-47-5172', '28', '16', 'rc_51'),
	('680-92-5329', '24', '12', ''),
	('701-38-2179', '12', '8', ''),
	('707-84-4555', '38', '6', 'dy_61'),
	('750-24-7616', '11', '3', 'cn_38'),
	('769-60-1266', '15', '10', 'nw_20'),
	('776-21-8098', '24', '4', 'cn_38'),
	('842-88-1257', '9', '2', 'rc_10'),
	('865-71-6800', '36', '17', 'rc_51'),
	('933-93-2165', '27', '5', 'dy_61'),
	('936-44-6941', '13', '9', 'nw_20');

drop table if exists crew_license; -- Kayla
create table crew_license (
	taxID char(50) not null,
    license char(50) not null,
    primary key (taxID),
    constraint fk14 foreign key (taxID) references crew(taxID)
);

insert into crew_license (taxID, license) values
	('153-47-8101', 'ocean_liner, river'),
	('250-86-2784', 'ocean_liner'),
	('330-12-6907', 'ocean_liner'),
	('369-22-9505', 'ocean_liner, river'),
	('386-39-7881', 'ocean_liner'),
	('450-25-5617', 'ocean_liner'),
	('454-71-7847', 'ocean_liner, river'),
	('513-40-4168', 'river'),
	('522-44-3098', 'ocean_liner'),
	('598-47-5172', 'ocean_liner'),
	('680-92-5329', 'river'),
	('701-38-2179', 'river'),
	('707-84-4555', 'ocean_liner, river'),
	('750-24-7616', 'ocean_liner'),
	('769-60-1266', 'ocean_liner'),
	('776-21-8098', 'ocean_liner, river'),
	('842-88-1257', 'ocean_liner, river'),
	('865-71-6800', 'ocean_liner, river'),
	('933-93-2165', 'ocean_liner'),
	('936-44-6941', 'ocean_liner, river');


drop table if exists occupies;  -- VK
create table occupies (
	personID decimal(9,0) not null,
    locID char(50) not null,
    primary key (personID, locID),
    constraint fk15 foreign key (personID) references person(personID),
    constraint fk18 foreign key (locID) references location(locID)
);

insert into occupies (personID, locID) values
	(1, 'ship_1'),
	(10, 'ship_24'),
	(13, 'ship_26'),
	(14, 'ship_26'),
	(16, 'ship_25'),
	(16, 'port_14'),
	(17, 'ship_25'),
	(17, 'port_14'),
	(18, 'ship_25'),
	(18, 'port_14'),
	(2, 'ship_1'),
	(21, 'ship_24'),
	(23, 'ship_1'),
	(25, 'ship_1'),
	(3, 'ship_23'),
	(37, 'ship_26'),
	(38, 'ship_26'),
	(4, 'ship_23'),
	(5, 'ship_7'),
	(5, 'port_1'),
	(6, 'ship_7'),
	(6, 'port_1'),
	(7, 'ship_24'),
	(9, 'ship_24');

drop table if exists supports;  -- VK
create table supports (
	cruiseID char(50) not null,
    cruiselineID char(50) not null,
    ship_name char(50) not null,
    progress int not null,
    ship_status enum('docked', 'sailing') default 'docked' not null,
    next_time time,
    primary key (cruiseID),
    constraint fk16 foreign key (cruiseID) references cruise(cruiseID),
    constraint fk17 foreign key (cruiselineID, ship_name) references ship(cruiselineID, ship_name)
);

insert into supports (cruiseID, cruiselineID, ship_name, progress, ship_status, next_time) values
	('rc_10', 'Royal Caribbean', 'Symphony of the Seas', 1, 'sailing', '08:00:00'),
	('cn_38', 'Carnival', 'Carnival Vista', 2, 'sailing', '14:30:00'),
	('dy_61', 'Disney', 'Disney Dream', 0, 'docked', '09:30:00'),
	('nw_20', 'Norwegian', 'Norwegian Bliss', 2, 'sailing', '11:00:00'),
	('pn_16', 'Ponant', 'Le Lyrial', 1, 'sailing', '14:00:00'),
	('rc_51', 'Royal Caribbean', 'Oasis of the Seas', 3, 'docked', '11:30:00');

