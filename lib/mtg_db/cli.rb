require 'mtg_db'
require 'sequel'
require 'thor'

module MtgDb
  class CLI < Thor
    include MtgDb

    desc 'create NAME', 'create an MtG SQLite3 Db with the given NAME'
    long_desc <<-LONGDESC
      `mtg_db create` will download all card information from the Gatherer website
      and build a structured SQLite3 database with this card information loaded.
    LONGDESC
    option :tmp_dir, default: TMP_DIR
    # TODO: Add quiet option option :quiet, :type => :boolean
    def create(name)
      name = File.expand_path(name)
      tmp_dir = File.expand_path(options[:tmp_dir])

      puts "Creating empty database: #{name}"
      MtgDb.create_db(name)

      puts "Downloading all cards to #{tmp_dir}, this will take a while..."
      MtgDb.download_all_cards(tmp_dir)

      puts 'Adding cards to the database...'
      MtgDb.add_all_cards_to_db(name, tmp_dir)

      # Now that all the cards are in the Db, we need to establish
      # relationships between them for the double-faced cards
      puts 'Downloading transformable/double-faced cards...'
      MtgDb.download_double_faced_cards(name, tmp_dir)
      MtgDb.add_double_faced_cards_to_db(name, tmp_dir)
    end

    desc "mangle NAME", "mangle the SQLite3 Db file header"
    def mangle(name)
      name = File.expand_path(name)
      if not MtgDb.is_sqlite3?(name)
        puts "File is either already mangled or not an SQLite3 database: #{name}"
      else
        puts "Mangling the SQLite3 file header"
        MtgDb.mangle(name)
      end
    end
  end
end
