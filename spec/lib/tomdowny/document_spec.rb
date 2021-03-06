# -*- encoding : utf-8 -*-
require 'spec_helper'

require 'tomdowny'

describe 'Tomdowny::Document' do

  before :each do
    @header = '<?xml version="1.0" encoding="utf-8"?>
<note version="0.3" xmlns:link="http://beatniksoftware.com/tomboy/link" xmlns:size="http://beatniksoftware.com/tomboy/size" xmlns="http://beatniksoftware.com/tomboy">
<title>RSpec note</title>
<text xml:space="preserve"><note-content version="0.1">RSpec note
'
    @body = '
<link:internal>Link Internal</link:internal>
<link:url>Link Url</link:url>
<link:broken>Link broken</link:broken>
<size:small>Small Text</size:small>
<size:large>Large Text</size:large>
<size:huge>Huge Text</size:huge>
<italic>Italic Text</italic>
<bold>Bold Text</bold>
<highlight>Highlight Test</highlight>
<strikethrough>Strikethrough Text</strikethrough>
<monospace>Monospace Text</monospace>
<list><list-item dir="ltr">1st element
</list-item><list-item dir="ltr">2nd element
<list><list-item dir="ltr">1st sub list
<list><list-item dir="ltr">1st sub sub list</list-item></list>
</list-item><list-item dir="ltr">2nd sub list</list-item></list></list-item></list>
'
    @footer = '</note-content></text></note>'
    @input = @header + @body + @footer

    @date = Time.new.strftime("%Y-%m-%d")
    @result = "---
title: RSpec note
author: Undefined
date: #{@date}
---

# RSpec note  
  
Link Internal  
Link Url  
Link broken  

### Small Text ###  

## Large Text ##  

# Huge Text #  
*Italic Text*  
**Bold Text**  
***Highlight Test***  
-Strikethrough Text-  
`Monospace Text`  

  - 1st element
  - 2nd element
    - 1st sub list
      - 1st sub sub list
    - 2nd sub list
"

    @doc = Tomdowny::Document.new
    @parser = Nokogiri::XML::SAX::Parser.new(@doc)
  end

  it 'output Markdown from note' do
    @parser.parse(@input)
    expect(@doc.result).to be == @result
  end

  # it 'output the expected result from sample note' do
  #   input = '<?xml version="1.0" encoding="utf-8"?>\n<note version="0.3" xmlns:link="http://beatniksoftware.com/tomboy/link" xmlns:size="http://beatniksoftware.com/tomboy/size" xmlns="http://beatniksoftware.com/tomboy">\n  <title>Test Note</title>\n  <text xml:space="preserve"><note-content version="0.1">Test Note\n\nStandard text\n\n<bold>Bold Text</bold>\n<italic>Italic Text</italic>\n<strikethrough>Strikethrough Text</strikethrough>\n<highlight>Hihglighted Text</highlight>\n<monospace>Monospace Text</monospace>\n\n<size:small>Small Text</size:small>\nNormal Text\n<size:large>Big Text</size:large>\n<size:huge>Huge Text</size:huge>\n\nBefore List Text\n<list><list-item dir="ltr">List Text\n<list><list-item dir="ltr">Sub List Text\n<list><list-item dir="ltr">Sub Sub List Text\n<list><list-item dir="ltr">Sub sub sub List Text\n<list><list-item dir="ltr">Sub sub sub sub List Text\n<list><list-item dir="ltr">Sub sub sub sub sub List Text\n</list-item></list></list-item><list-item dir="ltr">Re-Sub sub sub sub List Text\n</list-item></list></list-item><list-item dir="ltr">Re-Sub sub sub List Text\n</list-item></list></list-item><list-item dir="ltr">Re-Sub Sub List Text\n</list-item></list></list-item><list-item dir="ltr">Re-Sub List Text\n</list-item></list></list-item><list-item dir="ltr">Re-List Text</list-item></list>\nAfter Re-List Text\n\nStrange Cases\n\n\n<italic><size:small>Small Italic</size:small></italic>\n<bold><size:large>Big Bold</size:large></bold>\n<size:huge><monospace>Huge Monospace</monospace></size:huge>\n<highlight><size:small>Small Highlighted</size:small></highlight>\n<strikethrough><size:large>Big Strikethrough</size:large></strikethrough>\n\n<highlight><size:small>Small Highlighted <bold>Bold</bold></size:small></highlight>\n\n<list><list-item dir="ltr">List with <bold>Bold</bold> Text\n<list><list-item dir="ltr">List with <italic>Italic</italic> Text</list-item></list></list-item></list>\n\n</note-content></text>\n  <last-change-date>2014-07-22T21:31:00.2568980+02:00</last-change-date>\n  <last-metadata-change-date>2014-07-22T21:31:00.2586430+02:00</last-metadata-change-date>\n  <create-date>2014-07-22T21:22:56.1817380+02:00</create-date>\n  <cursor-position>588</cursor-position>\n  <selection-bound-position>588</selection-bound-position>\n  <width>450</width>\n  <height>360</height>\n  <x>0</x>\n  <y>0</y>\n  <open-on-startup>False</open-on-startup>\n</note>'
  #   output = 
  # end

  context 'author' do
    it 'allows to set the author' do
      @doc.author = 'R. Spec Junior'
      @parser.parse(@input)
      expect(@doc.result).to match(/author: R\. Spec Junior/)
    end

    it 'sets author as Undefined by default' do
      @parser.parse(@input)
      expect(@doc.result).to match(/author: Undefined/)
    end
  end

  context 'date' do
    it 'puts the conversion date as date (YYYY-mm-dd)' do
      @parser.parse(@input)
      expect(@doc.result).to match(/^date: #{@date}$/)
    end
  end

  context 'title' do
    it 'puts the title in downcase' do
      @parser.parse(@input)
      expect(@doc.title.downcase).to be == @doc.title
    end

    it 'replace : by _ in title' do
      @parser.parse(@input.gsub(/RSpec note/, 'RSpec : note'))
      expect(@doc.title).to be == 'rspec-_-note' 
    end

    it 'replace space by -' do
      @parser.parse(@input)
      expect(@doc.title).to be == 'rspec-note'
    end

    it 'manage french characters' do
      header = '<?xml version="1.0" encoding="utf-8"?>
<note version="0.3" xmlns:link="http://beatniksoftware.com/tomboy/link" xmlns:size="http://beatniksoftware.com/tomboy/size" xmlns="http://beatniksoftware.com/tomboy">
<title>RSpéc note</title>
<text xml:space="preserve"><note-content version="0.1">RSpec note
'
      @parser.parse(header + @body + @footer)
      expect(@doc.title).to be == 'rspéc-note'
    end
  end

  context 'prevents Hx syntax inside' do
    it 'italic' do
      note = "#{@header}<italic><size:small>Small Italic</size:small></italic>#{@footer}"
      @parser.parse(note)
      expect(@doc.result).to match(/^\*Small Italic\*$/)
    end

    it 'bold' do
      note = "#{@header}<bold><size:large>Big Bold</size:large></bold>#{@footer}"
      @parser.parse(note)
      expect(@doc.result).to match(/^\*\*Big Bold\*\*$/)

    end

    it 'highlighted' do
      note = "#{@header}<highlight><size:small>Small Highlighted</size:small></highlight>#{@footer}"
      @parser.parse(note)
      expect(@doc.result).to match(/^\*\*\*Small Highlighted\*\*\*$/)
    end

    it 'strikethrough' do
      note = "#{@header}<strikethrough><size:large>Big Strikethrough</size:large></strikethrough>#{@footer}"
      @parser.parse(note)
      expect(@doc.result).to match(/^-Big Strikethrough-$/)
    end

    it 'monospace' do
      note = "#{@header}<monospace><size:huge>Huge Monospace</size:huge></monospace>#{@footer}"
      @parser.parse(note)
      expect(@doc.result).to match(/^`Huge Monospace`$/)
    end
  end

  context 'valid font formatting mix' do
    it 'allows italic inside bold' do
      note = "#{@header}<bold>Bold <italic>Italic</italic> Bold</bold>#{@footer}"
      @parser.parse(note)
      expect(@doc.result).to match(/^\*\*Bold \*Italic\* Bold\*\*$/)
    end

    it 'allows bold inside italic' do
      note = "#{@header}<italic>Italic <bold>Bold</bold> Italic</italic>#{@footer}"
      @parser.parse(note)
      expect(@doc.result).to match(/^\*Italic \*\*Bold\*\* Italic\*$/)
    end

  end

  context 'special characters in note' do
    it 'replaces ` by \`' do
      note = "#{@header}<italic>This is a `backtick`</italic>#{@footer}"
      @parser.parse(note)
      expect(@doc.result).to match(/^\*This is a \\`backtick\\`\*$/)
    end
  end

  context 'template note exclusion' do
    before :each do
      @footer = '</note-content></text>
  <tags>
    <tag>system:template</tag>
  </tags>
</note>'
      @input = "#{@header}This is a template note#{@footer}"
    end

    it 'returns a nil title' do
      @parser.parse(@input)
      expect(@doc.title).to be nil
    end

    it 'returns a nil content' do
      @parser.parse(@input)
      expect(@doc.result).to be nil
    end 
  end
end
