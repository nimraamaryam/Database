CREATE TABLE universities (
    id SERIAL PRIMARY KEY,          -- Unique ID for each university
    university_name TEXT NOT NULL,  -- Full name of the university
    university_shortname TEXT NOT NULL UNIQUE, -- Abbreviation/short name
    university_city TEXT NOT NULL   -- City where the university is located
);

-- Step 2: Create Table for Professors
CREATE TABLE professors (
    id SERIAL PRIMARY KEY,          -- Unique ID for each professor
    firstname TEXT NOT NULL,        -- First name of the professor
    lastname TEXT NOT NULL,         -- Last name of the professor
    university_id INT NOT NULL,     -- Foreign key referencing universities
    FOREIGN KEY (university_id)
        REFERENCES universities (id)
        ON DELETE CASCADE           -- Delete professor if university is deleted
);

-- Step 3: Create Table for Organizations
CREATE TABLE organizations (
    id SERIAL PRIMARY KEY,          -- Unique ID for each organization
    organization_sector TEXT NOT NULL -- Sector to which the organization belongs
);

-- Step 4: Create Table for is_affiliated_with (Professors and Organizations)
CREATE TABLE is_affiliated_with (
    professor_id INT NOT NULL,      -- Foreign key referencing professors
    organization_id INT NOT NULL,   -- Foreign key referencing organizations
    function TEXT,                  -- Function or role of the professor in the organization
    PRIMARY KEY (professor_id, organization_id), -- Composite primary key
    FOREIGN KEY (professor_id)
        REFERENCES professors (id)
        ON DELETE CASCADE,          -- Delete affiliation if professor is deleted
    FOREIGN KEY (organization_id)
        REFERENCES organizations (id)
        ON DELETE CASCADE           -- Delete affiliation if organization is deleted
);


INSERT INTO universities (university_name, university_shortname, university_city)
SELECT DISTINCT university, university_shortname, university_city
FROM university_professors;


INSERT INTO professors (firstname, lastname, university_id)
SELECT DISTINCT 
    up.firstname,
    up.lastname,
    u.id AS university_id
FROM university_professors up
JOIN universities u ON up.university_shortname = u.university_shortname;

INSERT INTO organizations (organization_sector)
SELECT DISTINCT organization_sector
FROM university_professors;

-- Update organizations table to ensure unique organization names
ALTER TABLE organizations ADD COLUMN name TEXT UNIQUE;

UPDATE organizations
SET name = up.organization
FROM university_professors up
WHERE organizations.organization_sector = up.organization_sector;



INSERT INTO is_affiliated_with (professor_id, organization_id, function)
SELECT DISTINCT 
    p.id AS professor_id,
    o.id AS organization_id,
    up.function
FROM university_professors up
JOIN professors p 
    ON up.firstname = p.firstname AND up.lastname = p.lastname
JOIN organizations o 
    ON up.organization = o.name;

DELETE FROM universities WHERE university_shortname='EPF'; 

-- View All Universities
SELECT * FROM universities;

-- View All Professors
SELECT * FROM professors;

-- View All Organizations
SELECT * FROM organizations;

-- View All Affiliations
SELECT * FROM is_affiliated_with;

