module Analytics
  class WebProperty
    attr_reader :id, :name, :account_id, :url

    def initialize(opts, access_token)
      @access_token = access_token
      @id = opts.fetch("id")
      @name = opts.fetch("name")
      @account_id = opts.fetch("accountId")
      @url = opts.fetch("websiteUrl")
    end

    def profiles
      @profiles ||= request_profiles
    end

  private
    def request_profiles
      Analytics::Request.new(Analytics::BASE_URL, "management/accounts/#{@account_id}/webproperties/#{@id}/profiles", @access_token).response["items"].map do |item|
        Analytics::Profile.new(item, @access_token)
      end
    end
  end  
end
