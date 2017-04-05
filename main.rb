#!/usr/bin/env ruby
require 'rfusefs'
require './wikipedia.rb'

class WikiNgFS
  class WikiFileHandle
    attr_accessor :contents, :title, :language

    def initialize(title, language)
      @title = title
      @language = language
    end
  end

  def touch(path, modtime = nil)
    # puts "touch #{path}"
    modtime = Time.now.to_i if ! modtime
    language, title = parse_path(path)
    raise Errno::EPERM if ! language if ! title
    articles = WikiReader.articles(language)
    articles << title if articles && ! articles.include?(title)
  end

  def can_delete?(path)
    # puts "can_delete? #{path}"
    language, title = parse_path(path)
    articles = WikiReader.articles(language)
    title && articles && articles.include?(title)
  end

  def delete(path)
    # puts "delete #{path}"
    language, title = parse_path(path)
    WikiReader.articles(language).delete(title)
  end

  def can_mkdir?(path)
    # puts "can_mkdir? #{path}"
    language, title = parse_path(path)
    language && ! title
  end

  def mkdir(path)
    # puts "mkdir #{path}"
    language, title = parse_path(path)
    WikiReader.db[language] = nil
  end

  def can_rmdir?(path)
    # puts "can_mkdir? #{path}"
    language, title = parse_path(path)
    language && ! title
  end

  def rmdir(path)
    # puts "rmdir #{path}"
    language, title = parse_path(path)
    WikiReader.db.delete(language)
  end


  def contents(path)
    # puts "contents #{path}"
    if path == '/'
      # adds 'wikipedia-' at beginning
      lst = WikiReader.languages.dup
      lst.each_with_index {|v, i| lst[i] = "wikipedia-#{v}"}
      return lst

    else
      language, title = parse_path(path)
      return nil if ! language && ! title # invalid language and title

      if language && ! title # eg: "ls /wikipedia-en"
        lst = WikiReader.articles(language).dup.sort
        lst.each_with_index {|v, i| lst[i] = "#{v}.txt"}
        lst.each {|v| v.gsub!(/^.*(\\|\/)/, '')} # "/" -> "\/"
        return lst
      end
      return [title]
    end
  end

  def file?(path)
    # puts "file? #{path}"
    language, title = parse_path(path)
    !!(language && title)
  end

  def directory?(path)
    # puts "directory? #{path}"
    language, title = parse_path(path)
    language = nil if language && ! WikiReader.languages.include?(language)
    !!(language && !title)
  end

  def can_write?(path)
    # puts "can_write? #{path}"
    false
  end

  def rename(from_path, to_path)
    # puts "rename #{path}"
    delete(from_path)
    touch(to_path)
  end

  def size(path)
    # puts "size #{path}"
    language, title = parse_path(path)
    WikiReader.size(title, language)
  end

  # def read_file(path)
  #   language, title = parse_path(path)
  #   raise Errno::ENOENT if ! language || ! title
  # end

  def raw_open(path, mode, rfusefs = nil)
    # puts "raw_open #{path}"
    language, title = parse_path(path)
    raise Errno::ENOENT if ! language || ! title
    WikiFileHandle.new(title, language)
  end

  def raw_read(path, offset, size, handler = nil)
    # puts "raw_read #{path}"
    raise Errno::EBADF if ! handler
    handler.contents ||= WikiReader.article(handler.title, handler.language)
    handler.contents.b[offset, size]
  end

  def raw_close(path, handler = nil)
    # puts "raw_close #{path}"
    raise Errno::EBADF if ! handler
    handler.contents = nil
  end

  private

  def parse_path(path)
    #######################
    # PATH FORMAT:
    #  /wikipedia-<language>/<title>.txt
    #######################

    # break items: '/wikipedia-en/Titanic.txt' -> ['', 'wikipedia-en', 'Titanic'] -> ['wikipedia-en', 'Titanic']
    items = path.split(File::SEPARATOR)
    items.shift if items.first == ''
    return nil if items.empty? || (items.count > 2)

    # language: 'wikipedia-en' -> 'en'
    pos = items[0].index('wikipedia-')
    return nil if ! pos || (items[0] == 'wikipedia-')
    language = items[0][pos+10..-1]

    # title
    title = nil
    if items[1]
      pos = items[1].index('.txt')
      language = nil if ! pos # invalid file extension
      title = items[1][0, pos] if pos
    end

    # result
    [language, title]
  end
end

# @opts = *ARGV[1..-1]
# FuseFS.mount(WikiNgFS.new, ARGV[0], @opts)
# FuseFS.mount(WikiNgFS.new, ARGV[0])

# wikifs = WikiNgFS.new
# FuseFS.start(wikifs, '/mnt/test')
FuseFS.main() { |options| WikiNgFS.new }
