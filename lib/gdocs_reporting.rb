
require 'rubygems'
require 'highline/import'
require 'google_spreadsheet'

$: << File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(File.dirname(__FILE__),'gdocs_reporting')

module GdocsReporting
    require 'sheet_reporter'
    require 'web_reporter'
    require 'sar_reporter'
end
