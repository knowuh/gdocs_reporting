require 'net/http'
require 'benchmark'
require 'sheet_reporter'
module GdocsReporting
  class WebReporter < SheetReporter
    attr_accessor :page_name, :output_rows, :input_row

    def initialize
      super
      self.sheet = ask("Sheet name: ") { |q| q.default = "Seymour Audit" }
      self.page  = ask("Page name:  ") { |q| q.default = "Production Web Apps" }
      self.input_row   = 2
      self.output_rows = [5,6,7]
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
      update_rows(self.input_row,self.output_rows) do |input,outputs|
        if ( input =~ /\.org/ )
          input = "http://#{input}" unless (input =~ /http/) 
          input = "#{input}/" unless (input =~ /\/$/)
          results,time = check_host(input)
          outputs[0] = results
          outputs[1] = time
          outputs[2] = Time.now.strftime("%D - %I:%M:%S %p")
        end
      end
    end
    
    def deamonize(interval=120)
      error_count = 0
      while (true)
        begin
          self.check_hosts
        rescue
          error_count = error_count + 1;
          delay = error_count * error_count * interval
          puts "Error (#{error_count}): $!"
          sleep (delay)
        else
          error_count = 0
        end
        sleep(interval)
      end
    end
    def self.run
      r = WebReporter.new
      r.deamonize
    end
  end
end
