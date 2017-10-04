class mssql_webconnector < data_webconnector

    def select
        site = "http://localhost:64170/Dataconduit.svc/select"
        response = HTTParty.get(site)
    end
    
    def update
    end

    def delete
    end




end