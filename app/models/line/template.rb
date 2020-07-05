module Line
  class Template
    attr_reader :carousels, :alt

    def initialize(carousels:, alt: 'えびケイバ')
      @carousels = carousels
      @alt = alt
    end

    def to_hash
      {
          type: 'template',
          altText: "#{alt}の予想が配信されたよ！",
          template: {
              type: 'carousel',
              columns: carousels.map(&:to_hash)
          }
      }.to_hash
    end
  end
end
