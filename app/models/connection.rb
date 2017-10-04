class Connection < ActiveRecord::Base
    self.establish_connection :development
    self.abstract_class = true
end