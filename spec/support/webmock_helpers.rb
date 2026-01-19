# frozen_string_literal: true

require 'fileutils'

module WebmockHelpers
  def stubbed_get_response(request)
    path = path_for_request(request:, query: underscore_query(request.uri.query))

    unless File.exist?(path)
      raise "Could not locate #{path} (stubbing #{request.uri})" unless ENV.fetch('DOWNLOAD', '0') == '1'

      download_file_to_path(request.uri, path)
    end

    {
      body: File.new(path),
      status: 200
    }
  end

  def path_for_request(request:, query:)
    path = [request.uri.path.gsub(%r{/?api/v[\d.]+/?}, ''), query].reject(&:empty?)

    File.expand_path "../data/#{path.join('/')}.json", __dir__
  end

  def a_get_request(endpoint, query = {})
    a_request(:get, %r{/api/#{endpoint}\?}).with(query: query.merge(t: Time.now.to_i.to_s))
  end

  def stub_requests!(with_response: false)
    return WebMock.stub_request(:any, /mlb(?:infra)?\.com/) unless with_response

    WebMock.stub_request(:any, /mlb(?:infra)?\.com/).to_return { stubbed_get_response(it) }
  end

  def underscore_query(query)
    return '' unless query

    query.gsub(/[?&]?t=\d+/, '').gsub(/\W/, '_').gsub(/_+$/, '')
  end

  def download_file_to_path(url, path)
    # puts "Download file #{url} to #{path}"

    WebMock.disable!

    FileUtils.mkdir_p(File.dirname(path))
    `wget "#{url}" -O #{path}`

    WebMock.enable!
  end
end
