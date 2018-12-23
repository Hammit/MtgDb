module MtgDb
  module Constants
    # The key is what is found in standard format pages
    # The value is what it is replaced with in the db (as found in the old spoiler format)
    MANA_COST_ABBREVIATIONS = {
      'White': 'W',
      'Blue': 'U',
      'Black': 'B',
      'Red': 'R',
      'Green': 'G',

      '2 or White': '(2/W)',
      '2 or Blue': '(2/U)',
      '2 or Black': '(2/B)',
      '2 or Red': '(2/R)',
      '2 or Green': '(2/G)',

      'White or Blue': '(W/U)',
      'White or Black': '(W/B)',
      'Blue or Black': '(U/B)',
      'Blue or Red': '(U/R)',
      'Black or Red': '(B/R)',
      'Black or Green': '(B/G)',
      'Red or Green': '(R/G)',
      'Red or White': '(R/W)',
      'Green or White': '(G/W)',
      'Green or Blue': '(G/U)',

      'Phyrexian White': '(W/P)',
      'Phyrexian Blue': '(U/P)',
      'Phyrexian Black': '(B/P)',
      'Phyrexian Red': '(R/P)',
      'Phyrexian Green': '(G/P)',

      'Variable Colorless': 'X',
    }.freeze

    # TODO: See if we can (?DEFINE) subroutines in the regex as per Perl/PCRE
    # http://www.regular-expressions.info/subroutine.html
    # http://www.regular-expressions.info/recursecapture.html
    PT_REGEX = /
      \(?
        (
          (?<INTEGER> [+-]? \d+)
          |
          (?<OPERATOR> [+-])
          |
          (?<FRACTION> \{\d+ \/ \d+ \})
          |
          (?<EXPONENT> \{ \^ \d+ \})
          |
          (?<VARIABLE> \*)
        )
        \/
        (
          (?<INTEGER> [+-]? \d+)
          |
          (?<OPERATOR> [+-])
          |
          (?<FRACTION> \{\d+ \/ \d+ \})
          |
          (?<EXPONENT> \{ \^ \d+ \})
          |
          (?<VARIABLE> \*)
        )
      \)?
    /x

    SET_VERSION_REGEX = /^(?<SET>.*) \((?<RARITY>.*)\)$/o
  end
end