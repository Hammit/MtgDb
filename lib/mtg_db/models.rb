require 'sequel'
# require 'logger'
# require 'pry'

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
          value = Supertype.find_or_create(name: new_supertype)
        end
        super(value)
      end

      # Take care of assignment to the foreign key
      def subtype=(new_subtype)
        if new_subtype.is_a? String
          value = Subtype.find_or_create(name: new_subtype)
        end
        super(value)
      end

      # When power is non-integer (e.g. *), store it in the NonIntAttribute table and use a dummy value in Card table
      def power=(new_power)
        if !new_power.nil?
          if !looks_like_number?(new_power)
            attr = NonIntAttribute.find(original_attribute: new_power)
            if attr.nil?
              card_attribute = -65_535 + NonIntAttribute.all.size
              attr = NonIntAttribute.find_or_create(original_attribute: new_power, card_attribute: card_attribute)
            end
            super(attr.card_attribute)
          else
            super(new_power)
          end
        else
          super(new_power)
        end
      end

      def toughness=(new_toughness)
        return if new_toughness.nil?

        if looks_like_number?(new_toughness)
          super(new_toughness)
        else
          attr = find_or_create_non_int_attribute(new_toughness)
          super(attr.card_attribute)
        end
      end

      def is_vanguard?
        supertype.name == 'Vanguard'
      end

      def is_planeswalker?
        supertype.name == 'Planeswalker'
      end

      # Card.collect {|c| c if c.is_transformable?}.compact
      def is_transformable?
        rules =~ /transform/io
      end

      private

      # Test if the given value is a number or not
      # Used for testing power and toughness, as they are sometimes non-int. e.g. *, {1/2}, etc
      def looks_like_number?(attr)
        return false if attr.nil?

        if attr.match?(/^[+-]?\d+$/)
          true
        else
          false
        end
      end

      # Find or create the NonIntAttribute relevant to the given power or toughness
      def find_or_create_non_int_attribute(attr)
        non_int_attr = NonIntAttribute.find(original_attribute: attr)
        if non_int_attr.nil?
          card_attribute = -65_535 + NonIntAttribute.all.size
          non_int_attr = NonIntAttribute.find_or_create(original_attribute: attr, card_attribute: card_attribute)
        end
        return non_int_attr
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
      many_to_one :faceup_card,   key: :faceup_card_id,   class: Card
      many_to_one :facedown_card, key: :facedown_card_id, class: Card
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
      many_to_one :card_set, key: :set_id, class: CardSet
      many_to_one :rarity
    end

    class NonIntAttribute < Sequel::Model(:non_int_attributes)
      set_primary_key [:_id]
    end
  end
end
