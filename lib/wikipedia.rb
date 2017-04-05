class WikiReader
  # Libraries
  require 'openssl'
  require 'httpclient'
  require 'nokogiri'

  # HTTP
  @@http = HTTPClient.new

  # Our database
  #   Format: @db = {'en' => ['link_a', 'link_b', ...], 'pt' => ['link_c', ...]}
  #   A language with a "nil" value means it wasn't initialized yet and we should
  #    call fetch_vital before use it
  @@db = nil
  @@sizes = {}

  # all articles in memory
  def self.articles(language = 'en')
    return nil if ! db.key?(language) # invalid language
    db[language] = fetch_vital(language) if ! db[language] # not initialized

    db[language]
  end

  def self.languages
    db.keys
  end

  def self.article(title, language = 'en')
    raise Errno::ENOENT if ! db.key?(language) # invalid language
    db[language] = fetch_vital(language) if ! db[language] # not initialized

    art = fetch_article(title, language) # read from the internet
    raise Errno::ENOENT if ! art
    db[language] << title if art && ! db[language].index(title) # adds in our list

    @@sizes[language] ||= {}
    @@sizes[language][title] = art.bytesize

    art
  end

  def self.size(title, language = 'en')
    @@sizes[language] ||= {}
    @@sizes[language][title] || 1
  end

  def self.db
    return @@db if @@db
    @@db = Hash[fetch_languages.collect { |item| [item, nil] }]
  end

  private

  def self.fetch_article(title, language = 'en')
    begin
    url = "https://#{language}.wikipedia.org/wiki/#{URI::encode(title)}?action=raw"
    @@http.get_content(url)
    rescue => e
      puts e
      nil
    end
  end

  def self.fetch_languages
    # hardcoded list (used as fallback)
    default = [
      'en', 'ceb', 'sv', 'de', 'nl', 'fr', 'ru', 'it', 'es', 'war', 'pl', 'vi',
      'ja', 'pt', 'zh', 'uk', 'ca', 'fa', 'ar', 'no', 'sh', 'fi', 'hu', 'id',
      'cs', 'ko', 'ro', 'sr', 'tr', 'ms', 'eu', 'eo', 'bg', 'da', 'min', 'kk',
      'hy', 'sk', 'zh-min-nan', 'he', 'lt', 'hr', 'ce', 'et', 'sl', 'be', 'gl',
      'nn', 'el', 'uz', 'la', 'simple', 'vo', 'ur', 'hi', 'az', 'th', 'ka'
    ]

    # fetch from the internet
    lst = nil
    begin
    url = 'https://meta.wikimedia.org/wiki/List_of_Wikipedias'
    doc = Nokogiri::HTML(@@http.get_content(url))
    lst  = doc.at_css('[id="1_000_000.2B_articles"]').xpath('./ancestor::h3')[0].next.next.children.xpath('td[4]').map {|e| e.text}
    lst += doc.at_css('[id="100_000.2B_articles"]').xpath('./ancestor::h3')[0].next.next.children.xpath('td[4]').map {|e| e.text}
    rescue
    end

    # uses default list if theres no results
    lst = (lst.class == Array) && lst.any? ? lst : default
    lst[0, 15]
  end

  def self.fetch_vital(language = 'en')
    lst = []

    begin
    url = 'https://en.wikipedia.org/wiki/Wikipedia:Vital_articles'
    doc = Nokogiri::HTML(@@http.get_content(url))

    # not english, click on "Languages" section (left column)
    if language != 'en'
      link = doc.at_css("a.interlanguage-link-target[lang='#{language}']")
      return [] if ! link
      url = link.attribute('href')
      doc = Nokogiri::HTML(@@http.get_content(url))
      return [] if ! doc
    end

    # get all links starting with "/wiki/" and with no class (it will get some extra non-vital articles, but it's ok)
    lst = doc.xpath('//li/a[not (@class)][starts-with(@href, "/wiki/")]').map do |e|
      href = e.attribute('href').text[6..-1] # remove initial '/wiki/'
      href = URI::decode(href) # convert non-ascii chars
      pos = href.index('#')
      href = href[0, href.index('#')] if pos # remove anchor
      href
    end

    lst.uniq!

    rescue
    end # rescue

    lst
  end

end
