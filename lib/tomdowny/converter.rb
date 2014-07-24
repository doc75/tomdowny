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

    def title
      @doc.title
    end
    
    def output
      @doc.result
    end
  end
end
