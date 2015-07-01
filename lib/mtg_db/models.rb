require 'sequel'
#require 'logger'
#require 'pry'

module MtgDb
  module Models
    class Card < Sequel::Model
      set_primary_key [:_id]
      many_to_one :type
      many_to_one :supertype
      many_to_one :subtype
      one_to_many :set_versions
      one_to_one :double_faced

      # Take care of assignment to the foreign key
      def supertype=(new_supertype)
        if new_supertype.is_a? String
          value = Supertype.find_or_create(:name => new_supertype)
        end
        super(value)
      end

      # Take care of assignment to the foreign key
      def subtype=(new_subtype)
        if new_subtype.is_a? String
          value = Subtype.find_or_create(:name => new_subtype)
        end
        super(value)
      end

      def is_vanguard?
        self.supertype.name == 'Vanguard'
      end

      def is_planeswalker?
        self.supertype.name == 'Planeswalker'
      end

      # Card.collect {|c| c if c.is_transformable?}.compact
      def is_transformable?
        self.rules =~ /transform/io
      end
    end

    class Supertype < Sequel::Model
      set_primary_key [:_id]
      one_to_many :cards
    end

    class Subtype < Sequel::Model
      set_primary_key [:_id]
      one_to_many :cards
    end

    class CardSet < Sequel::Model(:sets)
      set_primary_key [:_id]
    end

    class Rarity < Sequel::Model
      set_primary_key [:_id]
    end

    class DoubleFaced < Sequel::Model(:double_faced)
      set_primary_key [:_id]
      many_to_one :faceup_card,   :key => :faceup_card_id,   :class=> Card
      many_to_one :facedown_card, :key => :facedown_card_id, :class => Card
    end

    class Planeswalker < Sequel::Model
      set_primary_key [:_id]
      many_to_one :card
    end

    class Vanguard < Sequel::Model
      set_primary_key [:_id]
      many_to_one :card
    end

    class SetVersion < Sequel::Model(:cards_set_versions)
      set_primary_key [:_id]
      many_to_one :card
      many_to_one :card_set, :key => :set_id, :class => CardSet
      many_to_one :rarity
    end

    class NonIntAttribute < Sequel::Model(:non_int_attributes)
      set_primary_key [:_id]
    end
  end
end
