.load ./sqlean/sqlean

CREATE TABLE myvars(
    id INTEGER PRIMARY KEY,
    x INTEGER,
    y INTEGER,
    width INTEGER,
    height INTEGER
);

CREATE TABLE map(
    id INTEGER PRIMARY KEY,
    row TEXT
);

CREATE TABLE antennas(
    id INTEGER PRIMARY KEY,
    frequency TEXT,
    x INTEGER,
    y INTEGER
);

CREATE TABLE antinodes(
    id INTEGER PRIMARY KEY,
    x INTEGER,
    y INTEGER
);

INSERT INTO map (id, row)
    SELECT rowid as id, value as row FROM fileio_scan('@FILEPATH@');

INSERT INTO myvars (id, x, y, width, height) VALUES(
        /* id = */ 1,
         /* x = */ 0,
         /* y = */ 0,
     /* width = */ (SELECT LENGTH(row) FROM map WHERE id = 1),
    /* height = */ (SELECT MAX(id) FROM map)
);

INSERT INTO antennas (frequency, x, y)
-- Get all cells values and their corresponding coordinates
WITH RECURSIVE
    -- Get list of possible y-coordinates
    ys(y) AS
        (VALUES(1) UNION ALL SELECT y+1 FROM ys WHERE y < (SELECT height FROM myvars WHERE id=1)),
    -- Combine y-coordinates with all possible x-coordinates and corresponding cell values
    cells(x, y, c) AS
        (SELECT 1, y, SUBSTR(row, 1, 1)
           FROM ys, map
          WHERE ys.y = map.id
          UNION ALL 
                SELECT x+1, y, SUBSTR(row, x+1, 1)
                  FROM cells, map
                 WHERE cells.y = map.id
                   AND x < (SELECT width FROM myvars WHERE id=1))
SELECT c, x, y FROM cells WHERE c <> '.'; -- Filter for antennas only

-- Get all pairs of antennas that share the same frequency
-- Do not pair up with yourself
-- From these pairs, get antinodes
INSERT INTO antinodes (x, y)
SELECT DISTINCT (2*A.x-B.x) AS x1, (2*A.y-B.y) AS y1
  FROM antennas A, antennas B
 WHERE A.id <> B.id 
   AND A.frequency = B.frequency
   AND x1 >= 1
   AND x1 <= (SELECT width FROM myvars WHERE id=1)
   AND y1 >= 1
   AND y1 <= (SELECT height FROM myvars WHERE id=1);

SELECT COUNT(*) FROM antinodes;