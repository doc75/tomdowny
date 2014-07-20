require 'nokogiri'

module Tomdowny
  class Document < Nokogiri::XML::SAX::Document
    def start_element(name, attrs = [])
      @output ||= ''
      @chars ||= []
      @valid ||= false
      case name
      when 'note-content'
        @valid = true
      when 'title'
        @chars << ''
        @output = "#{@output}# "
      when 'bold'
        @chars << '**'
        @output = "#{@output}#{@chars[-1]}"
      when 'italic'
        @chars << '*'
        @output = "#{@output}#{@chars[-1]}"
      when 'strikethrough'
        @chars << '-'
        @output = "#{@output}#{@chars[-1]}"
      when 'highlight'
        @chars << '***'
        @output = "#{@output}#{@chars[-1]}"
      when 'monospace'
        @chars << '`'
        @output = "#{@output}#{@chars[-1]}"
      when 'size:huge'
        @chars << ' #'
        @output = "#{@output}# "
      when 'size:large'
        @chars << ' ##'
        @output = "#{@output}## "
      when 'size:small'
        @chars << ' ###'
        @output = "#{@output}### "
      when 'list'
        @chars << ''
        @level ||= -1
        @level += 1
      when 'list-item'
        @chars << ''
        indent = '  ' * @level
        @output = "#{@output}#{indent}* "
      # TODO: see if we can manage links (not sure we should)
      end
    end

    def end_element(name)
      @output = "#{@output}#{@chars[-1]}" if @chars.length > 0
      @chars.pop
      case name
      when 'list'
        @level -= 1
      when 'note-content'
        @valid = false
      end
    end

    def characters(string)
      @output = "#{@output}#{string}" if @valid
    end

    def error string
      puts "ERROR: #{string}"
    end

    def warning string
      puts "WARNING: #{string}"
    end

    def get_result
      @output
    end
  end
end