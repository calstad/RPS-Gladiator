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

    def generate_game_xml(template, data=nil)
      render_template(template, data).doc.children.to_xml
    end

    def render_template(template, data)
      case template
      when 'player_move'
        Nokogiri::XML::Builder.new do |xml|
          xml.PlayerMove(XMLTools::GAME_NS) {
            xml.GameId data[:id]
            xml.Move data[:move] }
        end
      when 'registration'
        Nokogiri::XML::Builder.new do |xml|
          xml.Register(XMLTools::GAME_NS)
        end
      end
    end
    
  end
end
