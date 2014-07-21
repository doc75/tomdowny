require 'nokogiri'

module Tomdowny
  TAGS = { 'italic'        => { :open => '*',    :close => '*'},
           'bold'          => { :open => '**',   :close => '**'},
           'highlight'     => { :open => '***',  :close => '***'},
           'strikethrough' => { :open => '-',    :close => '-'},
           'monospace'     => { :open => '`',    :close => '`'},
           'size:small'    => { :open => '### ', :close => ' ###'},
           'size:large'    => { :open => '## ',  :close => ' ##'},
           'size:huge'     => { :open => '# ',   :close => ' #'},
           'list-item'     => { :open => '- ',   :close => ''}
         }
  class Document < Nokogiri::XML::SAX::Document
    attr_writer :author

    def start_element(name, attrs = [])
      @output ||= ''
      @chars ||= []
      @valid ||= false

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
      when 'list-item'
        indent = '    ' * @level
        @output = "#{@output}#{indent}"
      # TODO: see if we can manage links (not sure we should)
      end

      @output = "#{@output}#{TAGS[name][:open]}" if TAGS[name]

    end

    def end_element(name)
      case name
      when 'title'
        @valid = false
        @author ||= 'Undefined'
        @date ||= Time.new.strftime("%Y-%m-%d")
        @output = "#{@output}
author: #{@author}
date: 2014-07-21
---

# "
      when 'list'
        @level -= 1
      when 'note-content'
        @valid = false
      end
      @output = "#{@output}#{TAGS[name][:close]}" if TAGS[name]
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