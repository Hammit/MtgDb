require 'thor'
require 'mtg_db'
require 'sequel'

module MtgDb
  class CLI < Thor
    include MtgDb

    desc "create NAME", "create an MtG sqlite3 Db with the given NAME"
    option :tmp_dir, :default => TMP_DIR
    # TODO: Add quiet option option :quiet, :type => :boolean
    def create(name)
      name = File.expand_path(name)
      tmp_dir = File.expand_path(options[:tmp_dir])

      puts "Creating empty database: #{name}"
      MtgDb.create_db(name)

      puts "Downloading all cards to #{tmp_dir}, this will take a while..."
      MtgDb.download_all_cards(tmp_dir)

      puts "Adding cards to the database..."
      MtgDb.add_all_cards_to_db(name, tmp_dir)

      # Now that all the cards are in the Db, we need to establish
      # relationships between them for the double-faced cards
      puts "Downloading transformable/double-faced cards..."
      MtgDb.download_double_faced_cards(name, tmp_dir)
      MtgDb.add_double_faced_cards_to_db(name, tmp_dir)
    end
  end
end 
