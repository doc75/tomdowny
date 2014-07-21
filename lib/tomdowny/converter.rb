require 'nokogiri'

module Tomdowny
  class Converter
    def initialize(file, author = nil)
      @file   = file
      @author = author
    end
    
    def run
      @doc   = Document.new
      @doc.author = @author if @author
      parser = Nokogiri::XML::SAX::Parser.new(@doc)
      parser.parse(File.open(@file))
    end

    def output
      @doc.get_result
    end
  end
end
