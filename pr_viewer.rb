
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
    @items = @item_nodes.map do |node| #@items = array of hashes
      node.elements.reduce({}) do |item, el|
        item[el.name] = el.content.to_s
        item
      end
    end
    @prs = @items.map do|i| 
      PR.new(i)
    end
    @prs.sort!{|x,y| x.tip_id <=> y.tip_id}
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

  def render_page(proj_id, next_proj_id, item)
  <<-PAGE 
  <HTML><BODY>
  <H1>#{item.tip_id}</H1>
  #{item.title}<br>
  <a href="pr_out_#{next_proj_id}.html">next project</a>
  </BODY><HTML>
  PAGE
  end 

  def render_pages()
    @prs.each_with_index do |item, index|
      proj_id = item.tip_id
      index == (@prs.length - 1) ?  next_index = 0 : next_index = index + 1
      next_proj_id = @prs[next_index].tip_id
      File.open('pr_out_' + proj_id + '.html','w') do |outfile|
        outfile.puts render_page(proj_id, next_proj_id, item)
      end
    end
    puts "done!"
  end
    
end

r = PrReader.new('progress_reports.xml')
File.open('pr_out.html','w') do |outfile|
  outfile.puts "<HTML><BODY>"
  outfile.puts r.render_prs()
  outfile.puts "</BODY></HTML>"
end

r.render_pages