require 'spec_helper'

require 'tomdowny'

describe 'Tomdowny::Document' do

  before :each do
    @input = '<?xml version="1.0" encoding="utf-8"?>
<note version="0.3" xmlns:link="http://beatniksoftware.com/tomboy/link" xmlns:size="http://beatniksoftware.com/tomboy/size" xmlns="http://beatniksoftware.com/tomboy">
<title>RSpec note</title>
<text xml:space="preserve"><note-content version="0.1">RSpec note

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
</list-item><list-item dir="ltr">2nd element</list-item></list>
</note-content></text></note>'
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
"

    @doc = Tomdowny::Document.new
    @parser = Nokogiri::XML::SAX::Parser.new(@doc)
  end

  it 'output Markdown from note' do
    @parser.parse(@input)
    expect(@doc.get_result).to be == @result
  end

  context 'author' do
    it 'allows to set the author' do
      @doc.author = 'R. Spec Junior'
      @parser.parse(@input)
      expect(@doc.get_result).to match(/author: R\. Spec Junior/)
    end

    it 'sets author as Undefined by default' do
      @parser.parse(@input)
      expect(@doc.get_result).to match(/author: Undefined/)
    end
  end

  context 'date' do
    it 'puts the conversion date as date (YYYY-mm-dd)' do
      @parser.parse(@input)
      expect(@doc.get_result).to match(/date: #{@date}/)
    end
  end
end
