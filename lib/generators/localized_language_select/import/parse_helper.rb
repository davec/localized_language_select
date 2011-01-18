module Import
  module ParseHelper
    def get_code row      
      row.search("td[@class='g']").inner_text.sub('_','-')
    end

    def get_name row
      row.search("td[@class='v']").first.inner_text
    end

    def language_row? row    
      row.search("td[@class='n']") && n_row?(row) && g_row?(row)
    end

    def n_row? row
      row.search("td[@class='n']").inner_html =~ /^nameslanguage$/
    end

    def g_row? row
      row.search("td[@class='g']").inner_html =~ /^[a-z]{2,3}(?:_([A-Z][a-z]{3}))?(?:_([A-Z]{2}))?$/
    end
  end
end