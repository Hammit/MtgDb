CREATE TABLE cards (
    _id           INTEGER PRIMARY KEY,
    name          VARCHAR NOT NULL,
    mana_cost     VARCHAR,
    cmc           INTEGER,
    supertype_id  INTEGER,
    subtype_id    INTEGER,
    power         INTEGER,
    toughness     INTEGER,
    rules         TEXT,
    color         VARCHAR(5) DEFAULT NULL
);
CREATE TABLE supertypes (
    _id  INTEGER PRIMARY KEY,
    name VARCHAR NOT NULL UNIQUE
);
CREATE TABLE subtypes (
    _id  INTEGER PRIMARY KEY,
    name VARCHAR UNIQUE
);
CREATE TABLE sets (
    _id          INTEGER PRIMARY KEY,
    name         VARCHAR NOT NULL,
    abbreviation CHAR(3) NOT NULL
);
CREATE TABLE rarities (
    _id          INTEGER PRIMARY KEY,
    name         VARCHAR NOT NULL,
    abbreviation CHAR(1) NOT NULL
);
CREATE TABLE cards_set_versions (
    _id           INTEGER PRIMARY KEY,
    card_id       INTEGER NOT NULL,
    multiverse_id INTEGER NOT NULL,
    set_id        INTEGER NOT NULL,
    rarity_id     INTEGER
);
CREATE TABLE planeswalkers (
    _id           INTEGER PRIMARY KEY,
    card_id       INTEGER NOT NULL,
    loyalty       INTEGER
);
CREATE TABLE vanguards (
    _id           INTEGER PRIMARY KEY,
    card_id       INTEGER NOT NULL,
    hand_modifier INTEGER NOT NULL,
    life_modifier INTEGER NOT NULL
);
CREATE TABLE double_faced (
    _id              INTEGER PRIMARY KEY,
    faceup_card_id   INTEGER NOT NULL UNIQUE,
    facedown_card_id INTEGER NOT NULL UNIQUE
);
CREATE TABLE non_int_attributes (
    _id                INTEGER PRIMARY KEY,
    card_attribute     INTEGER NOT NULL UNIQUE,
    original_attribute VARCHAR NOT NULL UNIQUE
);
