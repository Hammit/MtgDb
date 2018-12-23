require 'minitest_helper'

# The test case class for running unit tests
# At this stage we don't test file downloading as that is a time consuming and bandwidth heavy process
# Parsing of downloaded files and insertion into the Db happens from test file data
class TestMtgDb < MiniTest::Test
  i_suck_and_my_tests_are_order_dependent!

  TEST_DB_FILENAME = 'test.sqlite3'.freeze

  def test_1_it_has_a_version_number
    refute_nil ::MtgDb::VERSION
  end

  def test_2_db_created
    db = MtgDb.create_db(TEST_DB_FILENAME)
    db_filesize = File.size(TEST_DB_FILENAME)
    db.disconnect
    File.delete(TEST_DB_FILENAME)

    assert_operator db_filesize, :>, 0, 'SQLite3 Db was not initialized correctly'
  end

  def test_3_adding_cards
    MtgDb.create_db(TEST_DB_FILENAME)
    require 'mtg_db/models'

    num_cards_pre_add = MtgDb::Models::Card.count
    MtgDb.add_all_cards_to_db(TEST_DB_FILENAME, 'test/files')
    num_cards_post_add = MtgDb::Models::Card.count

    assert_operator num_cards_post_add, :>, num_cards_pre_add, 'Cards were not added to database'
  end

  # def test_4_downloading_double_faced_cards
  #   # Make sure we have no files downloaded previously
  #   doubled_faced_cards_pre_dl = Dir.glob(
  #     File.join('test', 'files', MtgDb::DOUBLE_FACED_DIR, '*.html')
  #   ).sort
  #
  #   assert_empty doubled_faced_cards_pre_dl, 'Double-Faced download directory is not empty'
  #
  #   # Handle the double-faced cards downloading
  #   MtgDb.download_double_faced_cards(TEST_FILENAME, nil)
  #   doubled_faced_cards_post_dl = Dir.glob(
  #     File.join('test', 'files', MtgDb::DOUBLE_FACED_DIR, '*.html')
  #   ).sort
  #
  #   assert_operator doubled_faced_cards_post_dl.size, :>, doubled_faced_cards_pre_dl.size, 'No double-faceed cards downloaded'
  # end

  def test_5_add_double_faced_cards
    # Don't download the double-faced cards, use the test files instead
    cards_dir = File.join('test', 'files', MtgDb::DOUBLE_FACED_DIR)
    files = Dir.glob(File.join(cards_dir, '*.html')).sort

    refute_empty files, "Couldn't find any double-faced cards to use for testing/inserting into the Db"

    # Add double-faced cards to the db
    require 'mtg_db/models'
    num_cards_pre_add = MtgDb::Models::DoubleFaced.count
    MtgDb.add_double_faced_cards_to_db(TEST_DB_FILENAME, File.join('test', 'files'))
    num_cards_post_add = MtgDb::Models::DoubleFaced.count

    File.delete(TEST_DB_FILENAME)

    assert_operator num_cards_post_add, :>, num_cards_pre_add, "Double-Faced cards weren't added"
  end
end
