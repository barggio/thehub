module SessionHelper
#SessionHelper.processdata("1c2134ceed9b692a065bd1ed907f252b63178eeab0db50ad175f1f6693a29c4c", "/home/nopparit/workspace/thehub/uploads/1c2134ceed9b692a065bd1ed907f252b63178eeab0db50ad175f1f6693a29c4c_HappyExample.xlsx")

#id = SessionHelper.logsession("1c2134ceed9b692a065bd1ed907f252b63178eeab0db50ad175f1f6693a29c4c")
    def self.processdata(id, path)
        outcome = ExcelHelper.parse(path)
        if (outcome.length > 0) 
            for i in 0..outcome.length-1
                sessionid = logsession(id)
                fieldid = logsessiondef(id, outcome[i][0], outcome[i][1][0][1])
                fields = SqlserverHelper.database_select(nil,"PARIS_REPORTER","dbo","t_columns",["col_id"],nil,"session_id = '#{id}' and page = '#{outcome[i][0]}'", "order by col_seq")
                logsessiondata(fields, outcome[i][1])
                #if (fields.length > 0)
                #   logsession(sessionid)
                #       
                #   logsessiondata(sessionid, fieldid, payload) 
                #end

            end
        end
    end

    def self.logsession(id)
       sessionid = SqlserverHelper.database_insert(
           nil, 
           "PARIS_REPORTER",
           "dbo",
           "t_sessions",
           ["session_id", "user_id"],
           [[id, 'etrudx3']]) 
       sessionid
    end

    def self.logsessiondef(sessionid, page, fields)
        payload = []
        fields.map.with_index do |f,i|
            a = [sessionid,page, i+1, f]
            payload.push(a)
        end
        
        SqlserverHelper.database_insert(
            nil,
            "paris_reporter",
            "dbo",
            "t_columns",
            ["session_id","page", "col_seq","col_name"],
            payload)
    end

    def self.logsessiondata(field_ids, data)
        payload = []
        i = 1
        data.each do |row|
            if (i > 1)
                field_ids.map.with_index do |f,i|
                    a = [f['col_id'], row[0], row[1][i]]
                    payload.push(a)
                    if (payload.length == 100)
                        SqlserverHelper.database_insert(
                            nil,
                            "paris_reporter",
                            "dbo",
                            "t_datastore",
                            ["col_id","row_id","col_value"],
                            payload)
                        payload.clear
                        puts "push 2 DB"
                    end
                end     
            end  
            i = i+1    
        end
        if (payload.length > 0)
            SqlserverHelper.database_insert(
                nil,
                "paris_reporter",
                "dbo",
                "t_datastore",
                ["col_id","row_id","col_value"],
                payload)    
            payload.clear
        end
    end
end
