module Analytics
  class Report
    METRICS = [ 
      :visitors, :new_visits, :percent_new_visits,
      :visits, :bounces, :pageviews
    ]
    
    DIMENSIONS = [
      :continent, :city, :country, :date, :year, 
      :month, :week, :day, :hour, :page_path
    ]


    attr_reader :id, :access_token

    def initialize(id, access_token, renderer = Analytics::Renderer::Plain)
      @id = id
      @access_token = access_token
      @renderer = renderer
    end

    def get(start_date, end_date, metrics, dimensions = [], start-index = 1, max-results = 1000)
      response = Analytics::Request.new(Analytics::BASE_URL, get_url(start_date, end_date, metrics, dimensions, start-index, max-results), @access_token).response
      return nil unless response["rows"]
      response["rows"].map do |row|
        @renderer.render(row, metrics, dimensions)
      end 
    end

  private
    def get_url(start_date, end_date, metrics, dimensions, start-index, max-results)
      str = "data/ga?ids=ga:#{@id}&start-date=#{start_date.strftime("%F")}&end-date=#{end_date.strftime("%F")}&metrics=#{to_ga(metrics)}"
      str += "&dimensions=#{to_ga(dimensions)}" unless dimensions.empty?
      str += "&start-index=#{start_index}" unless start-index.blank?
      str += "&max-results=#{max-results}" unless max-results.empty?
      str
    end

    def split_by(method, det = 'and')
       method.to_s.split("_#{det}_").map(&:to_sym)
    end

    def to_ga(array)
      array.map { |x| 'ga:' + x.to_s.to_camelcase(:lower) }.join(",")
    end

    def method_missing(m, *args, &block)
      args.flatten!
      if METRICS.include? m.to_sym
        get(args[0],args[1], [m.to_sym])
      elsif m.to_s.split('_by_').length.eql? 2
        lhs, rhs = split_by(m, 'by')
        get(args[0],args[1], split_by(lhs), split_by(rhs))
      elsif split_by(m).length.eql? 2
        get(args[0],args[1], split_by(m), [])
      else
        super
      end
    end
  end
end
