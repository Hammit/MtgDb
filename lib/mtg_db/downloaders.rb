require 'fileutils'
require 'mechanize'

module MtgDb
  module Downloaders
    class DownloaderBase
      DEFAULT_OUTPUT_DIR = 'output'.freeze
      attr_reader :agent
      attr_accessor :output_dir

      def initialize(options = {})
        @agent = Mechanize.new
        @agent.pluggable_parser.default = Mechanize::FileSaver
        @output_dir = options[:output_dir] || DEFAULT_OUTPUT_DIR

        prepare_output_dir
      end

      def prepare_output_dir
        unless @output_dir.nil? || Dir.exist?(@output_dir)
          FileUtils.mkpath @output_dir
        end
      end

      def is_empty?
        html_files = File.join(@output_dir, '*.html')
        Dir.glob(html_files).empty?
      end

      def start
        raise NotImplementedError
      end
    end

    # Downloads the entire collection of cards in 'Standard' format
    class AllCardsStandardDownloader < DownloaderBase
      DEBUG = true
      ALL_CARDS_URL = 'http://gatherer.wizards.com/Pages/Search/Default.aspx?action=advanced&output=standard&special=true&cmc=|%3E=[0]'

      def start
        page_num = 1
        page = @agent.get(ALL_CARDS_URL)
        last_page = false
        until last_page
          page_num_str = page_num.to_s.rjust(3, '0')
          save_filename = File.join(@output_dir, "page.#{page_num_str}.html")
          puts "Saving to #{save_filename}" if DEBUG
          page.save(save_filename)
          begin
            page = @agent.page.links.find { |l| l.text == ' >' }.click
          rescue NoMethodError
            # `find` returns nil when the link can't be found
            last_page = true
          end
          page_num += 1
        end
      end

      def files
        Dir.glob(File.join(@output_dir, 'page.*.html')).sort
      end
    end

    # Download a detailed card page given the card's multiverse_id param
    # Useful for double-faced cards, where we can associate the face-up and face-down cards, both on this page
    class CardDetailsDownloader < DownloaderBase
      DEBUG = true
      CARD_DETAILS_URL = 'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=<PARAM_0>'.freeze

      def start(card_name, card_multiverse_id)
        url = CARD_DETAILS_URL
        details_url = url.sub '<PARAM_0>', card_multiverse_id.to_s

        page = @agent.get(details_url)
        page_str = card_name
        save_filename = File.join(@output_dir, "#{page_str}.html")
        puts "Saving to #{save_filename}" if DEBUG
        page.save(save_filename)
      end
    end
  end
end