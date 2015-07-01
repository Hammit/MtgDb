# require 'pry'
require 'mechanize'
require 'uri'
require_relative 'constants'

module MtgDb
  module Parsers
    class GathererParser < Mechanize::Page
      include Constants
      DEBUG = false

      attr_reader :cards

      def initialize(uri = nil, response = nil, body = nil, code = nil)
        super(uri, response, body, code)
        @cards = parse_cards
        #p @cards
      end

    private
      # Each page in standard format has a bunch of cards
      def parse_cards
        cards = []
        card_nodes = search('tr.cardItem')
        card_nodes.each do |card_node|
          card = {}
          card[:name]      = name(card_node)
          card[:mana_cost] = mana_cost(card_node)
          card[:cmc]       = cmc(card_node)
          card[:rules]     = rules(card_node)
          card[:power]     = power(card_node)
          card[:toughness] = toughness(card_node)
          card[:set_versions] = set_versions(card_node)

          # Supertype, Subtype, P/T, Loyalty, Hand/Life Modifiers, etc are all stored in the same node
          type_data = type_data(card_node)
          card.merge! type_data

          cards << card
          p card if DEBUG
        end
        cards
      end

      def name(node)
        node.search('span.cardTitle > a').text.strip
      end

      def mana_cost(node)
        img_nodes = node.search('span.manaCost > img')
        mana_costs = img_nodes.collect do |img|
          cost = img['alt']
          # colorless mana cost if no abbreviation exists
          MANA_COST_ABBREVIATIONS[cost] || cost
        end
        mana_costs.join
      end

      def cmc(node)
        node.search('span.convertedManaCost').text.strip
      end

      def type_data(node)
        type_hash = {}
        type_hash[:supertype] = supertype(node)
        type_hash[:subtype] = subtype(node)

        other_data = case type_hash[:supertype]
          when 'Vanguard' then vanguard_data(node)
          when 'Planeswalker' then planeswalker_data(node)
          else {}
        end

        type_hash.merge! other_data
      end

      def vanguard_data(node)
        type_line = node.search('span.typeLine').text

        supertype, part, other = type_line.partition("\r\n")
        matches = other.scan(PT_REGEX)
        hand_modifier, life_modifier = matches[0].compact
        { :hand_modifier => hand_modifier, :life_modifier => life_modifier }
      end

      def planeswalker_data(node)
        loyalty_match = node.search('span.typeLine').text.match(/\( (.*) \)\z/xo)
        loyalty = 0
        if loyalty_match
          loyalty = loyalty_match[1]
        end
        { :loyalty => loyalty }
      end

      # When the supertype is a Vanguard, there is a Hand/Life Modifier and when
      # it's a Planeswalker, there is Loyalty. In either case, no Power/Toughness
      def supertype(node)
        type_line = node.search('span.typeLine').text.strip
        supertype = case type_line
          when /\u2014/ then type_line.split(/\u2014/)[0].strip
          when /\r\n/   then type_line.split("\r\n")[0].strip
          else type_line.strip
        end
      end

      def subtype(node)
        subtype = node.search('span.typeLine').text.split(/\u2014/)[1]
        unless subtype.nil?
          subtype.strip!
          subtype = subtype.partition("\r\n")[0]
        end
        subtype
      end

      def rules(node)
        node.search('div.rulesText').text.strip
      end

      def power(node)
        # '(*/{^2})'.scan(PT_REGEX) => [[nil, nil, nil, nil, "*"], [nil, nil, nil, "{^2}", nil]]
        matches = node.search('span.typeLine').text.scan(PT_REGEX)
        if matches[0]
          matches[0].compact[0]
        else
          nil
        end
      end

      def toughness(node)
        # '(*/{^2})'.scan(PT_REGEX) => [[nil, nil, nil, nil, "*"], [nil, nil, nil, "{^2}", nil]]
        matches = node.search('span.typeLine').text.scan(PT_REGEX)
        if matches[0]
          matches[0].compact[1]
        else
          nil
        end
      end

      def set_versions(node)
        set_versions_node = node.search('.setVersions')
        set_versions = set_versions_node.search('a').collect do |a|
          # multiverse_id
          query_str = URI.parse(a['href']).query
          params_h = URI.decode_www_form(query_str).to_h
          multiverse_id = params_h['multiverseid']

          # set abbreviation e.g. ALA
          img_src = a.search('img').first['src']
          query_str = URI.parse(img_src).query
          params_h = URI.decode_www_form(query_str).to_h
          set_abbreviation = params_h['set']

          # set version, e.g. Planeschase (Common), Shards of Alara (Rare)
          set_version = a.search('img').first['title']
          match = set_version.match(SET_VERSION_REGEX)
          set = match['SET']
          rarity = match['RARITY']

          { :multiverse_id => multiverse_id, :set => set, :rarity => rarity, :set_abbreviation => set_abbreviation }
        end
      end
    end

    # Double-Faced cards have 2x .cardDetails sections, the face-up and face-down cards
    class DoubleFacedCardDetailsParser < Mechanize::Page
      DEBUG = false

      attr_reader :cards, :faceup_card_name, :facedown_card_name

      def initialize(uri = nil, response = nil, body = nil, code = nil)
        super(uri, response, body, code)
        @cards = parse_cards
        @faceup_card_name = @cards.first
        @facedown_card_name = @cards.last
        #p @cards
      end

      private
      
      def parse_cards
        cards = []
        card_nodes = search('.cardDetails')
        # binding.pry
        # Each page has 2 cards if it's transformable
        if card_nodes.size == 2
          face_up_name = name(card_nodes.first)
#           face_up_card = Card.where(:name => face_up_name).first
          cards << face_up_name

          face_down_name = name(card_nodes.last)
#           face_down_card = Card.where(:name => face_down_name).first
          cards << face_down_name
        end
        # p cards if DEBUG

        cards
      end

      def name(node)
        name_row = node.search('div.row')[1]
        name_row.search('div.value').text.strip
      end

      def mana_cost(node)
        mana_cost_row = node.search('div.row')[2]
        img_nodes = mana_cost_row.search('div.value > img')
        cost = Constants::mana_cost(img_nodes)
      end

      def cmc(node)
        cmc_row = node.search('div.row')[3]
        cmc_row.search('div.value').text.strip
      end

      def type_data(node)
        type_row = node.search('div.row')[4]
        type = type_row.search('div.value').text.strip

        type_hash = {}
        type_hash[:supertype] = Constants::supertype(type)
        type_hash[:subtype] = Constants::subtype(type)

        other_data = case type_hash[:supertype]
          when 'Vanguard' then vanguard_data(node)
          when 'Planeswalker' then planeswalker_data(node)
          else {}
        end

        type_hash.merge! other_data
      end

      # When the supertype is a Vanguard, there is a Hand/Life Modifier and when
      # it's a Planeswalker, there is Loyalty. In either case, no Power/Toughness
      def supertype(node)
        type_line = node.search('span.typeLine').text.strip
        supertype = case type_line
          when /\u2014/ then type_line.split(/\u2014/)[0].strip
          when /\r\n/   then type_line.split("\r\n")[0].strip
          else type_line.strip
        end
      end

      def subtype(node)
        subtype = node.search('span.typeLine').text.split(/\u2014/)[1]
        unless subtype.nil?
          subtype.strip!
          subtype = subtype.partition("\r\n")[0]
        end
        subtype
      end
    end

  end
end