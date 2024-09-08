-- CS4400: Introduction to Database Systems: Monday, July 1, 2024
-- Simple Cruise Management System Course Project Stored Procedures [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'cruise_tracking';
use cruise_tracking;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
	returns time reads sql data
begin
	declare total_time decimal(10,2);
    declare hours, minutes integer default 0;
    set total_time = ip_distance / ip_speed;
    set hours = truncate(total_time, 0);
    set minutes = truncate((total_time - hours) * 60, 0);
    return maketime(hours, minutes, 0);
end //
delimiter ;

-- [1] add_ship() -- 1
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ship.  A new ship must be sponsored
by an existing cruiseline, and must have a unique name for that cruiseline. 
A ship must also have a non-zero seat capacity and speed. A ship
might also have other factors depending on it's type, like paddles or some number
of lifeboats.  Finally, a ship must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_ship;
delimiter //
create procedure add_ship (in ip_cruiselineID varchar(50), in ip_ship_name varchar(50),
	in ip_max_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_ship_type varchar(100), in ip_uses_paddles boolean, in ip_lifeboats integer)
sp_main: begin
	if (ip_cruiselineID is null or ip_ship_name is null or ip_max_capacity is null or ip_speed is null or ip_locationID is null or ip_ship_type is null) then leave sp_main;
    elseif (ip_max_capacity <= 0 or ip_speed <= 0) then leave sp_main;
    elseif (ip_cruiselineID not in (select cruiselineID from cruiseline)) then leave sp_main;
    elseif (ip_ship_name in (select ship_name from ship where cruiselineID = ip_cruiselineID)) then leave sp_main;
    elseif (ip_locationID not in (select locationID from location)) then insert into location(locationID) values (ip_locationID);
    end if;
    
    insert into ship(cruiselineID, ship_name, max_capacity, speed, locationID, ship_type, uses_paddles, lifeboats) 
		values (ip_cruiselineID, ip_ship_name, ip_max_capacity, ip_speed, ip_locationID, ip_ship_type, ip_uses_paddles, ip_lifeboats);
end //
delimiter ;

-- [2] add_port() -- 1
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new port.  A new port must have a unique
identifier along with a new and database-wide unique location if it will be used
to support ship arrivals and departures.  A port may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_port;
delimiter //
create procedure add_port (in ip_portID char(3), in ip_port_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin

end //
delimiter ;

-- [3] add_person() -- 1
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at a port, on a ship, or both, at any given
time.  A person must have a first name, and might also have a last name.

A person can hold a crew role or a passenger role (exclusively).  As crew,
a person must have a tax identifier to receive pay, and an experience level.  As a
passenger, a person will have some amount of rewards miles, along with a
certain amount of funds needed to purchase cruise packages. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin

end //
delimiter ;

-- [4] grant_or_revoke_crew_license() -- 1
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a crew member's license.  If the license
doesn't exist, it must be created; and, if it already exists, then it must be removed. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_or_revoke_crew_license;
delimiter //
create procedure grant_or_revoke_crew_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin

end //
delimiter ;

-- [5] offer_cruise()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new cruise.  The cruise can be defined before
a ship has been assigned for support, but it must have a valid route.  And
the ship, if designated, must not be in use by another cruise.  The cruise
can be started at any valid location along the route except for the final stop,
and it will begin docked.  You must also include when the cruise will
depart along with its cost. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_cruise;
delimiter //
create procedure offer_cruise (in ip_cruiseID varchar(50), in ip_routeID varchar(50),
    in ip_support_cruiseline varchar(50), in ip_support_ship_name varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin
	if ip_cruiseID is null then leave sp_main;
	elseif ip_routeID is null then leave sp_main;
	elseif ip_next_time is null then leave sp_main;
    elseif ip_cost is null then leave sp_main;
	elseif ip_routeID not in (select routeID from route) then leave sp_main;
    elseif ip_cruiseID in (select cruiseID from cruise) then leave sp_main;
    elseif ip_support_ship_name in (select support_ship_name from cruise) then leave sp_main;
    end if;
    insert into cruise values (ip_cruiseID, ip_routeID, ip_support_cruiseline, ip_support_ship_name, ip_progress, 'docked', ip_next_time, ip_cost);
end //
delimiter ;

-- [6] cruise_arriving() -- 5
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a cruise arriving at the next port
along its route.  The status should be updated, and the next_time for the cruise 
should be moved 8 hours into the future to allow for the passengers to disembark 
and sight-see for the next leg of travel.  Also, the crew of the cruise should receive 
increased experience, and the passengers should have their rewards miles updated. 
Everyone on the cruise must also have their locations updated to include the port of 
arrival as one of their locations, (as per the scenario description, a person's location 
when the ship docks includes the ship they are on, and the port they are docked at). */
-- -----------------------------------------------------------------------------
drop procedure if exists cruise_arriving;
delimiter //
create procedure cruise_arriving (in ip_cruiseID varchar(50))
sp_main: begin
	declare dist_traveled int default 0;
    declare ip_routeID varchar(50);
    declare ip_progress int;
    declare arrival_port char(3);
    declare port_locationID varchar(50);
    declare ip_legID varchar(50);
    
	if (ip_cruiseID is null or ip_cruiseID not in (select cruiseID from cruise)) then leave sp_main;
    elseif (select ship_status from cruise where cruiseID = ip_cruiseID) like 'docked' then leave sp_main;
    end if;
    
	select progress into ip_progress from cruise where cruiseID = ip_cruiseID;
    select routeID into ip_routeID from cruise where cruiseID = ip_cruiseID;
    select legID into ip_legID from route_path where sequence = ip_progress and routeID = ip_routeID;
    select arrival, distance into arrival_port, dist_traveled from leg where legID = ip_legID;
    select locationID into port_locationID from ship_port where portID = arrival_port;
    
    /* Update ship's status and next_time */
	update cruise set ship_status = 'docked' where cruiseID = ip_cruiseID;
	update cruise set next_time = date_add(next_time, interval 8 hour) where cruiseID = ip_cruiseID;
    
	/* Update crew members experience */
	update crew set experience = experience + 1 where assigned_to = ip_cruiseID;
    
	/* Update passengers royalty miles */
    update passenger set miles = miles + dist_traveled where personID in (select personID from passenger_books where cruiseID = ip_cruiseID);
    
    /* Update passenger and crew members' locations to include port */
	insert into person_occupies(personID, locationID) select personID, port_locationID from crew where assigned_to = ip_cruiseID;
	insert into person_occupies(personID, locationID) select personID, port_locationID from passenger_books where cruiseID = ip_cruiseID;
        
end //
delimiter ;

-- call cruise_arriving('rc_10');

-- [7] cruise_departing() -- 5
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a cruise departing from its current
port towards the next port along its route.  The time for the next leg of
the cruise must be calculated based on the distance and the speed of the ship. The progress
of the ship must also be incremented on a successful departure, and the status must be updated.
We must also ensure that everyone, (crew and passengers), are back on board. 
If the cruise cannot depart because of missing people, then the cruise must be delayed 
for 30 minutes. You must also update the locations of all the people on that cruise,
so that their location is no longer connected to the port the cruise departed from, 
(as per the scenario description, a person's location when the ship sets sails only includes 
the ship they are on and not the port of departure). */
-- -----------------------------------------------------------------------------
drop procedure if exists cruise_departing;
delimiter //
create procedure cruise_departing (in ip_cruiseID varchar(50))
sp_main: begin
	declare dist int default 0;
    declare ip_speed float;
    declare ship_locationID varchar(50);
    declare ip_legID varchar(50);
	declare departure_port char(3);
	declare port_locationID varchar(50);

    -- check if input is null or cruiseID is not valid
    if (ip_cruiseID is null or ip_cruiseID not in (select cruiseID from cruise)) then leave sp_main;
    elseif (select ship_status from cruise where cruiseID = ip_cruiseID) like 'sailing' then leave sp_main;
    end if;
    
    -- ship locationID
	select locationID into ship_locationID from ship s join cruise c 
    on s.cruiselineID = c.support_cruiseline and s.ship_name = c.support_ship_name 
    where c.cruiseID = ip_cruiseID;
	
    -- ship's speed
    select speed into ip_speed from ship s join cruise c 
    on c.support_cruiseline = s.cruiselineID and c.support_ship_name = s.ship_name 
    where c.cruiseID = ip_cruiseID;
    
    -- current leg
    select legID into ip_legID from route_path where sequence = (select progress from cruise where cruiseID = ip_cruiseID) and routeID = (select routeID from cruise where cruiseID = ip_cruiseID);
    select distance into dist from leg where legID = ip_legID;
    select departure into departure_port from leg where legID = ip_legID;
    
    if (
    (select count(*) from person_occupies where locationID = ship_locationID) <> 
    ((select count(personID) from crew where assigned_to = ip_cruiseID) + (select count(personID) from passenger_books where cruiseID = ip_cruiseID))
    ) then 
		update cruise set next_time = date_add(next_time, interval 30 minute) where cruiseID = ip_cruiseID;
		leave sp_main;
	end if;
    
    update cruise set ship_status = 'sailing' where cruiseID = ip_cruiseID;
    update cruise set progress = progress + 1 where cruiseID = ip_cruiseID;
    update cruise set next_time = addtime(next_time, leg_time(dist, ip_speed)) where cruiseID = ip_cruiseID;
    
   delete from person_occupies where locationID = (select locationID from ship_port where portID = departure_port) and personID in (select personID from passenger_books where cruiseID = ip_cruiseID);
   delete from person_occupies where locationID = (select locationID from ship_port where portID = departure_port) and personID in (select personID from crew where assigned_to = ip_cruiseID);
end //
delimiter ;

call cruise_departing('rc_51');


-- [8] person_boards() -- 3
-- -----------------------------------------------------------------------------
/* This stored procedure updates the location for people, (crew and passengers), 
getting on a in-progress cruise at its current port.  The person must be at the same port as the cruise,
and that person must either have booked that cruise as a passenger or been assigned
to it as a crew member. The person's location cannot already be assigned to the ship
they are boarding. After running the procedure, the person will still be assigned to the port location, 
but they will also be assigned to the ship location. */
-- -----------------------------------------------------------------------------
drop procedure if exists person_boards;
delimiter //
create procedure person_boards (in ip_personID varchar(50), in ip_cruiseID varchar(50))
sp_main: begin

end //
delimiter ;

-- [9] person_disembarks() -- 3
-- -----------------------------------------------------------------------------
/* This stored procedure updates the location for people, (crew and passengers), 
getting off a cruise at its current port.  The person must be on the ship supporting 
the cruise, and the cruise must be docked at a port. The person should no longer be
assigned to the ship location, and they will only be assigned to the port location. */
-- -----------------------------------------------------------------------------
drop procedure if exists person_disembarks;
delimiter //
create procedure person_disembarks (in ip_personID varchar(50), in ip_cruiseID varchar(50))
sp_main: begin

end //
delimiter ;

-- [10] assign_crew() -- 3
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a crew member as part of the cruise crew for a given
cruise.  The crew member being assigned must have a license for that type of ship,
and must be at the same location as the cruise's first port. Also, the cruise must not 
already be in progress. Also, a crew member can only support one cruise (i.e. one ship) at a time. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_crew;
delimiter //
create procedure assign_crew (in ip_cruiseID varchar(50), ip_personID varchar(50))
sp_main: begin

end //
delimiter ;

-- [11] recycle_crew() -- 2
-- -----------------------------------------------------------------------------
/* This stored procedure releases the crew assignments for a given cruise. The
cruise must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_cruiseID varchar(50))
sp_main: begin

end //
delimiter ;

-- [12] retire_cruise() -- 2
-- -----------------------------------------------------------------------------
/* This stored procedure removes a cruise that has ended from the system.  The
cruise must be docked, and either be at the start its route, or at the
end of its route.  And the cruise must be empty - no crew or passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_cruise;
delimiter //
create procedure retire_cruise (in ip_cruiseID varchar(50))
sp_main: begin

end //
delimiter ;

-- [13] cruises_at_sea()
-- -----------------------------------------------------------------------------
/* This view describes where cruises that are currently sailing are located. */
-- -----------------------------------------------------------------------------
create or replace view cruises_at_sea (departing_from, arriving_at, num_cruises,
	cruise_list, earliest_arrival, latest_arrival, ship_list) as
select '_', '_', '_', '_', '_', '_', '_';

-- [14] cruises_docked()
-- -----------------------------------------------------------------------------
/* This view describes where cruises that are currently docked are located. */
-- -----------------------------------------------------------------------------
create or replace view cruises_docked (departing_from, num_cruises,
	cruise_list, earliest_departure, latest_departure, ship_list) as 
select l.departure, count(distinct departure), c.cruiseID, c.next_time, c.next_time, s.locationID 
from cruise c
join route_path rp on (c.routeID = rp.routeID and c.progress + 1 = rp.sequence)
join leg l on (rp.legID = l.legID)
join ship s on (c.support_ship_name = s.ship_name)
where c.ship_status like 'docked' and next_time is not null
group by l.departure, s.locationID, c.cruiseID, c.next_time;

-- [15] people_at_sea()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently at sea are located. */
-- -----------------------------------------------------------------------------
create or replace view people_at_sea (departing_from, arriving_at, num_ships,
	ship_list, cruise_list, earliest_arrival, latest_arrival, num_crew,
	num_passengers, num_people, person_list) as
select '_', '_', '_', '_', '_', '_', '_', '_', '_', '_', '_';

-- [16] people_docked()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently docked are located. */
-- -----------------------------------------------------------------------------
create or replace view people_docked (departing_from, ship_port, port_name,
	city, state, country, num_crew, num_passengers, num_people, person_list) as
select '_', '_', '_', '_', '_', '_', '_', '_', '_', '_';

-- [17] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different cruises. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_cruises, cruise_list, port_sequence) as
select '_', '_', '_', '_', '_', '_', '_';

-- [18] alternative_ports()
-- -----------------------------------------------------------------------------
/* This view displays ports that share the same country. */
-- -----------------------------------------------------------------------------
create or replace view alternative_ports (country, num_ports,
	port_code_list, port_name_list) as
select '_', '_', '_', '_';
