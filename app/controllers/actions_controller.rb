#require 'helper'
class ActionsController < ApplicationController
  before_action :auth_login
  
    def new
        binding.pry
        #Trapping stray route
    end
    
    def show
        binding.pry
    end

    def upload_file
      #Load upload view
      #render the view "upload_file"
    end

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
        SessionHelper.processdata(token, path)
      end
      redirect_to actions_display_summary_path
    end

    def display_summary
        @url = YAML.load_file("#{Rails.root}/config/tableauview.yml")[ENV["RAILS_ENV"]]["analytics"]["summary"]
    end

    #Allow the user to see the data scope available to them
    def display_data_universe

    end
    
end
