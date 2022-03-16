# frozen_string_literal: true

require 'redd/utilities/unmarshaller'

class StubClient
  # Holds a returned HTTP response.
  Response = Struct.new(:code, :headers, :body) do
    def raw_body
      @raw_body ||= JSON.generate(body)
    end
  end

  def initialize
    @unmarshaller = Redd::Utilities::Unmarshaller.new(self)
  end

  def unmarshal(object) = @unmarshaller.unmarshal(object)

  def model(verb, path, **params) = unmarshal(send(verb, path, params).body)

  def get(_path, **_params) = (raise NotImplementedError, 'stub #get')

  def post(_path, **_params) = (raise NotImplementedError, 'stub #post')

  def put(_path, **_params) = (raise NotImplementedError, 'stub #put')

  def patch(_path, **_params) = (raise NotImplementedError, 'stub #patch')

  def delete(_path, **_params) = (raise NotImplementedError, 'stub #delete')
end
