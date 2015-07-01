# MtgDb

A ruby (2.1) program that creates an SQLite3 database containing Magic: The Gathering
card information collected from [The Gatherer](http://gatherer.wizards.com/ "The Gatherer").

## Installation

Install it yourself as:

    $ gem install mtg_db

## Usage

    mtg_db create NAME     # create an MtG sqlite3 Db with the given NAME
    mtg_db help [COMMAND]  # Describe available commands or one specific command

## Notes
Downloading card information from [The Gatherer](http://gatherer.wizards.com/ "The Gatherer")
can take a long time. Be prepared to wait a while when creating the db.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mtg_db/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
