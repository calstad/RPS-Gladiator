require 'nokogiri'
module RPSGladiator
  module XMLTools
    GAME_NS = {"xmlns"=>"http://charlestonaltnet.org/xml/RPS", "xmlns:i"=>"http://www.w3.org/2001/XMLSchema-instance"}
    
    def xpath_query(node, query)
      node.xpath("//game:#{query}", "game" => GAME_NS['xmlns']).text
    end

    def parse_game_xml(raw_xml)
      Nokogiri::XML(raw_xml, nil, 'UTF-8').root
    end

  end
end
