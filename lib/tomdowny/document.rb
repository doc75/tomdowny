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
    attr_reader :result, :title

    def start_element(name, attrs = [])
      @result    ||= ''
      @chars     ||= []
      @valid     ||= false
      @open_tags ||= []

      @cur_first_elem_line ||= name

      case name
      when 'note-content'
        @valid = true
      when 'title'
        @title = nil
        @result = "#{@result}---
title: "
        @valid = true
      when 'list'
        @level ||= 0
        @level += 1
        @result = "#{@result}\n" if @level == 1  
      when 'list-item'
        indent = '  ' * @level
        @result = "#{@result}#{indent}"
      # TODO: see if we can manage links (not sure we should)
      end

      @result = "#{@result}#{TAGS[name][:open]}" if TAGS[name] && tag_compatible(name)
      @open_tags << name
    end

    def end_element(name)
      case name
      when 'title'
        @valid = false
        @author ||= 'Undefined'
        @date   ||= Time.new.strftime("%Y-%m-%d")
        @result = "#{@result}
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

      @result = "#{@result}#{TAGS[name][:close]}" if TAGS[name] && tag_compatible(name)
    end

    def characters(string)
      newline = string.include?("\n")
      string.gsub!(/`/) { |m| '\\' + m }
      if @valid
        # if ['text', 'list', 'list-item'].include?(@cur_first_elem_line)
        if ['list', 'list-item'].include?(@cur_first_elem_line)
          @result = "#{@result}#{string}"
        else
          @result = "#{@result}#{string.gsub(/\n/, "  \n")}"
        end

        if current_tag == 'title'
          @title = "#{@title}#{string.downcase.gsub(/\s/, '-').gsub(/:/, '_')}"
        end
      end

      # do not manage template notes
      case current_tag
      when 'tag'
        # puts "#{@title}: tag = #{string}"
        if string == 'system:template'
          @title = nil
          @result = nil
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

    private
      def current_tag
        if @open_tags.length > 0
          @open_tags[-1]
        else
          nil
        end
      end

      def tag_compatible tag_name
        if INCOMPATIBILITIES.has_key?(tag_name) && INCOMPATIBILITIES[tag_name].include?(current_tag)
          false
        else
          true
        end
      end
  end
end