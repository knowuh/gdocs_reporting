
module GdocsReporting
  class SheetReporter
    attr_accessor :email,
                  :password,
                  :session

    def initialize
      HighLine.track_eof = false
      self.email    = ask("Google account email: ")             { |q| q.default = "your_account@google.com" }
      self.password = ask("Google account password: ")          { |q| q.default = "password"; q.echo = "*"}
      self.session = GoogleSpreadsheet.login(self.email,self.password)
    end

    def sheet=(name)
      if defined? name
        @sheet = self.session.spreadsheets.find { |s| s.title == name }
        unless @sheet
          puts "Warning: sheet #{name} not found, making a new one"
          @sheet = self.session.create_spreadsheet(name)
        end
      end
      return @sheet
    end

    def sheet
      return @sheet
    end

    def page=(name)
      if defined? name
        @page = self.sheet.worksheets.find  { |w| w.title == name  }
      end
      unless @page
        puts "Warning: page #{name} not found, making a new one"
        @page = self.sheet.add_worksheet(name)
      end
      return @page
    end

    def page
      return @page
    end

    def write_data(data,options = {})
      if options[:sheet] 
        self.sheet = options[:sheet]
      end
      if options[:page] 
        self.page = options[:page]
      end

      row_offset = options[:row_offset]       || 0
      column_offset = options[:column_offset] || 0

      data.each_with_index do |values,i|
        values.each_with_index { |v,j| self.page[i + row_offset + 1, j + column_offset + 1] = v }
      end
      self.page.save
    end

    # like a ruby excel macro: 
    # pass in a block to evalutate input_data, and send back output_data
    def update_rows(input_column,output_columns,start_row = 1)
      first = start_row
      last = self.page.num_rows
      first.upto(last) do |row|
        input_data  = self.page[row,input_column]
        output_data = output_columns.map { |c| self.page[row,c] }
        yield input_data, output_data
        # write the data back out again
        output_data.each_with_index { |c,i| self.page[row,output_columns[i]] = c }
      end
      self.page.save
    end
  end
end

