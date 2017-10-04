module SqlserverHelper
    #Usage: result = SqlserverHelper.database_insert(nil, "PARIS_REPORTER", "dbo", "t_sessions", ["hash","user_id"], [["test","etrudx3"]])
    def self.database_insert(resource, database, schema, table, column_list, content_rows)
        configname = (resource == nil) ?  "sqlserver" : resource 
        config = Rails.configuration.database_configuration[ENV["RAILS_ENV"]][configname]
        client = TinyTds::Client.new username: config['username'], password: config['password'], host: config['host']        
        columns = column_list.map{|f| "[#{f}]"}.join(",")
        contents = content_rows.map{|r| 'SELECT ' + (r.map{|k| "'#{k.to_s.gsub(/['$+,]/,'*')}'"}).join(',') }.join(' UNION ')
        cmdstr = "INSERT INTO #{database}.#{schema}.#{table} ( #{columns} ) #{contents}" 
        result = client.execute(cmdstr) 
        id = result.insert  
        #Be responsible and close :)
        client.close
    end

    #Usage: result = SqlserverHelper.database_select(nil, "PARIS_REPORTER", "dbo", "T_RPT_LEAKAGE_TRACKER", ["SNAP_PD","RID","KPISET"], "top 10", nil)
    #       result is an array of hashes        
    #       result = SqlserverHelper.database_select("appmanage", "POC", "dbo", "Events", ["name", "description"], "top 10", nil)
    def self.database_select(resource, database, schema, table, column_list, limit, condition, order)        
        configname = (resource == nil) ?  "sqlserver" : resource 
        config = Rails.configuration.database_configuration[ENV["RAILS_ENV"]][configname]
        client = TinyTds::Client.new username: config['username'], password: config['password'], host: config['host']        
        columns = column_list.map{|c| "[#{c}]"}.join(",")
        condition = (condition == nil) ? "1 = 1" : condition
        order = (order == nil) ? "" : order 
        limit = (limit == nil) ? "" : limit
        cmdstr = "SELECT #{limit} #{columns} FROM #{database}.#{schema}.#{table} where #{condition} #{order}" 
        puts cmdstr
        result = client.execute(cmdstr) 
        output = []
        result.each do |row|
            output.push(row)
        end
        #Be responsible and close :)
        client.close
        output
    end
    #Usage: result = database_update(nil, "paris_reporter","dbo","t_sessions",["hash"],["1"],nil)
    def self.database_update(resource, database, schema, table, column_list, content_list, condition)        
        configname = (resource == nil) ?  "sqlserver" : resource 
        config = Rails.configuration.database_configuration[ENV["RAILS_ENV"]][configname]
        client = TinyTds::Client.new username: config['username'], password: config['password'], host: config['host']
        i = 0

        keypair = ""
        for i in 0..column_list.length-1 do
            if (keypair == "")
                keypair = "[#{column_list[i]}] = '#{content_list[i].gsub(/['$+,]/,'*')}'"
            else
                keypair = "#{keypair}, [#{column_list[i]}] = '#{content_list[i].gsub(/['$+,]/,'*')}'"                
            end
        end

        condition = (condition == nil) ? "1 = 1" : condition
        cmdstr = "UPDATE #{database}.#{schema}.#{table} SET #{keypair} where #{condition}" 
        result = client.execute(cmdstr)
        output = result.do
        #Be responsible and close :)
        client.close
        output
    end    

    #Usage: result = database_delete(nil, "paris_reporter","dbo","t_sessions",nil)
    def self.database_delete(resource, database, schema, table, condition)        
        configname = (resource == nil) ?  "sqlserver" : resource 
        config = Rails.configuration.database_configuration[ENV["RAILS_ENV"]][configname]
        client = TinyTds::Client.new username: config['username'], password: config['password'], host: config['host']
        condition = (condition == nil) ? "1 = 1" : condition
        cmdstr = "DELETE FROM #{database}.#{schema}.#{table} where #{condition}"        
        result = client.execute(cmdstr)
        output = result.do
        #Be responsible and close :)
        client.close
        output
    end    
end