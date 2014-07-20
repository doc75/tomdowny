require 'nokogiri'

module Tomdowny
  class Converter
    def initialize(file)
      @file = file
    end
    
    def run
      @doc = Document.new
      parser = Nokogiri::XML::SAX::Parser.new(@doc)
      parser.parse(File.open(@file))
    end

    def output
      @doc.get_result
    end
  end
end
