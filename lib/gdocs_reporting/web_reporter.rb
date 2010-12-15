require 'net/http'
require 'benchmark'
module GdocsReporting
  class WebReporter < SheetReporter
    attr_accessor :page_name, :output_rows, :input_column, :poll_interval

    def initialize
      super
      self.sheet        = ask("              Sheet name: ") { |q| q.default = "Automated Tests" }
      self.page         = ask("               Page name: ") { |q| q.default = "Server response Times" }
      self.input_column = ask("        Host (input) row: ") { |q| q.default = 2 }
      status_row        = ask("        Web response row: ") { |q| q.default = 5 }
      request_time_row  = ask("   Web response time row: ") { |q| q.default = 6 }
      timestamp_row     = ask("           Timestamp row: ") { |q| q.default = 7 }
      self.poll_interval = ask("Poll Interval (seconds): ") { |q| q.default = 30 }

      self.poll_interval = self.poll_interval.to_i
      self.input_column  = self.input_column.to_i
      self.output_rows = [status_row.to_i,request_time_row.to_i,timestamp_row.to_i]
    end
    
    def check_host(url_string)
      begin
        url = URI.parse(url_string)
        req = Net::HTTP::Get.new(url.path)
        response = ''
        time = Benchmark.realtime do
          response = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
        end
        result = 'no'
        if response.code =~/^2/
          result = 'yes'
        elsif response.code =~/^3/
          result = 'redirect'
        end
        return [result,time]
      rescue StandardError => e
        puts "#{e} thrown for url #{url_string}"
        return ["no", 100]
      end
    end

    def check_hosts
      update_rows(self.input_column,self.output_rows) do |input,outputs|
        if ( input =~ /\.org/ )
          input = "http://#{input}" unless (input =~ /http/) 
          input = "#{input}/" unless (input =~ /\/$/)
          results,time = check_host(input)
          outputs[0] = results
          outputs[1] = time
          outputs[2] = Time.now.strftime("%D - %I:%M:%S %p")
        else
          puts "WARNING: didn't find well formated host input on #{self.page.title}, column #{self.input_column}, found: #{input}"
        end
      end
    end
    
    def deamonize(_interval=self.poll_interval)
      error_count = 0
      while (true)
        begin
          self.page.reload  # check for changes
          self.check_hosts
        rescue
          error_count = error_count + 1;
          delay = error_count * error_count * _interval
          puts "Error (#{error_count}): #{$!}"
          sleep (delay)
        else
          error_count = 0
        end
        sleep(_interval)
      end
    end
    def self.run
      r = WebReporter.new
      r.deamonize
    end
  end
end
