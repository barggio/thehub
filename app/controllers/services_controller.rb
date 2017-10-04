#This class is explicitly to service Ajax services
class ServicesController < ApplicationController
    # Send back the panel for tableau controller
    def get_controlpanel
        sessionid = "" #get from query string
        render json: {id: sessionid, dummy: "abc"}
    end

    # Send out email to job chomper
    def send_email
      
    end

    
end
