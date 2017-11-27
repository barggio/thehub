module HanaHelper
    #Usage: result = HanaHelper.hana_select(profile,url)
    #       result is parsed response in JSON        
    #       result = SqlserverHelper.database_select("appmanage", "POC", "dbo", "Events", ["name", "description"], "top 10", nil)
    def self.hana_select(resource, url)        
        configname = (resource == nil) ?  "hana" : resource 
        config = Rails.configuration.database_configuration[ENV["RAILS_ENV"]][configname]
        uname = config['username']
        pwd = config['password']
        obj = nil
        begin
            payload = HTTParty.get("http://#{uname}:#{pwd}@#{url}")
            obj = payload.parsed_response
        rescue
            obj = nil     
        end
        obj
    end
end