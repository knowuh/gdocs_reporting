
module GdocsReporting
  class SarReporter < SheetReporter
    attr_accessor :sar_host

    def initialize
      super
      self.sheet    = ask("Sheet name: ") { |q| q.default = "Seymour Audit" }
      self.page     = ask("Page name:  ") { |q| q.default = "sar_data" }
      self.sar_host = ask("sar host:   ") { |q| q.default = "some.random.host.org" }
    end
    ## sar specific things here:
    def remote_command(command)
      return %x(ssh #{self.sar_host} "#{command}")
    end

    #00:00:01          CPU     %user     %nice   %system   %iowait    %steal     %idle
    #00:10:02          all      1.21      0.00      0.69      0.30      0.00     97.80
    #00:20:01          all      1.58      0.06      1.15      1.84      0.00     95.36
    def record_sar
      date = Chronic.parse('yesterday')
      day   = "%02d" % date.day
      headers = ["Time"]
      data = []
      remote_command("sar -f /var/log/sa/sa#{day}").each_line do |line|
        if line.match(/(CPU.*$)/)
          headers = headers + $1.split
        elsif
          line.match(/^((\d{2}):(\d{2}):(\d{2}))/)
          data << line.split()
        end
      end
      write_data(headers)
      write_data(data, {:row_offset => 1 })
    end
  end
end
