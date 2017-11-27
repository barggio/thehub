class ServicesController < ApplicationController
    def get_controlpanel
        sessionid = "" #get from query string
        render json: {id: sessionid, dummy: "abc"}
    end

    def send_email
        #Process query string
        

    end
end