
class PR
  attr :contact_first_name, :contact_last_name, :delays, :design_status
  attr :last_bill_submitted_on, :status, :progress, :contract_awarded_on, :title
  attr :environmental_approval_on, :tip_id
  
  def initialize(item_node)
    item_node.keys.each do |key|
      key_name = key.gsub '-', '_'
      instance_variable_set "@#{key_name}", item_node[key]
    end
  end
end

class PrReader
  require 'open-uri'
  require 'nokogiri'
  
  def initialize(filepath)
    @url = filepath
    @xml = open(@url)
    @xml_doc = Nokogiri::XML(@xml)
    @item_nodes = @xml_doc.xpath('/progress-reports/progress-report')
    @items = @item_nodes.map do |node|
      node.elements.reduce({}) do |item, el|
        item[el.name] = el.content.to_s
        item
      end
    end
    @prs = @items.map do|i| 
      PR.new(i)
    end
  end
  
  def render_pr_record(pr)
  <<-REC
  <TR>
    <TD>#{pr.tip_id}</TD>
    <TD>#{pr.title}</TD>
    <TD>#{pr.progress}</TD>
  </TR>
  REC
  end
  
  def render_prs()
    <<-PR
<TABLE><TR><TH>Project ID</TH><TH>Title</TH><TH>Progress</TH></TR>
#{@prs.map {|pr| render_pr_record(pr)}.join "\n"}
</TABLE>   
    PR
  end
    
end

r = PrReader.new('C:\Users\Chris\Documents\Ruby\pr_viewer\progress_reports.xml')
File.open('pr_out.html','w') do |outfile|
  outfile.puts "<HTML><BODY>"
  outfile.puts r.render_prs()
  outfile.puts "</BODY></HTML>"
end