require 'nokogiri'

module Tomdowny
  TAGS = { 'italic'        => { :open => '*',    :close => '*'},
           'bold'          => { :open => '**',   :close => '**'},
           'highlight'     => { :open => '***',  :close => '***'},
           'strikethrough' => { :open => '-',    :close => '-'},
           'monospace'     => { :open => '`',    :close => '`'},
           'size:small'    => { :open => "\n### ", :close => ' ###'},
           'size:large'    => { :open => "\n## ",  :close => ' ##'},
           'size:huge'     => { :open => "\n# ",   :close => ' #'},
           'list-item'     => { :open => '- ',   :close => ''}
         }
  FONT_FORMATTING = ['italic', 'bold', 'highlight', 'strikethrough', 'monospace']
  INCOMPATIBILITIES = { 'size:small' => FONT_FORMATTING,
                        'size:large' => FONT_FORMATTING,
                        'size:huge'  => FONT_FORMATTING }

  class Document < Nokogiri::XML::SAX::Document
    attr_writer :author

    def start_element(name, attrs = [])
      @output    ||= ''
      @chars     ||= []
      @valid     ||= false
      @open_tags ||= []

      @cur_first_elem_line ||= name

      case name
      when 'note-content'
        @valid = true
      when 'title'
        @output = "#{@output}---
title: "
        @valid = true
      when 'list'
        @level ||= 0
        @level += 1
        @output = "#{@output}\n" if @level == 1  
      when 'list-item'
        indent = '  ' * @level
        @output = "#{@output}#{indent}"
      # TODO: see if we can manage links (not sure we should)
      end

      if TAGS[name]
        if @open_tags.length && (!INCOMPATIBILITIES.has_key?(name) || !INCOMPATIBILITIES[name].include?(@open_tags[-1]))
          @output = "#{@output}#{TAGS[name][:open]}"
        end
      end
      @open_tags << name
    end

    def end_element(name)
      case name
      when 'title'
        @valid = false
        @author ||= 'Undefined'
        @date   ||= Time.new.strftime("%Y-%m-%d")
        @output = "#{@output}
author: #{@author}
date: #{@date}
---

# "
      when 'list'
        @level -= 1
      when 'note-content'
        @valid = false
      end

      @open_tags.pop

      if TAGS[name]
        if @open_tags.length && (!INCOMPATIBILITIES.has_key?(name) || !INCOMPATIBILITIES[name].include?(@open_tags[-1]))
          @output = "#{@output}#{TAGS[name][:close]}"
        end
      end
    end

    def characters(string)
      newline = string.include?("\n")
      if @valid
        if ['text', 'list', 'list-item'].include?(@cur_first_elem_line)
          @output = "#{@output}#{string}"
        else
          @output = "#{@output}#{string.gsub(/\n/, "  \n")}"
        end
      end
      @cur_first_elem_line = nil if newline
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