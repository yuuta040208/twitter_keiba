module Line
  class Carousel
    attr_reader :title, :text, :url

    def initialize(title:, text:, url:)
      @title = title
      @text = text
      @url = url
    end

    def to_hash
      {
          title: title,
          text: text,
          actions: [{type: 'uri', label: 'えびケイバでもっと見る', uri: url}]
      }
    end
  end
end
