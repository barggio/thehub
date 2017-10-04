
module ExcelHelper 
    def self.parse(path) 
        
        workbook = Roo::Spreadsheet.open path 
        worksheets = workbook.sheets 
        puts "Found #{worksheets.count} worksheets" 
        #checks each worksheet 
        #prepare payload
        output = []
        i = 1
        worksheets.each do |worksheet| 
            payload = []
            fields = []
            num_rows = 0                 
            #checks each row   
            workbook.sheet(worksheet).each_row_streaming do |row|
                row_id = row_cord = row.map {|cell| cell.coordinate.row}.max
                row_cells = row.map { |cell| cell.cell_value.to_s } 
                fields.push([row_id, row_cells])    
                #row_len = row.inject(0) {|sum , cell| sum += cell.value.to_s.length }
                #no_nonnum = row.inject(0) {|sum , cell| sum += ((cell.value.to_s.numeric?)?0:1) }
                
                #Item.create!(item_number: row_cells[0], start_date: row_cells[1], end_date: row_cells[2], is_excluded: row_cells[3])                 
            end 
            output.push([worksheet, fields, payload])
        end 
        output
    end

end 

class String
    def numeric?
      Float(self) != nil rescue false
    end
end