#require 'helper'
class ActionsController < ApplicationController
  before_action :auth_user
  
    def new
      binding.pry
      #Trapping stray route
    end
    def display_catalog
      # DONE: grab real dataset list
      @objs = get_catalog
    end
    
    def get_catalog
      #objs = []

      objs = SqlserverHelper.database_select("gfa_reports", "PARIS_REPORTER", "dbo", "t_workspaces" ,["wid","description"], " top 10 ", " wid not in ('1fd0cf795c80168068a4902a9e73eb92')", " order by crte_dt desc")

      #obj = {"name": "Leakage Information", "id": "de24c0820149eff4749cfb57e20552ee"}
      #objs.push(obj)
      objs
    end

    def view_dataset
      session_id = params['session']
      # DONE: grab data from database
      data = SqlserverHelper.database_sp("gfa_reports", "PARIS_REPORTER", "dbo", "usp_get_session_data", [session_id])
      render json: data
    end

    def delete_dataset
      session_id = params['session']
      # DONE: send to database      
      result = SqlserverHelper.database_delete("gfa_reports", "PARIS_REPORTER", "dbo", "t_workspaces", " wid = '#{session_id}'")        
      # DONE: grab new list
      @objs = get_catalog
      render 'display_catalog'
    end

    def show
      binding.pry
      #Trapping stray routes
    end

    def display_data
      arrCols1 = (1..50).map(){|i| "i#{i}"}.map(){|i| params[i]}.select{|v| v != nil}
      arrCols2 = (1..50).map(){|i| "j#{i}"}.map(){|i| params[i]}.select{|v| v != nil}
      arrFinal = arrCols1 + arrCols2
      wid = SessionHelper.get_latest_session("gfa_reports",@user.email)
      outcome = arrFinal.map.with_index {|value,index| [wid, index, value]}
      result = SqlserverHelper.database_insert("gfa_reports", "PARIS_REPORTER", "dbo", "t_session_collist", ["session_id","sequence","col_id"], outcome)
      # Long processing
      # DONE: load Data definition
      tabname = "udf_get_datasource_extract_info('#{wid}')"      
      srcs = SqlserverHelper.database_select("gfa_reports", "PARIS_REPORTER", "dbo", tabname,["sequence","src_id" ,"type","server","database","schema","entity","url","filter","filter_clause"], nil, nil, nil)
      # DONE: load Data
      srcs.each do |src|
        # DONE: grab all columns definition
        cols = SqlserverHelper.database_select("gfa_reports", "PARIS_REPORTER", "dbo", "t_datasource_fields",["colname","ordinal"],nil, " srcid = #{src['src_id']}",nil)
        cols = cols.sort_by{|s| s["ordinal"]}
        if (src["type"] == "HANA")
          # Call web service
          #url = YAML.load_file("#{Rails.root}/config/hana_config.yml")[ENV["RAILS_ENV"]]["items"]["url"]
          #info = HanaHelper.hana_select("hana", url)
          #payload_data = info["results"].map(){|r| [wid, src["sequence"]] + r.values}
          payload_data = []
          payload_col = cols.map{|c| "col#{c["ordinal"]}"}
          payload_col = ["session_id", "sequence"] + payload_col  
          #payload_data.each_slice(200){|c| SqlserverHelper.database_insert("gfa_reports", "PARIS_REPORTER", "dbo", "t_session_data", payload_col , c)}
          
        end
        if (src["type"] == "MSSQL")
          clause = nil
          if src['filter_clause'] != nil
            clause = src['filter_clause']
          end
          slots = SqlserverHelper.database_select("gfa_reports", src['database'], src['schema'], src['entity'],cols.map(){|c| c["colname"]}, nil,  clause,nil)
          payload_data = slots.map(){|r| [wid, src["sequence"]] + r.values}
          payload_col = cols.map{|c| "col#{c["ordinal"]}"}
          payload_col = ["session_id", "sequence"] + payload_col  
          #binding.pry 
          payload_data.each_slice(200){|c| SqlserverHelper.database_insert("gfa_reports", "PARIS_REPORTER", "dbo", "t_session_data", payload_col , c)}
          #result = SqlserverHelper.database_insert("gfa_reports", "PARIS_REPORTER", "dbo", "t_session_data", payload_col , payload_data)
          #binding.pry
        end
      end

      # DONE: Display data
      @objs = get_catalog
      render 'display_catalog'
    end

    # Route: show UI for choosing Type do data
    def display_choose_type
      @session = Workspace.new
      sessionid = SecureRandom.hex 16
      @session.wid = sessionid
      @session.description = "NA"
      @session.userid = @user.email
      @session.isshared = false
      result = SqlserverHelper.database_insert("gfa_reports", "PARIS_REPORTER", "dbo", "t_workspaces", ["wid","user_id", "description"], [[sessionid ,@user.email,  "NA"]])
    end

    # Route: show UI for choosing source(s)
    def display_source_selection
      # clear t_session_src
      @multiple = false
      if (params["multiple"] == "multiple")
        @multiple = true
      end
      result = SqlserverHelper.database_select("gfa_reports", "PARIS_REPORTER", "dbo", "t_datasources",["id","name","type"], nil,  "isvalid = 1", nil)
      @choices = result.map() {|p| [ "#{p['type']} - #{p['name']}", p['id'] ] }
      @wid = SessionHelper.get_latest_session("gfa_reports",@user.email)
      #@sessions = Workspace.where(userid: @user.email)
      #@session = @sessions.order(:id ).last
      @parts = Trx.new      
    end

    # Route: show UI 
    def display_logic
      @wid = params['wid']
      src1 = nil
      src2 = nil
      
      var = params.require(:trx).permit(:trx1, :trx2)
      src1 = var[:trx1]
      src2 = var[:trx2]
      arrSrcs = []
      arrSrcs.push([@wid, 1, src1])
      if (src2 != nil)
        arrSrcs.push([@wid, 2, src2])
      end
      # reset selection
      result = SqlserverHelper.database_delete("gfa_reports", "PARIS_REPORTER","dbo","t_session_srcs", "session_id = '#{@wid}'")
      # DONE: commit data to database
      result = SqlserverHelper.database_insert("gfa_reports", "PARIS_REPORTER", "dbo", "t_session_srcs", ["session_id","sequence", "src_id"], arrSrcs)
      # Extract the session id
      @src1    = src1

      @parts = Trx.new      
      if (src2 == nil)
        render 'display_data_selection'
      else
        # DONE: Grab columns for source 1 & 2
        @src2    = src2
        result1 = SqlserverHelper.database_select("gfa_reports", "PARIS_REPORTER", "dbo", "t_datasource_fields",["id","colname"], nil,  "isvalid = 1 and srcid = #{src1}", nil)
        result2 = SqlserverHelper.database_select("gfa_reports", "PARIS_REPORTER", "dbo", "t_datasource_fields",["id","colname"], nil,  "isvalid = 1 and srcid = #{src2}", nil)
        @choices1 =  result1.map(){|i| [i["colname"], i["id"]]}
        @choices2 =  result2.map(){|i| [i["colname"], i["id"]]}
        render 'display_merge_criteria'
      end
    end

    # Show UI for selecting fields
    def display_data_selection
      @wid = params["wid"]
      var = params.require(:trx).permit(:trx1, :trx2, :trx3, :trx4)
      # Get source 1 and 2
      srcs = SqlserverHelper.database_select("gfa_reports", "PARIS_REPORTER", "dbo", "t_session_srcs",["sequence","src_id"], nil,  " session_id = '#{@wid}'", nil)
      @multiple = false
      @col1 = var[:trx1]
      @col2 = var[:trx2]
      @jtype = var[:trx3]
      @filter = var[:trx4]
      # DONE: commit join values
      result = SqlserverHelper.database_insert("gfa_reports", "PARIS_REPORTER", "dbo", "t_session_merge_info", ["session_id","col_id1", "col_id2", "filter"], 
      [[@wid, @col1, @col2, @filter]])

      src1 = srcs.select{|s| s["sequence"] == 1}.first["src_id"]
      result1 = SqlserverHelper.database_select("gfa_reports", "PARIS_REPORTER", "dbo", "t_datasource_fields",["ordinal", "id","colname"], nil,  "isvalid = 1 and srcid = #{src1}", nil)
      @choices1 =  result1.map(){|i| [i["ordinal"], i["colname"], i["id"]]}

      if (srcs.count > 1)
        @multiple = true
        src2 = srcs.select{|s| s["sequence"] == 2}.first["src_id"]
        result2 = SqlserverHelper.database_select("gfa_reports", "PARIS_REPORTER", "dbo", "t_datasource_fields",["ordinal", "id","colname"], nil,  "isvalid = 1 and srcid = #{src2}", nil)
        @choices2 =  result2.map(){|i| [i["ordinal"], i["colname"], i["id"]]}
      end

      @parts = Trx.new
    end

    #--------ITEM SUBSTITUTION------------------------------------#
    def itemsub_listing
        @url = YAML.load_file("#{Rails.root}/config/tableauview.yml")[ENV["RAILS_ENV"]]["item_sub"]["itemsub_listing"]
    end
    # Route: UI for inputing upload information
    def upload_file
      #Load upload view
      #render the view "upload_file"
    end

    # Route: Process upload data
    def process_file
      #Load data into database
      #binary = ::File.open(path, 'rb'){|file| file.read}
      file = params[:content]    
      if !file.blank?
        orig = file.original_filename
        token = SecureRandom.hex(32)
        path = "#{Rails.root}/uploads/#{token}_#{orig}"
        FileUtils.cp file.path, path
        # Log to database about
        SessionHelper.processdata(@user.email, token, path)
      end
      #redirect_to actions_display_summary_path
      @session = token
      itemsub_validate(@session)
      @filename = orig
      @url = YAML.load_file("#{Rails.root}/config/tableauview.yml")[ENV["RAILS_ENV"]]["item_sub"]["upload_validation"]
      @url = "#{@url}?SESSION_ID=#{@session}"
      # 192f3bc870cc75eb3214189163c31bd2ae1a36d813baf227d55c7c576192f40f 
      tabname = "UDF_Latest_session_by_user('#{@user.email}')"
      outcome = SqlserverHelper.database_select("sqlserver", "PARIS_REPORTER", "dbo", tabname , ["session_id"], nil, nil, nil)
    end

    # Route: Display item sub upload validation
    def display_itemsub_result
      @url = YAML.load_file("#{Rails.root}/config/tableauview.yml")[ENV["RAILS_ENV"]]["item_sub"]["upload_validation"]
      tabname = "UDF_Latest_session_by_user('#{@user.email}')"
      outcome = SqlserverHelper.database_select("sqlserver", "PARIS_REPORTER", "dbo", tabname , ["session_id"], nil, nil, nil)
      if (outcome.count == 0)
        @session = ''
      else
        @session = outcome[0]["session_id"]
      end
      @url = "#{@url}?SESSION_ID=#{@session}" 
    end

    #Function: Validate item
    def itemsub_validate(session)
      # Retrieve item master list from HANA
      #url = YAML.load_file("#{Rails.root}/config/hana_config.yml")[ENV["RAILS_ENV"]]["items"]["url"]
      #outcome = HanaHelper.hana_select("hana", url)
      outcome = nil
      if (outcome == nil)
        #if HANA is not available, get it from SQL Server
        outcome = SqlserverHelper.database_select("sqlserver", "PARIS_REPORTER", "dbo", "T_ITEMS", ["MATERIAL_NO"], nil, nil, nil)
        items = outcome.map(){|r| r["MATERIAL_NO"]}
      else
        items = outcome["results"].map(){|r| r["MATERIAL_NO"]}
      end

      # Retrieve items from the session just upload
      tabname = "UDF_GET_ITEM_LIST('#{session}')"
      outcome = SqlserverHelper.database_select("sqlserver", "PARIS_REPORTER", "dbo", tabname , ["col_value"], nil, "REPLACE(col_name,' ','') = 'Itemnumber'", nil)
      candidates = outcome.map(){|i| i["col_value"]}
      result = candidates.map(){|c| [session, c, (items.include? c)]} 
      # DONE: write it back to database and display on tableau 
      # TODO: what if the wrong format altogether
      if (result.count > 0)
        final = SqlserverHelper.database_insert("sqlserver", "PARIS_REPORTER", "dbo", "t_item_validation", ["session_id","item_id", "status"], result)
      end
    end
    #---------------------------------------------------------------------#
    def display_summary
        @url = YAML.load_file("#{Rails.root}/config/tableauview.yml")[ENV["RAILS_ENV"]]["analytics"]["summary"]
    end

    #Allow the user to see the data scope available to them
    def display_data_universe

    end

end
